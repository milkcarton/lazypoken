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
	[serviceTask setLaunchPath:@"/Users/Jelle/Documents/Application Development/LazyPoken/build/Debug/Script"];
	[serviceTask launch];
}

- (IBAction)stopLauchService:(id)sender
{
	[serviceTask interrupt];
}

@end
