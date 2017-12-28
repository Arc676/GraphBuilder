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

Graph* graph;

- (void) awakeFromNib {
	_nodePositions = [NSMutableDictionary dictionary];
	graph = new Graph("");

	_isPlacingNode = NO;
	[super awakeFromNib];
}

- (BOOL) acceptsFirstResponder {
	return YES;
}

- (void) newNode {
	self.isPlacingNode = YES;
}

- (void) newGraph {
	delete graph;
	graph = new Graph("");
	[self.nodePositions removeAllObjects];
	[self setNeedsDisplay:YES];
}

- (NSRect) rectForOvalAroundPoint:(NSPoint)point {
	return NSMakeRect(point.x - 10, point.y - 10, 20, 20);
}

- (void) drawRect:(NSRect)rect {
	[[NSColor whiteColor] set];
	NSRectFill(rect);

	[[NSColor blackColor] set];
	std::map<std::string, Node*> nodes = graph->getNodes();
	for (std::map<std::string, Node*>::iterator it = nodes.begin(); it != nodes.end(); it++) {
		NSString* name = [NSString stringWithCString:it->first.c_str() encoding:NSUTF8StringEncoding];
		NSPoint pos = NSPointFromString(self.nodePositions[name]);

		if ([name isEqualToString:self.activeNodeName]) {
			[[NSColor darkGrayColor] set];
		} else {
			[[NSColor blackColor] set];
		}

		NSBezierPath* path = [NSBezierPath bezierPathWithOvalInRect:
							  [self rectForOvalAroundPoint:pos]];
		[path fill];
	}

	if (self.isPlacingNode || self.isDraggingNode) {
		[[NSColor grayColor] set];
		NSBezierPath* path = [NSBezierPath bezierPathWithOvalInRect:
							  [self rectForOvalAroundPoint:self.activeNodePos]];
		[path fill];
	}
}

- (void) mouseDown:(NSEvent *)event {
	if (!self.isPlacingNode) {
		__block BOOL nodeFound = NO;
		__block NSString* node = @"";
		NSPoint mouse = [event locationInWindow];
		CGFloat x = mouse.x, y = mouse.y;
		[self.nodePositions enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* obj, BOOL* stop) {
			NSPoint pos = NSPointFromString(obj);
			if (hypot(pos.x - x, pos.y - y) <= 10) {
				nodeFound = YES;
				node = key;
				*stop = YES;
			}
		}];
		if (nodeFound) {
			self.isDraggingNode = YES;
			self.activeNodeName = node;
		}
	}
}

- (void) mouseUp:(NSEvent *)event {
	if (self.isPlacingNode || self.isDraggingNode) {
		NSString* newPos = [NSString stringWithFormat:@"%f %f", self.activeNodePos.x, self.activeNodePos.y];
		if (self.isPlacingNode) {
			self.isPlacingNode = NO;

			NSString* name = [NSString stringWithFormat:@"%lu", (unsigned long)self.nodePositions.count];
			self.nodePositions[name] = newPos;

			Node* node = new Node([name cStringUsingEncoding:NSUTF8StringEncoding]);
			graph->addNode(node);
		} else {
			self.isDraggingNode = NO;

			self.nodePositions[self.activeNodeName] = newPos;
			self.activeNodeName = @"";
		}
		[self setNeedsDisplay:YES];
	}
}

- (void) mouseUpdate:(NSEvent *)event shouldUpdate:(BOOL)condition {
	if (condition) {
		self.activeNodePos = [event locationInWindow];
		[self setNeedsDisplay:YES];
	}
}

- (void) mouseDragged:(NSEvent *)event {
	[self mouseUpdate:event shouldUpdate:self.isDraggingNode];
}

- (void) mouseMoved:(NSEvent *)event {
	[self mouseUpdate:event shouldUpdate:self.isPlacingNode];
}

@end
