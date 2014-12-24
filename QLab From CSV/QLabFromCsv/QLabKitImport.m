////
////  QLabKitImport.m
////  QLab From CSV
////
////  Created by Jay Anslow on 21/12/2014.
////  Copyright (c) 2014 Jay Anslow. All rights reserved.
////
//#import <Foundation/Foundation.h>
//#import <QLabKit.objc/lib/QLKServer.h>
//
//#define QLAB_IP @"localhost"
//#define QLAB_PORT 53000
//
//@interface QLKAppDelegate ()
//
//@property (strong) QLKBrowser *browser;
//
//@end
//
//@implementation QLKAppDelegate
//
//- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
//{
//    // Manual connect to server and get workspaces
//    QLKServer *server = [[QLKServer alloc] initWithHost:QLAB_IP port:QLAB_PORT];
//    server.name = @"QLab";
//    [server refreshWorkspacesWithCompletion:^(NSArray *workspaces)
//     {
//         printf("refreshWorspacesWithCompletion");
//     }];
//}
//
//
//#pragma mark - QLKBrowserDelegate
//
//- (void) browserDidUpdateServers:(QLKBrowser *)browser
//{
//    [self updateView];
//}
//
//- (void) serverDidUpdateWorkspaces:(QLKServer *)server
//{
//    [self updateView];
//}
//
//#pragma mark - NSTableViewDelegate
//
//- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
//{
//    return (tableView == self.serversTableView) ? self.rows.count : [[self.workspace.firstCueList propertyForKey:QLKOSCCuesKey] count];
//}
//
//- (NSView *) tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
//{
//    NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
//    
//    if ( tableView == self.serversTableView )
//    {
//        id obj = self.rows[row];
//        cellView.textField.stringValue = ([obj isKindOfClass:[QLKServer class]]) ? [(QLKServer *)obj name].uppercaseString : [(QLKWorkspace *)obj name];
//    }
//    else
//    {
//        QLKCue *fql = [self.workspace firstCueList];
//        NSArray *cues = [fql propertyForKey:QLKOSCCuesKey];
//        QLKCue *cue = cues[row];
//        
//        cellView.textField.stringValue = ([tableColumn.identifier isEqualToString:QLKOSCNumberKey]) ? cue.number : [cue displayName];
//    }
//    
//    return cellView;
//}
//
//- (BOOL) tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row
//{
//    return (tableView == self.serversTableView) ? [self.rows[row] isKindOfClass:[QLKServer class]] : NO;
//}
//
//- (BOOL) tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
//{
//    return ![self tableView:tableView isGroupRow:row];
//}
//
//#pragma mark - NSSplitViewDelegate
//
//- (BOOL) splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view
//{
//    return (splitView.subviews[0] != view);
//}
//
//@end