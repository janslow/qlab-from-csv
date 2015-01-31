//
//  ViewController.swift
//  QLabFromCsv
//
//  Created by Jay Anslow on 24/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Cocoa
import AppKit

class ViewController: NSViewController, QLKBrowserDelegate {
    
    @IBOutlet weak var serverComboBox: NSComboBox!
    @IBOutlet weak var workspaceComboBox: NSComboBox!
    @IBOutlet weak var cueListComboBox: NSComboBox!
    @IBOutlet weak var cueListProgressAnimation: NSProgressIndicator!
    @IBOutlet weak var connectButton: NSButton!
    @IBOutlet weak var appendButton: NSButton!
    @IBOutlet weak var inputFileTextField: NSTextFieldCell!
    @IBOutlet weak var logFileTextField: NSTextFieldCell!
    
    private let serverComboBoxDataSource = ServerComboBoxDataSource()
    private let workspaceComboBoxDataSource = WorkspaceComboBoxDataSource()
    private let cueListComboBoxDataSource = CueComboBoxDataSource(showNumber: false)
    private let csvParser = CsvParser.csv()
    private let rowParser = RowParser()
    
    private var selectedCsv : NSURL? = nil
    private var connectedWorkspace : QLKWorkspace? = nil
    private var isConnected : Bool {
        get {
            return connectedWorkspace != nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "workspaceDidUpdateCues:", name: QLKWorkspaceDidUpdateCuesNotification, object: nil)
        
        let browser = QLKBrowser()
        browser.delegate = self;
        browser.start()
        browser.enableAutoRefreshWithInterval(3);
        
        serverComboBoxDataSource.bindToComboBox(serverComboBox)
        workspaceComboBoxDataSource.bindToComboBox(workspaceComboBox)
        cueListComboBoxDataSource.bindToComboBox(cueListComboBox)
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func browserDidUpdateServers(browser : QLKBrowser) {
        serverComboBoxDataSource.setItems(browser.servers)
    }
    
    func serverDidUpdateWorkspaces(server : QLKServer) {
        if serverComboBoxDataSource.getSelectedServer()?.host == server.host {
            workspaceComboBoxDataSource.setItems(server.workspaces)
        }
    }
    
    func workspaceDidUpdateCues(notification : NSNotification) {
        setStateConnecting(false)
        if let workspace = connectedWorkspace {
            let cueLists = (workspace.root.cues as [AnyObject]).filter({
                // Exclude fake cue lists (i.e., Active Cues).
                ($0 as QLKCue).number != nil
            })
            cueListComboBoxDataSource.setItems(cueLists)
        }
    }
    
    @IBAction func onServerChange(sender: NSComboBox) {
        let workspaces = serverComboBoxDataSource.getSelectedServer()?.workspaces ?? []
        workspaceComboBoxDataSource.setItems(workspaces)
    }
    
    @IBAction func onConnectClick(sender: NSButton) {
        // Already connected to a workspace.
        if isConnected {
            // Disconnect from workspace.
            connectedWorkspace!.disconnect()
            connectedWorkspace = nil
            setStateConnecting(false)
        // Not connected to a workspace
        } else if let workspace = workspaceComboBoxDataSource.getSelectedWorkspace() {
            setStateConnecting(true)
            // Try to connect to the workspace.
            workspace.connectWithPasscode(nil) {
                (reply : AnyObject!) in
                if (reply as? String) == "ok" {
                    self.connectedWorkspace = workspace
                    workspace.enableAlwaysReply()
                    workspace.fetchCueLists()
                } else {
                    // If unable to connect, show an error message.
                    let alert = NSAlert()
                    alert.addButtonWithTitle("OK")
                    alert.messageText = "Connection Error"
                    alert.informativeText = reply as? String
                    alert.alertStyle = NSAlertStyle.WarningAlertStyle
                    alert.runModal()
                    self.setStateConnecting(false)
                }
            }
        }
    }
    @IBAction func onInputFileBrowseClick(sender: NSButton) {
        let dialog = NSOpenPanel()
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false
        
        if dialog.runModal() == NSOKButton && !dialog.URLs.isEmpty {
            selectedCsv = dialog.URLs[0] as? NSURL
            inputFileTextField.stringValue = selectedCsv?.lastPathComponent ?? selectedCsv?.path ?? "#UNKNOWN#"
        }
    }
    @IBAction func onLogFileBrowseClick(sender: NSButton) {
        let dialog = NSOpenPanel()
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
        
        if dialog.runModal() == NSOKButton && !dialog.URLs.isEmpty {
            logFileTextField.stringValue = (dialog.URLs[0] as? NSURL)?.path ?? ""
        }
    }
    
    @IBAction func onAppendClick(sender: NSButton) {
        if let workspace : QLKWorkspace = connectedWorkspace {
            if let csvPath = selectedCsv?.path {
                if let csv = csvParser.parseFromFile(csvPath) {
                    let cues = rowParser.load(csv.rows)
                    
                    let connector = CueQLabConnector(workspace: workspace)
                    connector.appendCues(cues) {
                        (uids : [String]) in
                        println("Created all \(uids.count) cues : (\(uids))")
                    }
                } else {
                    println("Unable to read input file")
                }
            } else {
                println("No input file")
            }
        } else {
            println("Not connected")
        }
    }
    
    private func setStateConnecting(connecting : Bool) {
        serverComboBox.enabled = !connecting && !isConnected
        workspaceComboBox.enabled = !connecting && !isConnected
        cueListComboBox.enabled = !connecting && isConnected
        connectButton.enabled = !connecting
        appendButton.enabled = !connecting && isConnected
        
        cueListProgressAnimation.hidden = !connecting
        
        if (connecting) {
            cueListProgressAnimation.startAnimation(self)
            
            connectButton.title = "Connecting"
        } else {
            cueListProgressAnimation.stopAnimation(self)
            
            if (isConnected) {
                connectButton.title = "Disconnect"
            } else {
                connectButton.title = "Connect"
            }
        }
    }
}