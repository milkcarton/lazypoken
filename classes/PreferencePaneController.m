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

#import "PreferencePaneController.h"

@implementation PreferencePaneController

- (void)awakeFromNib
{	
	SUUpdater *updater = [SUUpdater updaterForBundle:[NSBundle bundleWithIdentifier:LPBundleIdentifier]];
	[updater setAutomaticallyChecksForUpdates:YES];
	[updater resetUpdateCycle];
	
	launchOnStartup = [NSNumber numberWithInt:[self getLaunchOnStartup]];
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

- (BOOL)getLaunchOnStartup
{
	BOOL value = YES;
	CFStringRef key = CFSTR("LPLaunchOnStartup");
	CFStringRef bundleID = (CFStringRef)LPBundleIdentifier;
	CFPropertyListRef ref = CFPreferencesCopyAppValue(key, bundleID);

	if(ref && CFGetTypeID(ref) == CFBooleanGetTypeID()) {
		value = CFBooleanGetValue(ref);
	}

	if(ref) {
		CFRelease(ref);
	}

	return value;
}

- (IBAction)setlaunchOnStartup:(id)sender
{	
	CFStringRef key = CFSTR("LPLaunchOnStartup");
	BOOL value = (BOOL)[sender state];
	CFStringRef bundleID = (CFStringRef)LPBundleIdentifier;
	CFPreferencesSetAppValue(key, value ? kCFBooleanTrue : kCFBooleanFalse, bundleID);
    CFPreferencesAppSynchronize(bundleID);
}

@end
