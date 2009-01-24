//
//  LaunchController.m
//  LazyPoken
//
//  Created by Jelle Vandebeeck on 24/01/09.
//  Copyright 2009 KBC. All rights reserved.
//

#import "LaunchController.h"

@implementation LaunchController

- (id)init
{
	[super init];
	
	NSNotificationCenter *notificationCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
	SEL didMountMethod = @selector(didMountMethod:);
	
	// Add the observer for the volume mount notification.
	[notificationCenter addObserver:self selector:didMountMethod name:NSWorkspaceDidMountNotification object:nil];
	
	return self;
}

- (void)didMountMethod:(NSNotification *)notification
{
	NSLog(@"volume mounted: %@", [notification userInfo]);
}

@end
