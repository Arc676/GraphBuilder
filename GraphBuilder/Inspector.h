//
//  Inspector.h
//  GraphBuilder
//
//  Created by Alessandro Vinciguerra on 01/01/2018.
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

@class ViewController;

@interface Inspector : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSTextField *nodeName;
@property (weak) IBOutlet NSTableView *connectionsTable;

@property (retain) NSDictionary* originalData;
@property (retain) NSMutableDictionary* nodeData;

@property (retain) ViewController* vc;

- (void) loadNodeData:(NSDictionary*)data;
- (void) reloadOriginalData;

- (IBAction)removeConnection:(id)sender;

- (IBAction)applyChanges:(id)sender;
- (IBAction)revertChanges:(id)sender;

@end
