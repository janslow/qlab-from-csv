//
//  ExecuteViewController.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 12/02/2015.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

@objc public protocol ExecuteViewController : ChildViewController {
    
}

@objc public class ExecuteViewControllerImpl : NSViewController, ExecuteViewController {
    public var Parent : MasterViewController?
    
    @IBOutlet weak var appendButton: NSButton!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("Loaded ExecuteViewController")
    }
    
    public override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func onAppendClick(sender: NSButton) {
        log.debug("APPEND")
        
        if let workspace : QLKWorkspace = Parent!.QLabController.Workspace {
            if Parent!.CuesController.IsValid {
                let cues = Parent!.CuesController.Cues
                let connector = CueQLabConnector(workspace: workspace)
                connector.appendCues(cues) {
                    (uids : [String]) in
                    log.info("Created all \(uids.count) cues")
                    log.debug("With UIDs: \(uids)")
                }
            } else {
                log.error("Append error: Cues not valid")
            }
        } else {
            log.error("Append error: Not connected")
        }
    }
}