//
//  ViewController.h
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

#import "GBView.h"
#import "Inspector.h"

@interface ViewController : NSViewController

@property (strong) IBOutlet GBView *gbView;

@property (assign) BOOL graphHasBeenSaved;
@property (retain) NSURL* lastURL;

- (IBAction)connectNode:(id)sender;
- (IBAction)deleteNode:(id)sender;

- (IBAction)runDijkstra:(id)sender;
- (IBAction)clearPath:(id)sender;

- (void) newNode;
- (void) newGraph;

- (void) loadGraph;
- (void) loadPlainTextGraph;
- (void) loadModifiedNodeData:(NSDictionary*)data forNode:(NSString*)node;

- (void) saveGraph;
- (void) saveGraphAs;
- (void) exportGraphAsText;

- (void) setWeightVisibility:(BOOL)visible;

- (void) showGraphWeight;

@end
