//
//  ViewController.m
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

#import "ViewController.h"

@implementation ViewController

- (void) prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"InspectNodeSegue"]) {
		Inspector* inspector = (Inspector*)[[segue destinationController] contentViewController];
		[inspector loadNodeData:[self.gbView getSelectedNodeData]];
	}
}

- (void) loadModifiedNodeData:(NSDictionary *)data forNode:(NSString *)node {
	[self.gbView loadModifiedNodeData:data forNode:node];
}

- (void) newNode {
	[self.gbView newNode];
}

- (void) newGraph {
	self.graphHasBeenSaved = NO;
	self.lastURL = nil;
	[self.gbView newGraph];
}

- (void) loadGraph {
	NSOpenPanel* panel = [NSOpenPanel openPanel];
	if ([panel runModal] == NSModalResponseOK) {
		if (![self.gbView loadGraphFrom:[panel URL]]) {
			NSAlert* alert = [[NSAlert alloc] init];
			[alert setMessageText:@"Error"];
			[alert setInformativeText:@"Failed to load graph data"];
			[alert runModal];
		} else {
			self.graphHasBeenSaved = YES;
			self.lastURL = [panel URL];
		}
	}
}

- (void) saveGraph {
	if (self.graphHasBeenSaved) {
		self.graphHasBeenSaved = [self.gbView writeGraphTo:self.lastURL];
	} else {
		[self saveGraphAs];
	}
}

- (void) saveGraphAs {
	NSSavePanel* panel = [NSSavePanel savePanel];
	if ([panel runModal] == NSModalResponseOK) {
		self.lastURL = [panel URL];
		self.graphHasBeenSaved = [self.gbView writeGraphTo:[panel URL]];
	}
}

- (IBAction)connectNode:(id)sender {
	[self.gbView connectNode];
}

- (IBAction)deleteNode:(id)sender {
	[self.gbView deleteSelectedNode];
}

- (IBAction)runDijkstra:(id)sender {
	[self.gbView pathFind:DIJKSTRA];
}

- (IBAction)clearPath:(id)sender {
	[self.gbView clearPath];
}

@end
