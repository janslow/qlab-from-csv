QLab from CSV
=============

This project is designed to take a list of cues from a spreadsheet (in CSV format) and populate a QLab cue list with them using OSC. *QLab from CSV* is not associated with Figure 53.

Requirements
------------

* `Ruby` (tested with `1.9.3p392`)
* `Bundler` gem (tested with `1.3.4`)
* [`QLab 3`](http://figure53.com/qlab/) (tested with `3.1.6`)
  * Whilst it is theoretically possible to run qlab-for-ruby over a network, it is recommended to run the QLab instance on the same machine.
* [`QLX`](http://www.qlx.io/) (for controlling ETC Eos desks)

Installation
------------

* Download the contents of this repository and open a terminal window in it's directory
* `bundle install`
* `./qlab_from_csv.rb`

Configuration
-------------

Configuration must currently be done by editing the main script. The following values should be configured:

* `csv_file = '/path/to/cues.csv'` - Path to source CSV
* `@qlx_script_file = '/path/to/QLX.scpt'` - Path to QLX AppleScript file
* `@log_file = '/path/to/log.csv'` - Path to Cue Log file

In addition, QLX should be configured as stated on [their website](http://www.qlx.io/setup.html). However, the `QLXPATH` configuration cue does not need to be set (it must be hard coded into the cue). QLab should also accept OSC commands on the default port (`Workspace Settings` > `OSC Controls` > `Use OSC Controls` should be ticked)

CSV Syntax
----------

The CSV file should be UTF-8 encoded and have the following columns (the order doesn't matter):

* `QLab` - The unique cue number for the cue in QLab. Required.
* `LX` - The cue number to trigger on an Eos desk.
* `Sound`/`Video` - The cue number of the cue to start in QLab (starts cue number prefixed by `S` or `V` respectively).
* `Comment` - Comment to add to the description of the cue.
* `Page` - Page number to add to the description of the cue.

There should be a header row with the column names (as above) at the top of the file.

The `LX`/`Sound`/`Video` accepts instructions which conform to the following rules:

* The value can be empty (this means nothing is done).
* The instruction can be to fire a single cue, identified by a number which can contain letters, numbers, underscores and decimal points (such as `1.32a_v2`).
* Multiple cues can be fired in a single instruction by joining cue numbers with a comma (e.g., `1,2` fires `1` and `2` at the same time).
* Whitespace (spaces, tabs etc.) in lists are ignored (e.g., `1, 2` is identical to `1,2`).
* Cues can be delayed by appending `/dX` (where X is the number of seconds to pre-wait) to a cue number (e.g., `1/d5` fires `1` after 5 seconds).

For example, `1, 2/d3.2` fires `1` immediately then `2` after 3.2 seconds.

As a regular expression:

  ^(\s*[\w\.]+(/d[\d\.]+)?\s*(,\s*[\w\.]+(/d[\d\.]+)?\s*)*)?$

An example of a valid file is `sample_cues.csv` in this repository.