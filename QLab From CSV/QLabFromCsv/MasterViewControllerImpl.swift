//
//  MasterViewControllerImpl.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 2015-04-21.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

public class MasterViewControllerImpl : NSTabViewController, MasterViewController {
    @IBOutlet weak var qlabTab: NSTabViewItem!
    @IBOutlet weak var cuesTab: NSTabViewItem!
    @IBOutlet weak var executeTab: NSTabViewItem!
    
    required public init?(coder : NSCoder) {
        super.init(coder: coder)
        MAIN_VIEW_CONTROLLER = self
    }
    
    public var QLabController : QLabViewController {
        get {
            return qlabTab.viewController! as! QLabViewController
        }
    }
    public var CuesController : CuesViewController {
        get {
            return cuesTab.viewController! as! CuesViewController
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("Loaded MasterViewController")
    }
    
    public override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    public func fireCheckValid() {
        APP_DELEGATE?.setIsRunAllowed(QLabController.IsConnected && CuesController.IsValid)
    }
    
    public func append() {
        if QLabController.IsConnected && CuesController.IsValid {
            let connector = CueQLabConnector(workspace: QLabController.Workspace!)
            log.info("Appending cues.")
            connector.appendCues(CuesController.Cues) {
                (uids : [String]) in
                log.info("Appended \(uids.count) cues.")
            }
        }
    }
    
}