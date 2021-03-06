/*
 Copyright (c) 2009 Jelle Vandebeeck, Simon Schoeters
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 Created by Jelle Vandebeeck on 2009.01.25.
*/

#import "LPLaunchController.h"

@implementation LPLaunchController

- (id)init
{
	[super init];
	[self setRunningVersion];
	NSNotificationCenter *notificationCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
	SEL didMountMethod = @selector(didMountMethod:);
	
	// Add the observer for the volume mount notification.
	[notificationCenter addObserver:self selector:didMountMethod name:NSWorkspaceDidMountNotification object:nil];
	
	return self;
}

- (void)didMountMethod:(NSNotification *)notification
{
	CFBooleanRef userIsActive; 
	CFDictionaryRef sessionInfoDict; 
	sessionInfoDict = CGSessionCopyCurrentDictionary(); 
	userIsActive = CFDictionaryGetValue(sessionInfoDict, kCGSessionOnConsoleKey); 
	
	NSString *path = [[notification userInfo] valueForKey:@"NSDevicePath"];
	if (CFBooleanGetValue(userIsActive) && [path compare:LPVolumeName] == NSOrderedSame) {
		NSLog(@"Poken volume mounted");
		NSURL *file = [NSURL fileURLWithPath:@"/Volumes/POKEN/Start_Poken.html"];
		if ([[NSWorkspace sharedWorkspace] openURL:file]) {
			NSLog(@"Opened the Poken webpage");
		}
	}
}

- (void)setRunningVersion
{
	CFStringRef version = (CFStringRef)[[[NSBundle bundleForClass:[self class]] infoDictionary] valueForKey:@"CFBundleVersion"];
	CFStringRef key = CFSTR("LPRunningVersion");
	CFStringRef bundleID = (CFStringRef)LPBundleIdentifier;
	CFPreferencesSetAppValue(key, version, bundleID);
	CFPreferencesAppSynchronize(bundleID);
}

@end
