#!/usr/bin/env ruby

require 'csv'
require 'qlab-ruby'

# Set the path to the source file.
csv_file = './sample_cues.csv'

# Set the path to QLX script (from http://www.qlx.io/).
@qlx_script_file = '/path/to/QLX.scpt'

# Set the path to the cue log.
@log_file = '/path/to/log.csv'

# These should not need changing in most situations.
qlab_hostname = 'localhost'
qlab_workspace_name = nil

qlab_machine = QLab.connect qlab_hostname
if qlab_workspace_name
  @qlab_workspace = qlab_machine.workspaces.find! { |w| w.name == qlab_workspace_name }
else
  @qlab_workspace = qlab_machine.workspaces.first
end

cues = CSV.new(File.read(csv_file), :headers => true, :header_converters => :symbol).to_a.map { |row| row.to_hash }

def parse_cues s
  if !s || s.empty?
    return []
  end
  s.split(',').collect do |q|
    id, delay = q.strip.split '/'
    if !delay
      delay = 0
    elsif delay == 'f'
      delay = :follow
    elsif delay[0] == 'd'
      delay = delay[1..-1].to_f
    else
      delay = 0
    end
    {
      :id => id,
      :delay => delay
    }
  end
end

# Create a sub-cue of a specified type (and add delay if required).
def create_sub_q q_spec, type
  sub_q = @qlab_workspace.new_cue type
  unless sub_q
    raise "Unable to create a new cue of type #{type}"
  end
  sub_q.number = ''
  case q_spec[:delay]
  when :follow
    sub_q.preWait = 0
  else
    sub_q.preWait = q_spec[:delay]
  end
  sub_q
end

# Create a start sub-q.
def create_start_sub_q q_spec, target_prefix
  sub_q = create_sub_q q_spec, 'start'

  target_q_number = "#{target_prefix}#{q_spec[:id]}"
  sub_q.name = "Start #{target_q_number}"

  target_q = @qlab_workspace.find_cue :number => target_q_number
  if target_q
    sub_q.cueTargetId = target_q.id
  end

  sub_q
end

# Create a top-level cue (always a group).
def create_q cue
  q_number = "Q#{cue[:qlab]}"

  # Add the comment and page number to the description, if provided.
  description = ""
  description += "#{cue[:comment]} " if cue[:comment]
  description += "(p#{cue[:page]}) " if cue[:page]

  # 
  cues_description = ""
  sub_qs = []
  
  # Add Log sub-cue.
  log_q = @qlab_workspace.new_cue 'script'
  log_q.number = ''
  log_q.name = "Log #{q_number}"
  # TODO: Extract the log dir into a user configurable variable.
  log_q.scriptSource = "do shell script \"echo \\\"`date '+%Y-%m-%d %H:%M:%S'`,#{q_number}\\\" >> #{@log_file}\""
  sub_qs << log_q

  # Add LX sub-cues.
  parse_cues(cue[:lx]).each do |lx|
    lx_id = lx[:id]
    cues_description += "LX#{lx_id}/"
    
    lx_q = create_sub_q lx, 'script'
    lx_q.name = "QLXGO #{lx_id}"
    lx_q.scriptSource = "run script (\"#{@qlx_script_file}\" as POSIX file)"
    sub_qs << lx_q
  end

  # Add Sound sub-cues.
  parse_cues(cue[:sound]).each do |sound|
    cues_description += "S#{sound[:id]}/"
    
    sound_q = create_start_sub_q sound, "S"
    sub_qs << sound_q
  end

  # Add Video sub-cues.
  parse_cues(cue[:video]).each do |video|
    cues_description += "V#{video[:id]}/"
    
    video_q = create_start_sub_q video, "V"
    sub_qs << video_q
  end

  # Select the sub-cues and wrap them in a group cue.
  @qlab_workspace.select sub_qs
  q = @qlab_workspace.new_cue 'group'
  q.number = q_number
  q.name = description + "(#{cues_description[0..-2]})" if cues_description
end

# Iterate through cues from CSV and put them into QLab.
# [jma] Workaround for non-deterministic OSC issue.
max_attempts = 10
cues.each do |cue|
  for i in 0..max_attempts
    begin
      create_q cue
      break
    rescue StandardError => e
      puts "Failed attempt #{i}", e
      sleep 1
      qlab_machine.refresh
      i += 1
      if i >= max_attempts
        raise e
      end
    end
  end
end

qlab_machine.close