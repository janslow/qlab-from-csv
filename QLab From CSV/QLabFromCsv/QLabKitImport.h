//
//  QLabKitImport.h
//  QLab From CSV
//
//  Created by Jay Anslow on 23/12/2014.
//  Copyright (c) 2014 Jay Anslow. All rights reserved.
//

#ifndef QLab_From_CSV_QLabKitImport_h
#define QLab_From_CSV_QLabKitImport_h

#import <QLabKitLibrary/QLabKitLibrary.h>

@interface QLabKitLibrary : NSObject <QLKBrowserDelegate>

@property (strong) QLKWorkspace *workspace;

@end

#endif
