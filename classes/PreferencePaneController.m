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
	
	// Create the ResourcePath for the script to launch
	NSMutableString *scriptPath = [NSMutableString stringWithString:[[NSBundle bundleWithIdentifier:@"be.milkcarton.LazyPoken"] resourcePath]];
	[scriptPath appendString:@"/Script"];
	
	// Launch the script
	[serviceTask setLaunchPath:scriptPath];
	[serviceTask launch];
}

- (IBAction)stopLauchService:(id)sender
{
	[serviceTask interrupt];
}

@end
