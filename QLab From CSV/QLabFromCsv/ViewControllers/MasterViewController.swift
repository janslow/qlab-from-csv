//
//  TabViewControllerScene.swift
//  QLab From CSV
//
//  Created by Jay Anslow on 12/02/2015.
//  Copyright (c) 2015 Jay Anslow. All rights reserved.
//

import Foundation

@objc public protocol MasterViewController {
    var QLabController : QLabViewController { get }
    var CuesController : CuesViewController { get }
    
    func fireCheckValid()
    func append()
}

@objc public protocol ChildViewController {
    var Parent : MasterViewController? { get set }
}

@objc public class MasterViewControllerImpl : NSTabViewController, MasterViewController {
    @IBOutlet weak var qlabTab: NSTabViewItem!
    @IBOutlet weak var cuesTab: NSTabViewItem!
    @IBOutlet weak var executeTab: NSTabViewItem!
    
    required public init?(coder : NSCoder) {
        super.init(coder: coder)
        MAIN_VIEW_CONTROLLER = self
    }
    
    public var QLabController : QLabViewController {
        get {
            return qlabTab.viewController! as QLabViewController
        }
    }
    public var CuesController : CuesViewController {
        get {
            return cuesTab.viewController! as CuesViewController
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("Loaded MasterViewController")
        QLabController.Parent = self
        CuesController.Parent = self
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