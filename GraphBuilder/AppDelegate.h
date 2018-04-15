//
//  AppDelegate.h
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

#import <Cocoa/Cocoa.h>
#include "ViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (retain) ViewController* viewController;

- (IBAction)newNode:(id)sender;
- (IBAction)newGraph:(id)sender;

- (IBAction)openGraph:(id)sender;
- (IBAction)openPlainTextGraph:(id)sender;

- (IBAction)saveGraph:(id)sender;
- (IBAction)saveGraphAs:(id)sender;
- (IBAction)exportGraphToText:(id)sender;

- (IBAction)showWeights:(id)sender;
- (IBAction)hideWeights:(id)sender;

- (IBAction)showTotalWeight:(id)sender;

- (IBAction)generateMST:(id)sender;

@end
