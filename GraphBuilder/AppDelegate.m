//
//  AppDelegate.m
//  GraphBuilder
//
//  Created by Alessandro Vinciguerra on 28/12/2017.
//      <alesvinciguerra@gmail.com>
//Copyright (C) 2017-2018 Arc676/Alessandro Vinciguerra

//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation (version 3)

//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.

//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.
//See README and LICENSE for more details

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[NSApp.mainWindow setAcceptsMouseMovedEvents:YES];
	_viewController = (ViewController*)NSApp.mainWindow.contentViewController;
}

- (IBAction)newNode:(id)sender {
	[self.viewController newNode];
}

- (IBAction)newGraph:(id)sender {
	[self.viewController newGraph];
}

- (IBAction)openGraph:(id)sender {
	[self.viewController loadGraph];
}

- (IBAction)openPlainTextGraph:(id)sender {
	[self.viewController loadPlainTextGraph];
}

- (IBAction)saveGraph:(id)sender {
	[self.viewController saveGraph];
}

- (IBAction)saveGraphAs:(id)sender {
	[self.viewController saveGraphAs];
}

- (IBAction)exportGraphToText:(id)sender {
	[self.viewController exportGraphAsText];
}

- (IBAction)showWeights:(id)sender {
	[self.viewController setWeightVisibility:YES];
}

- (IBAction)hideWeights:(id)sender {
	[self.viewController setWeightVisibility:NO];
}

- (IBAction)showNames:(id)sender {
	[self.viewController setNodeNameVisibility:YES];
}

- (IBAction)hideNames:(id)sender {
	[self.viewController setNodeNameVisibility:NO];
}

- (IBAction)showTotalWeight:(id)sender {
	[self.viewController showGraphWeight];
}

- (IBAction)generateMST:(id)sender {
	[self.viewController generateMST];
}

@end
