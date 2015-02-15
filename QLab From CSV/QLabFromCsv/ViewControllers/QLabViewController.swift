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
    
    private var state : ConnectionState = ConnectionState.NotConnected {
        didSet {
            onStateChange()
        }
    }
    
    public var Workspace : QLKWorkspace? {
        switch state {
        case let .Connected(workspace):
            return workspace
        default:
            return nil
        }
    }
    public var IsConnected : Bool {
        switch state {
        case .Connected:
            return true
        default:
            return false
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
        onStateChange()
    }
    
    public func serverDidUpdateWorkspaces(server : QLKServer) {
        if serverComboBoxDataSource.getSelectedServer()?.host == server.host {
            workspaceComboBoxDataSource.setItems(server.workspaces)
            onStateChange()
        }
    }
    
    func workspaceDidUpdateCues(notification : NSNotification) {
        if let workspace = Workspace {
            let cueLists = (workspace.root.cues as [AnyObject]).filter({
                // Exclude fake cue lists (i.e., Active Cues).
                ($0 as QLKCue).number != nil
            })
            cueListComboBoxDataSource.setItems(cueLists)
            onStateChange()
        }
    }
    
    @IBAction func onServerChange(sender: NSComboBox) {
        let workspaces = serverComboBoxDataSource.getSelectedServer()?.workspaces ?? []
        workspaceComboBoxDataSource.setItems(workspaces)
        onStateChange()
    }
    
    @IBAction func onConnectClick(sender: NSButton) {
        switch state {
        case .NotConnected:
            if let workspace = workspaceComboBoxDataSource.getSelectedWorkspace() {
                connect(workspace)
            }
        case let .Connecting(workspace):
            disconnect(workspace)
        case let .Connected(workspace):
            disconnect(workspace)
        }
    }
    
    private func connect(workspace : QLKWorkspace) {
        state = ConnectionState.Connecting(workspace)
        
        // Try to connect to the workspace.
        workspace.connectWithPasscode(nil) {
            (reply : AnyObject!) in
            if (reply as? String) == "ok" {
                self.state = ConnectionState.Connected(workspace)
                workspace.enableAlwaysReply()
                workspace.fetchCueLists()
                log.info("Connected to \(workspace.serverName)/\(workspace.name)")
            } else {
                self.state = ConnectionState.NotConnected
                log.error("QLab connection error: \(workspace.serverName)/\(workspace.name) - \(reply)")
                // If unable to connect, show an error message.
                let alert = NSAlert()
                alert.addButtonWithTitle("OK")
                alert.messageText = "Connection Error"
                alert.informativeText = reply as? String
                alert.alertStyle = NSAlertStyle.WarningAlertStyle
                alert.runModal()
            }
        }
    }
    
    private func disconnect(workspace : QLKWorkspace) {
        Workspace!.disconnect()
        state = ConnectionState.NotConnected
    }
    
    private func onStateChange() {
        var isLocked = false
        var isConnecting = false
        var isConnected = false
        var canConnectDisconnect = false
        switch state {
        case .NotConnected:
            canConnectDisconnect = workspaceComboBoxDataSource.getSelectedWorkspace() != nil
            connectButton.title = "Connect"
        case .Connecting:
            isLocked = true
            isConnecting = true
            connectButton.title = "Connecting"
        case .Connected:
            isLocked = true
            isConnected = true
            canConnectDisconnect = true
            connectButton.title = "Disconnect"
        }
        
        serverComboBox.enabled = !isLocked
        workspaceComboBox.enabled = !isLocked
        
        cueListComboBox.enabled = isConnected
        
        connectButton.enabled = !isConnecting
        cueListProgressAnimation.hidden = !isConnecting
        if (isConnecting) {
            cueListProgressAnimation.startAnimation(self)
        } else {
            cueListProgressAnimation.stopAnimation(self)
        }
        
        MAIN_VIEW_CONTROLLER?.fireCheckValid()
    }
}