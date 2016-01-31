//
//  CuesViewControllerImpl.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-21.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

public class CuesViewControllerImpl : NSViewController, CuesViewController {
    @IBOutlet weak var _inputFileTextField: NSTextField!
    @IBOutlet weak var _logFileTextField: NSTextField!
    @IBOutlet weak var _rowCountLabel: NSTextField!
    @IBOutlet weak var _logEnabledRadio: NSButtonCell!
    @IBOutlet weak var _logDisabledRadio: NSButtonCell!
    
    private let _csvParser = X32CsvParser()
    private var _selectedCsv : NSURL? = nil
    
    private var _csvFile : CsvFile? = nil
    private var _csvIssueAcceptor : ParseIssueAcceptor = ParseIssueAcceptorImpl()
    
    private var _cues : [Cue] = []
    private var _cueIssueAcceptor : ParseIssueAcceptor = ParseIssueAcceptorImpl()
    
    public var Cues : [Cue] {
        get {
            return _cues
        }
    }
    public var IsValid : Bool {
        get {
            return !_cues.isEmpty
        }
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("Loaded CuesViewController")
        
        #if DEBUG
            // Default CSV file when in debug mode.
            _selectedCsv = NSURL(fileURLWithPath: "/Users/janslow/dev/qlab-from-csv/x32_sample_cues.csv")
            _inputFileTextField.stringValue = _selectedCsv?.lastPathComponent ?? "Unable to load sample_cues.csv"
        #endif
    }
    
    public override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func onInputFileBrowseClick(sender: NSButton) {
        let dialog = NSOpenPanel()
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false
        
        if let defaultUrl = _selectedCsv {
            dialog.directoryURL = defaultUrl
        }
        
        if dialog.runModal() == NSModalResponseOK && !dialog.URLs.isEmpty {
            _selectedCsv = dialog.URLs[0]
            _inputFileTextField.stringValue = _selectedCsv?.lastPathComponent ?? _selectedCsv?.path ?? ""
            log.debug("Selected input file: \(_selectedCsv?.path)")
            onReloadClick(sender)
        }
    }
    
    @IBAction func onReloadClick(sender: NSButton) {
        resetCsv()
        if let csvPath = _selectedCsv?.path {
            _csvFile = _csvParser.parseFromFile(csvPath, issues: _csvIssueAcceptor)
            if !_csvIssueAcceptor.HasFatalErrors {
                let csv = _csvFile!
                _rowCountLabel.stringValue = "\(csv.rows.count) rows plus header row, \(csv.headers.count) header columns."
                log.debug("Parsed file with \(_rowCountLabel.stringValue)")
                
                createCues(csv, patch: 2)
                return
            }
        } else {
            _csvIssueAcceptor.add(IssueSeverity.FATAL, line: nil, cause: nil, code: "NO_FILE", details: "No input file selected.")
        }
        _rowCountLabel.stringValue = "Unable to parse as CSV file."
        displayIssues()
    }
    
    @IBAction func onLogFileBrowseClick(sender: NSButton) {
        let dialog = NSOpenPanel()
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
        
        if dialog.runModal() == NSModalResponseOK && !dialog.URLs.isEmpty {
            if let url = dialog.URLs[0] as? NSURL {
                if let path = url.path {
                    var isDirectory : ObjCBool = ObjCBool(false)
                    if NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDirectory) && isDirectory.boolValue {
                        _logFileTextField.stringValue = NSURL(string: "log.csv", relativeToURL: url)?.path ?? ""
                    } else {
                        _logFileTextField.stringValue = url.path ?? ""
                    }
                    onLogFileInputChange(sender)
                }
            }
        }
    }
    
    // Set the log file to a default log.csv file.
    @IBAction func onLogFileEnable(sender: AnyObject) {
        _logFileTextField.stringValue = "log.csv"
        onLogFileInputChange(sender)
    }
    
    // Clear the log file.
    @IBAction func onLogFileDisable(sender: AnyObject) {
        _logFileTextField.stringValue = ""
        onLogFileInputChange(sender)
    }
    
    // Trigger cue creation because the log file has changed.
    @IBAction func onLogFileInputChange(sender: AnyObject) {
        if let csvFile = _csvFile {
            var senderId = "\(sender)"
            if let senderIdentifier = (sender as? NSUserInterfaceItemIdentification)?.identifier {
                senderId = senderIdentifier
            }
            log.debug("Cue creation triggered: Changed log configuration \(senderId).")
            createCues(csvFile, patch: 2)
        }
    }
    
    private func displayIssues() {
        let issues = _csvIssueAcceptor.Issues + _cueIssueAcceptor.Issues
        if issues.isEmpty {
            log.info("No issues")
        } else {
            log.warning("\(issues.count) issues")
        }
    }
    
    // Update _cues by regenerating all cues from _csvRows and the current configuration.
    private func createCues(csvFile : CsvFile, patch: Int) {
        resetCues()
        if let csvTemplate = createCsvTemplate(csvFile, patch: patch) {
            let cueParser = RowParser(csvTemplate: csvTemplate)
            var cues = cueParser.load(csvFile, issues: _cueIssueAcceptor)
            
            if !_cueIssueAcceptor.HasFatalErrors {
                cues = applyLogs(cues, issues: _cueIssueAcceptor)
                
                if !_cueIssueAcceptor.HasFatalErrors {
                    _cues = cues
                    log.debug("Parsed \(_cues.count) cues.")
                    
                    MAIN_VIEW_CONTROLLER?.fireCheckValid()
                }
            }
        }
        displayIssues()
    }
    
    private func createCsvTemplate(csvFile : CsvFile, patch: Int) -> CsvTemplate? {
        let nillableCsvTemplate = X32CsvTemplateFactory.build(csvFile.headers, patch: patch, issues: _cueIssueAcceptor)
        if _cueIssueAcceptor.HasFatalErrors {
           return nil
        }
        return nillableCsvTemplate!
    }
    
    private func applyLogs(cues : [Cue], issues : ParseIssueAcceptor) -> [Cue] {
        let logPath = _logFileTextField.stringValue
        if !logPath.isEmpty {
            _logEnabledRadio.state = 1
            _logDisabledRadio.state = 0
            return cues.map({
                (c : Cue) in
                if let cue = c as? GroupCue {
                    cue.children += [LogScriptCue(logId: cue.cueNumber!, logFile: logPath, preWait: 0) as Cue]
                }
                return c
            })
        } else {
            _logEnabledRadio.state = 0
            _logDisabledRadio.state = 1
            return cues
        }
    }
    
    private func resetCsv() {
        _csvIssueAcceptor = ParseIssueAcceptorImpl()
        _csvFile = nil
        resetCues()
    }
    
    private func resetCues() {
        _cueIssueAcceptor = ParseIssueAcceptorImpl()
        _cues = []
    }
}