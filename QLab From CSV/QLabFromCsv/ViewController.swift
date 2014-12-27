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
    
    private var serverComboBoxDataSource = ServerComboBoxDataSource()
    private var workspaceComboBoxDataSource = WorkspaceComboBoxDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let browser = QLKBrowser()
        browser.delegate = self;
        browser.start()
        browser.enableAutoRefreshWithInterval(3);
        
        serverComboBoxDataSource.bindToComboBox(serverComboBox)
        workspaceComboBoxDataSource.bindToComboBox(workspaceComboBox)
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    func browserDidUpdateServers(browser : QLKBrowser) {
        serverComboBoxDataSource.setServers(browser.servers as AnyObject as [QLKServer])
    }
    
    func serverDidUpdateWorkspaces(server : QLKServer) {
        if serverComboBoxDataSource.getSelectedServer()?.host == server.host {
            workspaceComboBoxDataSource.setWorkspaces(server.workspaces as AnyObject as [QLKWorkspace])
        }
    }
    
    @IBAction func onServerChange(sender: NSComboBox) {
        let workspaces = serverComboBoxDataSource.getSelectedServer()?.workspaces ?? []
        workspaceComboBoxDataSource.setWorkspaces(workspaces as AnyObject as [QLKWorkspace])
    }
    @IBAction func onWorkspaceChange(sender: NSComboBox) {
        println(workspaceComboBoxDataSource.getSelectedWorkspace()?.name)
    }
}