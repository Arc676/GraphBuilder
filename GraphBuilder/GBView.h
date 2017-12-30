//
//  GBView.h
//  GraphBuilder
//
//  Created by Alessandro Vinciguerra on 28/12/2017.
//      <alesvinciguerra@gmail.com>
//Copyright (C) 2017 Arc676/Alessandro Vinciguerra

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

#import "Enums.h"

@interface GBView : NSView

@property (retain) NSMutableDictionary* nodePositions;
@property (assign) int nextNode;

@property (assign) State currentState;

@property (assign) PathfindAlgo desiredAlgo;
@property (assign) BOOL hasPath;

@property (retain) NSString* activeNodeName;
@property (assign) NSPoint selectedNodePos;
@property (assign) NSPoint activeNodePos;

- (void) mouseUpdate:(NSEvent*)event shouldUpdate:(BOOL)condition;

- (NSRect) rectForOvalAroundPoint:(NSPoint)point;
- (NSString*) getNodeAt:(NSPoint)point;
- (void) loadNodeAt:(NSPoint)point newState:(State)state;

- (void) newNode;
- (void) newGraph;

- (BOOL) loadGraphFrom:(NSURL*)url;
- (BOOL) writeGraphTo:(NSURL*)url;

- (void) clearState;

- (void) connectNode;
- (void) deleteSelectedNode;
- (void) pathFind:(PathfindAlgo)algo;

@end
