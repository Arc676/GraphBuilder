//
//  GBView.m
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

#import "GBView.h"

#include "pathfinder.h"

@implementation GBView

std::list<Node*> nodes;

- (instancetype)init {
	self = [super init];
	if (self) {
		nodes = std::list<Node*>();
		_isPlacingNode = NO;
	}
	return self;
}

- (BOOL) acceptsFirstResponder {
	return YES;
}

- (void) newNode {
	self.isPlacingNode = YES;
}

- (void) newGraph {
	nodes.clear();
	[self setNeedsDisplay:YES];
}

- (void) drawRect:(NSRect)rect {
	[[NSColor whiteColor] set];
	NSRectFill(rect);
}

- (void) mouseUp:(NSEvent *)event {
	if (self.isPlacingNode) {
		self.isPlacingNode = NO;
	}
}

- (void) mouseMoved:(NSEvent *)event {
	if (self.isPlacingNode) {
		self.nodePos = [event locationInWindow];
	}
}

@end
