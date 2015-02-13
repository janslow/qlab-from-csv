//
//  ViewController.swift
//  QLabFromCsv
//
//  Created by Jay Anslow on 24/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

import Cocoa
import AppKit

@objc public protocol QLabViewController : ChildViewController {
    var Workspace : QLKWorkspace? { get }
    
    var IsConnected : Bool { get }
}

enum ConnectionState {
    case NotConnected
    case Connecting(QLKWorkspace)
    case Connected(QLKWorkspace)
    case Disconnecting(QLKWorkspace)
}

@objc public class QLabViewControllerImpl: NSViewController, QLKBrowserDelegate, QLabViewController {
    public var Parent : MasterViewController?
    
    @IBOutlet weak var serverComboBox: NSComboBox!
    @IBOutlet weak var workspaceComboBox: NSComboBox!
    @IBOutlet weak var cueListComboBox: NSComboBox!
    @IBOutlet weak var cueListProgressAnimation: NSProgressIndicator!
    @IBOutlet weak var connectButton: NSButton!
    
    private let serverComboBoxDataSource = ServerComboBoxDataSource()
    private let workspaceComboBoxDataSource = WorkspaceComboBoxDataSource()
    private let cueListComboBoxDataSource = CueComboBoxDataSource(showNumber: false)
    
    public var Workspace : QLKWorkspace? = nil
    public var IsConnected : Bool {
        get {
            return Workspace != nil
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("Loaded QLabViewController")
        
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

    public override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    public func browserDidUpdateServers(browser : QLKBrowser) {
        serverComboBoxDataSource.setItems(browser.servers)
    }
    
    public func serverDidUpdateWorkspaces(server : QLKServer) {
        if serverComboBoxDataSource.getSelectedServer()?.host == server.host {
            workspaceComboBoxDataSource.setItems(server.workspaces)
        }
    }
    
    func workspaceDidUpdateCues(notification : NSNotification) {
        setStateConnecting(false)
        if let workspace = Workspace {
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
        if IsConnected {
            // Disconnect from workspace.
            Workspace!.disconnect()
            Workspace = nil
            setStateConnecting(false)
        // Not connected to a workspace
        } else if let workspace = workspaceComboBoxDataSource.getSelectedWorkspace() {
            setStateConnecting(true)
            // Try to connect to the workspace.
            workspace.connectWithPasscode(nil) {
                (reply : AnyObject!) in
                if (reply as? String) == "ok" {
                    self.Workspace = workspace
                    workspace.enableAlwaysReply()
                    workspace.fetchCueLists()
                    log.info("Connected to \(workspace.serverName)/\(workspace.name)")
                } else {
                    // If unable to connect, show an error message.
                    let alert = NSAlert()
                    alert.addButtonWithTitle("OK")
                    alert.messageText = "Connection Error"
                    alert.informativeText = reply as? String
                    alert.alertStyle = NSAlertStyle.WarningAlertStyle
                    alert.runModal()
                    self.setStateConnecting(false)
                    log.error("QLab connection error: \(workspace.serverName)/\(workspace.name) - \(reply)")
                }
            }
        }
    }
    
    private func setStateConnecting(connecting : Bool) {
        serverComboBox.enabled = !connecting && !IsConnected
        workspaceComboBox.enabled = !connecting && !IsConnected
        cueListComboBox.enabled = !connecting && IsConnected
        connectButton.enabled = !connecting
        
        cueListProgressAnimation.hidden = !connecting
        
        if (connecting) {
            cueListProgressAnimation.startAnimation(self)
            
            connectButton.title = "Connecting"
        } else {
            cueListProgressAnimation.stopAnimation(self)
            
            if (IsConnected) {
                connectButton.title = "Disconnect"
            } else {
                connectButton.title = "Connect"
            }
        }
    }
}