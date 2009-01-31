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

#import "LPPreferencePaneController.h"

@implementation LPPreferencePaneController

- (void)willSelect
{	
	NSString *thisVersion = [[[NSBundle bundleWithIdentifier:LPBundleIdentifier] infoDictionary] valueForKey:@"CFBundleVersion"];
	if ([[self getRunningVersion] caseInsensitiveCompare:thisVersion] != 0 && [self isRunning]) {
		// This is an update, set the new value and restart the agent
		NSLog(@"Update found, restarting the LazyPoken agent");
		[self setRunningVersion];
		[self stopLauchService];
		[self startLauchService];
		[self runningInterface:YES];
	}
	
	
	// Find the different status images
	NSString* tmp = [[NSBundle bundleForClass:[self class]] pathForResource:@"hand64running" ofType:@"png"];
	runningImage = [[NSImage alloc] initWithContentsOfFile:tmp];
	tmp = [[NSBundle bundleForClass:[self class]] pathForResource:@"hand64stopped" ofType:@"png"];
	stoppedImage = [[NSImage alloc] initWithContentsOfFile:tmp];
	
	SUUpdater *updater = [SUUpdater updaterForBundle:[NSBundle bundleWithIdentifier:LPBundleIdentifier]];
	[updater setAutomaticallyChecksForUpdates:YES];
	[updater resetUpdateCycle];
	
	launchOnStartup = [NSNumber numberWithInt:[self getLaunchOnStartup]];
	[startupCheckbox setState:[launchOnStartup intValue]];
	
	[self runningInterface:[self isRunning]];
}

- (void)runningInterface:(BOOL)running
{
	if (running) {
		[handImage setImage:runningImage];
		[startButton setTitle:MCLocalizedString(@"STOP_LAZYPOKEN")];
		[titleText setStringValue:MCLocalizedString(@"LAZYPOKEN_STATUS")];
		[descriptionText setStringValue:MCLocalizedString(@"STOP_DESCRIPTION")];
		[startupCheckbox setTitle:MCLocalizedString(@"START_AT_STARTUP")];		
	} else {
		[handImage setImage:stoppedImage];
		[startButton setTitle:MCLocalizedString(@"START_LAZYPOKEN")];
		[titleText setStringValue:MCLocalizedString(@"LAZYPOKEN_STATUS")];
		[descriptionText setStringValue:MCLocalizedString(@"START_DESCRIPTION")];
		[startupCheckbox setTitle:MCLocalizedString(@"START_AT_STARTUP")];
	}
}

- (IBAction)startStopAgent:(id)sender
{
	if ([self isRunning]) {
		[self stopLauchService];
		[self runningInterface:NO];
	} else {
		[self startLauchService];
		[self runningInterface:YES];
	}
}

- (void)startLauchService
{
	serviceTask = [[NSTask alloc] init];
	
	// Create the ResourcePath for the script to launch
	NSMutableString *scriptPath = [NSMutableString stringWithString:[[NSBundle bundleWithIdentifier:LPBundleIdentifier] resourcePath]];
	[scriptPath appendString:@"/"];
	[scriptPath appendString:LPScriptName];
	
	// Launch the script and save the process id
	[serviceTask setLaunchPath:scriptPath];
	
	NSMutableDictionary *environment = [NSMutableDictionary dictionaryWithDictionary:[serviceTask environment]];
    [environment setObject:@"" forKey:LPBUndleTag];
    [serviceTask setEnvironment:environment];

	[serviceTask launch];
	[self setRunningVersion];
	NSLog(@"Started the LazyPoken agent");
}

- (void)stopLauchService
{
	NSEnumerator *processEnumerator = [[AGProcess userProcesses] objectEnumerator];
	AGProcess *process = nil;
    
	while (process = [processEnumerator nextObject]) {
		if ([LPScriptName isEqualToString:[process command]]) {
			NSDictionary *environment = [process environment];
			if ([environment valueForKey:LPBUndleTag]) {
                if ([process terminate]) {
                    NSLog(@"Stoped the LazyPoken agent");
                } else {
					NSLog(@"Failed to stop the LazyPoken agent");
                }
            }
        }
    }
}

- (BOOL)isRunning
{
	BOOL isRunning = FALSE;
	NSEnumerator *processEnumerator = [[AGProcess userProcesses] objectEnumerator];
	AGProcess *process = nil;
    
	while (process = [processEnumerator nextObject]) {
		if ([LPScriptName isEqualToString:[process command]]) {
			NSDictionary *environment = [process environment];
			if ([environment valueForKey:LPBUndleTag]) {
				isRunning = TRUE;
            }
        }
    }
	return isRunning;
}

- (BOOL)getLaunchOnStartup
{
	NSNumber *loginItem = nil;
	NSNumber *hidden = nil;
	NSError *error = nil;
	NSMutableString *scriptPath = [NSMutableString stringWithString:[[NSBundle bundleWithIdentifier:LPBundleIdentifier] resourcePath]];
	[scriptPath appendString:@"/"];
	[scriptPath appendString:LPScriptName];
	BOOL ok = [SSYLoginItems isURL:[NSURL fileURLWithPath:scriptPath] loginItem:&loginItem hidden:&hidden error:&error];
	
	if (ok && [loginItem boolValue]) {
		return TRUE;
	}
	return FALSE;
}

- (IBAction)setlaunchOnStartup:(id)sender
{
	NSError *error = nil;
	NSMutableString *scriptPath = [NSMutableString stringWithString:[[NSBundle bundleWithIdentifier:LPBundleIdentifier] resourcePath]];
	[scriptPath appendString:@"/"];
	[scriptPath appendString:LPScriptName];
	
	if ([sender state]) {
		[SSYLoginItems addLoginURL:[NSURL fileURLWithPath:scriptPath] hidden:[NSNumber numberWithBool:TRUE] error:&error];
	} else {
		[SSYLoginItems removeLoginURL:[NSURL fileURLWithPath:scriptPath] error:&error];
	}
	
	if (error != nil) {
		NSLog(@"LazyPoken Startup Error: %@", [error description]);
	}
}

- (NSString *)getRunningVersion 
{
	NSString *version = @""; // default value if not found
	CFStringRef key = CFSTR("LPRunningVersion");
	CFStringRef bundleID = (CFStringRef)LPBundleIdentifier;
	CFPropertyListRef ref = CFPreferencesCopyAppValue(key, bundleID);
		
	if(ref && CFGetTypeID(ref) == CFStringGetTypeID())
		version = (NSString*)ref;
	
	if(ref)
		CFRelease(ref);
		
	return version;
}

- (void)setRunningVersion
{
	CFStringRef version = (CFStringRef)[[[NSBundle bundleWithIdentifier:LPBundleIdentifier] infoDictionary] valueForKey:@"CFBundleVersion"];
	CFStringRef key = CFSTR("LPRunningVersion");
	CFStringRef bundleID = (CFStringRef)LPBundleIdentifier;
	CFPreferencesSetAppValue(key, version, bundleID);
	CFPreferencesAppSynchronize(bundleID);
}

@end
