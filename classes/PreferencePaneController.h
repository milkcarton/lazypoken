//
//  PreferencePaneController.h
//  LazyPoken
//
//  Created by Jelle Vandebeeck on 24/01/09.
//  Copyright 2009 KBC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PreferencePanes/PreferencePanes.h>

@interface PreferencePaneController : NSPreferencePane {

}

// Action to start the launch service script.
- (IBAction)startLauchService:(id)sender;

@end
