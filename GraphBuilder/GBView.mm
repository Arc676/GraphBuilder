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
Node* selectedNode;

- (void) awakeFromNib {
	_nodePositions = [NSMutableDictionary dictionary];
	graph = new Graph("");

	_currentState = IDLE;
	_activeNodeName = @"";
	[super awakeFromNib];
}

- (BOOL) acceptsFirstResponder {
	return YES;
}

- (void) clearState {
	self.currentState = IDLE;
	self.activeNodeName = @"";
	selectedNode = nullptr;
}

- (void) newNode {
	self.currentState = PLACING;
}

- (void) newGraph {
	delete graph;
	graph = new Graph("");
	[self.nodePositions removeAllObjects];
	[self setNeedsDisplay:YES];
}

- (void) connectNode {
	self.currentState = CONNECTING;
}

- (void) deleteSelectedNode {
	graph->removeNode(selectedNode);
	[self.nodePositions removeObjectForKey:[NSString stringWithCString:selectedNode->getName().c_str() encoding:NSUTF8StringEncoding]];
	[self clearState];
}

- (void) pathFind:(PathfindAlgo)algo {
	//
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

		NSBezierPath* path = [NSBezierPath bezierPathWithOvalInRect:
							  [self rectForOvalAroundPoint:pos]];

		if ([name isEqualToString:self.activeNodeName]) {
			if (self.currentState & SELECTED) {
				[[NSColor blackColor] set];
				[path stroke];
			} else {
				[[NSColor darkGrayColor] set];
				[path fill];
			}
		} else {
			[[NSColor blackColor] set];
			[path fill];
		}

		std::map<std::string, float> adjacentNodes = it->second->getAdjacentNodes();
		for (std::map<std::string, float>::iterator it = adjacentNodes.begin(); it != adjacentNodes.end(); it++) {
			[path removeAllPoints];

			NSString* name2 = [NSString stringWithCString:it->first.c_str() encoding:NSUTF8StringEncoding];
			NSPoint pos2 = NSPointFromString(self.nodePositions[name2]);

			[path moveToPoint:pos];
			[path lineToPoint:pos2];
			[path stroke];
		}
	}

	if (self.currentState & (PLACING | DRAGGING)) {
		[[NSColor grayColor] set];
		NSBezierPath* path = [NSBezierPath bezierPathWithOvalInRect:
							  [self rectForOvalAroundPoint:self.activeNodePos]];
		[path fill];
	}
}

- (NSString*) getNodeAt:(NSPoint)point {
	__block BOOL nodeFound = NO;
	__block NSString* name = @"";
	[self.nodePositions enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* obj, BOOL* stop) {
		NSPoint pos = NSPointFromString(obj);
		if (hypot(pos.x - point.x, pos.y - point.y) <= 10) {
			nodeFound = YES;
			name = key;
			*stop = YES;
		}
	}];
	return name;
}

- (void) loadNodeAt:(NSPoint)point newState:(State)state {
	if (self.currentState == IDLE) {
		NSString* node = [self getNodeAt:point];
		if (![node isEqualToString:@""]) {
			self.activeNodeName = node;
			self.currentState = state;
			[self setNeedsDisplay:YES];
		}
	}
}

- (void) rightMouseDown:(NSEvent *)event {
	[self loadNodeAt:[event locationInWindow] newState:IDLE];
	if (![self.activeNodeName isEqualToString:@""]) {
		selectedNode = graph->getNodes().at([self.activeNodeName cStringUsingEncoding:NSUTF8StringEncoding]);
		[super rightMouseDown:event];
	}
}

- (void) mouseDown:(NSEvent *)event {
	[self loadNodeAt:[event locationInWindow] newState:DRAGGING];
}

- (void) mouseUp:(NSEvent *)event {
	if (self.currentState & (PLACING | DRAGGING)) {
		NSString* newPos = [NSString stringWithFormat:@"%f %f", self.activeNodePos.x, self.activeNodePos.y];
		if (self.currentState == PLACING) {
			NSString* name = [NSString stringWithFormat:@"%lu", self.nodePositions.count];
			self.nodePositions[name] = newPos;

			Node* node = new Node([name cStringUsingEncoding:NSUTF8StringEncoding]);
			graph->addNode(node);
		} else {
			self.nodePositions[self.activeNodeName] = newPos;
		}
	} else if (self.currentState == CONNECTING) {
		NSString* node2 = [self getNodeAt:[event locationInWindow]];
		if (![node2 isEqualToString:@""]) {
			Node* otherNode = graph->getNodes().at([node2 cStringUsingEncoding:NSUTF8StringEncoding]);
			if (selectedNode->getAdjacentNodes().count(otherNode->getName()) == 0 &&
				otherNode->getAdjacentNodes().count(selectedNode->getName()) == 0) {
				selectedNode->addAdjacentNode(otherNode, 1);
				otherNode->addAdjacentNode(selectedNode, 1);
			}
		}
	}
	[self clearState];
	[self setNeedsDisplay:YES];
}

- (void) mouseUpdate:(NSEvent *)event shouldUpdate:(BOOL)condition {
	if (condition) {
		self.activeNodePos = [event locationInWindow];
		[self setNeedsDisplay:YES];
	}
}

- (void) mouseDragged:(NSEvent *)event {
	[self mouseUpdate:event shouldUpdate:(self.currentState == DRAGGING)];
}

- (void) mouseMoved:(NSEvent *)event {
	[self mouseUpdate:event shouldUpdate:(self.currentState == PLACING)];
}

@end
