//
//  LazyPokenLauncher.m
//  LazyPoken
//
//  Created by Jelle Vandebeeck on 24/01/09.
//  Copyright 2009 KBC. All rights reserved.
//

#import "SSYLoginItems/SSYLoginItems.h"
#import "LaunchController.h"

int main (int argc, const char * argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Initialize the LaunchController and sets the observers for the volume mount notifications.
	LaunchController *launchController = [[LaunchController alloc] init];
	// Create a loop to a date in the far future.
	while ([[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
	
	[launchController release], launchController = nil;
	[pool release], pool = nil;
	return 0;
}