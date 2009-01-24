//
//  LaunchController.h
//  LazyPoken
//
//  Created by Jelle Vandebeeck on 24/01/09.
//  Copyright 2009 KBC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LaunchController : NSObject {
}

// enter this method when a volume is mounted
- (void)didMountMethod:(NSNotification *)notification;

@end
