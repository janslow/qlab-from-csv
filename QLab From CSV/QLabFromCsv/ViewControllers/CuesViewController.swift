//
//  CuesViewController.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 10/02/2015.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

@objc public protocol CuesViewController : ChildViewController {
    var Cues : [Cue] { get }
    
    var IsValid : Bool { get }
}

@objc public class CuesViewControllerImpl : NSViewController, CuesViewController {
    public var Parent : MasterViewController?
    
    @IBOutlet weak var _inputFileTextField: NSTextField!
    @IBOutlet weak var _logFileTextField: NSTextField!
    @IBOutlet weak var _rowCountLabel: NSTextField!
    @IBOutlet weak var _logEnabledRadio: NSButtonCell!
    @IBOutlet weak var _logDisabledRadio: NSButtonCell!
    
    private let _csvParser = CsvParser.csv()
    private let _cueParser = RowParser(csvTemplate: SimpleCsvTemplate())
    private var _selectedCsv : NSURL? = nil
    private var _csvHeaders : [String] = []
    private var _csvRows : [Dictionary<String, String>] = []
    private var _cues : [Cue] = []
    
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
            _selectedCsv = NSURL(fileURLWithPath: "/Users/janslow/dev/qlab-from-csv/sample_cues.csv")
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
        
        if dialog.runModal() == NSOKButton && !dialog.URLs.isEmpty {
            _selectedCsv = dialog.URLs[0] as? NSURL
            _inputFileTextField.stringValue = _selectedCsv?.lastPathComponent ?? _selectedCsv?.path ?? ""
            log.debug("Selected input file: \(_selectedCsv?.path)")
            onReloadClick(sender)
        }
    }
    
    @IBAction func onReloadClick(sender: NSButton) {
        _csvHeaders = []
        _csvRows = []
        if let csvPath = _selectedCsv?.path {
            if let csv = _csvParser.parseFromFile(csvPath) {
                _csvHeaders = csv.headers
                _csvRows = csv.rows
                
                _rowCountLabel.stringValue = "\(_csvRows.count) rows plus header row, \(_csvHeaders.count) header columns."
                log.debug("Parsed file with \(_rowCountLabel.stringValue)")
                
                createCues()
            } else {
                log.warning("Append error: Unable to parse input file.")
                _rowCountLabel.stringValue = "Unable to parse as CSV file."
            }
        } else {
            log.error("Append error: No input file selected.")
            _rowCountLabel.stringValue = "No input file selected."
        }
    }
    
    @IBAction func onLogFileBrowseClick(sender: NSButton) {
        let dialog = NSOpenPanel()
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
        
        if dialog.runModal() == NSOKButton && !dialog.URLs.isEmpty {
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
        var senderId = "\(sender)"
        if let senderWithId = sender as? NSUserInterfaceItemIdentification {
            senderId = senderWithId.identifier
        }
        log.debug("Cue creation triggered: Changed log configuration \(senderId).")
        createCues()
    }
    
    // Update _cues by regenerating all cues from _csvRows and the current configuration.
    private func createCues() {
        var cues = _cueParser.load(_csvRows)
        
        _cues = applyLogs(cues)
        log.debug("Parsed \(_cues.count) cues.")
        
        Parent?.fireCheckValid()
    }
    
    private func applyLogs(cues : [Cue]) -> [Cue] {
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
}