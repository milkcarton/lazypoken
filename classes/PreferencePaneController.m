//
//  PreferencePaneController.m
//  LazyPoken
//
//  Created by Jelle Vandebeeck on 24/01/09.
//  Copyright 2009 KBC. All rights reserved.
//

#import "PreferencePaneController.h"

@implementation PreferencePaneController

- (IBAction)startLauchService:(id)sender
{
	serviceTask = [[NSTask alloc] init];
	
	
	NSLog(@"Prt");
	
	// Create the ResourcePath for the script to launch
	NSMutableString *scriptPath = [NSMutableString stringWithString:[[NSBundle bundleWithIdentifier:LPBundleIdentifier] resourcePath]];
	[scriptPath appendString:@"/"];
	[scriptPath appendString:LPScriptName];
	
	// Launch the script
	[serviceTask setLaunchPath:scriptPath];
	[serviceTask launch];
}

- (IBAction)stopLauchService:(id)sender
{
	[serviceTask interrupt];
}

@end
