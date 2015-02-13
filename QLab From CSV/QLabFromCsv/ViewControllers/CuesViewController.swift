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
    private let _csvParser = CsvParser.csv()
    private let _rowParser = RowParser()
    private var _selectedCsv : NSURL? = nil
    private var _cues : [Cue] = []
    
    public var Cues : [Cue] {
        get {
            return _cues
        }
    }
    public var IsValid : Bool {
        get {
            return true
        }
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("Loaded CuesViewController")
        
        #if DEBUG
            // Default CSV file when in debug mode.
            _selectedCsv = NSURL(fileURLWithPath: "/Users/jay/dev/qlab_from_csv/sample_cues.csv")
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
            _inputFileTextField.stringValue = _selectedCsv?.lastPathComponent ?? _selectedCsv?.path ?? "#UNKNOWN#"
            log.debug("Selected input file: \(_selectedCsv?.path)")
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
                }
            }
        }
    }
    
    @IBAction func onReloadClick(sender: NSButton) {
        if let csvPath = _selectedCsv?.path {
            if let csv = _csvParser.parseFromFile(csvPath) {
                var cues = _rowParser.load(csv.rows)
                let logPath = _logFileTextField.stringValue
                if !logPath.isEmpty {
                    cues = cues.map({
                        (c : Cue) in
                        if let cue = c as? GroupCue {
                            cue.children += [LogScriptCue(logId: cue.cueNumber!, logFile: logPath, preWait: 0) as Cue]
                        }
                        return c
                    })
                }
                _cues = cues
                
            } else {
                log.warning("Append error: Unable to parse input file")
            }
        } else {
            log.error("Append error: No input file")
        }
    }
}