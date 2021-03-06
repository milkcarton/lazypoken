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

#import <Cocoa/Cocoa.h>
#import <Sparkle/Sparkle.h>
#import <PreferencePanes/PreferencePanes.h>
#import "LPGlobalVariables.h"
#import "AGProcess.h"
#import "SSYLoginItems.h"

@interface LPPreferencePaneController : NSPreferencePane {
	@private NSTask *serviceTask;
	@private NSNumber *launchOnStartup;
	@private NSImage *runningImage;
	@private NSImage *stoppedImage;
	
	IBOutlet NSImageView *handImage;
	IBOutlet NSTextField *titleText;
	IBOutlet NSTextField *descriptionText;
	IBOutlet NSButton *startButton;
	IBOutlet NSButton *startupCheckbox;
}

// The button decides to start or stop the LazyPoken agent
- (IBAction)startStopAgent:(id)sender;

// Action to start the launch service script.
- (void)startLauchService;

// Action to stop the launch service script.
- (void)stopLauchService;

// Returns true when LazyPoken for this user is running, false if not
- (BOOL)isRunning;

// Changes the interface fields (YES = show the started state, NO = show the stoped state)
- (void)runningInterface:(BOOL)running;

// Reads the user "start automatically" default from the LPBundleIdentifier instead of the com.apple.systempreferences
- (BOOL)getLaunchOnStartup;

// Writes the user "start automatically" default to the LPBundleIdentifier instead of the com.apple.systempreferences
- (IBAction)setlaunchOnStartup:(id)sender;

// Reads the defaults version number from the LPBundleIdentifier instead of the com.apple.systempreferences
// This is used to check if we need to reload the running script after an update
- (NSString *)getRunningVersion;

@end
