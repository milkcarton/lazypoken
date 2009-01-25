//
//  PreferencePaneController.m
//  LazyPoken
//
//  Created by Jelle Vandebeeck on 24/01/09.
//  Copyright 2009 KBC. All rights reserved.
//

#import "PreferencePaneController.h"

@implementation PreferencePaneController

- (void)awakeFromNib
{	
	launchOnStartup = [[NSUserDefaults standardUserDefaults] objectForKey:@"LPLaunchOnStartup"];
	if (launchOnStartup == nil) {
		launchOnStartup = [NSNumber numberWithInt:YES];
	}
	[startupCheckbox setState:[launchOnStartup intValue]];
}


- (IBAction)startLauchService:(id)sender
{
	serviceTask = [[NSTask alloc] init];
	
	// Create the ResourcePath for the script to launch
	NSMutableString *scriptPath = [NSMutableString stringWithString:[[NSBundle bundleWithIdentifier:LPBundleIdentifier] resourcePath]];
	[scriptPath appendString:@"/"];
	[scriptPath appendString:LPScriptName];
	
	// Launch the script
	[serviceTask setLaunchPath:scriptPath];
	[serviceTask launch];
	
	// Change the interface
	[startButton setTitle:@"Stop LazyPoken"];
	[statusText setStringValue:@"running"];
	[statusText setTextColor:[NSColor colorWithCalibratedRed:0.42 green:0.71 blue:0.26 alpha:1]]; 
}

- (IBAction)stopLauchService:(id)sender
{
	[serviceTask interrupt];
	
	// Change the interface
	[startButton setTitle:@"Start LazyPoken"];
	[statusText setStringValue:@"stopped"];
	[statusText setTextColor:[NSColor redColor]]; 
}

@end
