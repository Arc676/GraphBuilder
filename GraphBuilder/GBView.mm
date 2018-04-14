//
//  GBView.m
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

#import "GBView.h"

#include "pathfinder.h"

@implementation GBView

Graph* graph;
Node* selectedNode;
std::list<Node*> pathNodes;

- (void) awakeFromNib {
	_nodePositions = [NSMutableDictionary dictionary];
	graph = new Graph();

	_currentState = IDLE;

	_desiredAlgo = DIJKSTRA;
	_hasPath = NO;

	_showWeights = YES;

	_activeNodeName = @"";
	[super awakeFromNib];
}

- (BOOL) acceptsFirstResponder {
	return YES;
}

- (NSDictionary*) getSelectedNodeData {
	NSMutableDictionary* connections = [NSMutableDictionary dictionary];
	std::map<std::string, float> adjacent = selectedNode->getAdjacentNodes();
	for (std::map<std::string, float>::iterator it = adjacent.begin(); it != adjacent.end(); it++) {
		connections[[NSString stringWithCString:it->first.c_str()
									   encoding:NSUTF8StringEncoding]] = [NSNumber numberWithFloat:it->second];
	}
	return @{
			 @"Name" : [NSString stringWithCString:selectedNode->getName().c_str() encoding:NSUTF8StringEncoding],
			 @"Connections" : connections
			 };
}

- (void) loadModifiedNodeData:(NSDictionary *)data forNode:(NSString *)node {
	NSString* nodeName = data[@"Name"];
	std::string newName = [nodeName cStringUsingEncoding:NSUTF8StringEncoding];
	std::string originalName = [node cStringUsingEncoding:NSUTF8StringEncoding];

	NSString* pos = self.nodePositions[node];
	[self.nodePositions removeObjectForKey:node];
	self.nodePositions[nodeName] = pos;

	Node* modifiedNode = graph->getNodes()[originalName];
	graph->renameNode(modifiedNode, newName);

	__block std::map<std::string, float> adjacent = modifiedNode->getAdjacentNodes();
	[data[@"Connections"] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSNumber* dist, BOOL* stop) {
		std::string node = [key cStringUsingEncoding:NSUTF8StringEncoding];
		float nodeDist = [dist floatValue];
		if (adjacent[node] != nodeDist) {
			modifiedNode->addAdjacentNodeByName(node, nodeDist);
		}
	}];
	[self clearState];
}

- (void) clearState {
	self.currentState = IDLE;
	self.activeNodeName = @"";
	selectedNode = nullptr;
	[self setNeedsDisplay:YES];
}

- (void) newNode {
	self.currentState = PLACING;
}

- (void) newGraph {
	delete graph;
	graph = new Graph();
	[self.nodePositions removeAllObjects];
	[self setNeedsDisplay:YES];
}

- (BOOL) loadGraphFrom:(NSURL *)url {
	NSDictionary* dict = [NSDictionary dictionaryWithContentsOfURL:url];
	if (dict) {
		graph = new Graph();
		self.nodePositions = dict[@"NodePositions"];
		NSString* data = dict[@"GraphData"];
		if (data && self.nodePositions) {
			for (NSString* node in [data componentsSeparatedByString:@"\n"]) {
				if ([node isEqualToString:@""]) {
					break;
				}
				graph->addNodeFromString([node cStringUsingEncoding:NSUTF8StringEncoding]);
			}
			self.nextNode = (int)[self.nodePositions count];
			[self clearState];
			return YES;
		}
	}
	return NO;
}

- (BOOL) loadPlainTextGraphFrom:(NSURL *)url {
	NSString* data = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	if (data) {
		NSArray* nodes = [data componentsSeparatedByString:@"\n"];
		self.nodePositions = [NSMutableDictionary dictionaryWithCapacity:[nodes count] - 1];
		graph = new Graph();
		float x = 10, y = 10;
		for (NSString* node in nodes) {
			if ([node isEqualToString:@""]) {
				break;
			}
			Node* n = graph->addNodeFromString([node cStringUsingEncoding:NSUTF8StringEncoding]);
			x += 40;
			if (x > 570) {
				x = 10;
				y += 10;
			}
			self.nodePositions[[NSString stringWithCString:n->getName().c_str() encoding:NSUTF8StringEncoding]] = [NSString stringWithFormat:@"%f %f", x, y];
		}
		self.nextNode = (int)[self.nodePositions count];
		[self clearState];
		return YES;
	}
	return NO;
}

- (BOOL) writeGraphTo:(NSURL *)url {
	NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  self.nodePositions, @"NodePositions",
						  [NSString stringWithCString:graph->toString().c_str()
											 encoding:NSUTF8StringEncoding], @"GraphData", nil];
	return [dict writeToURL:url atomically:YES];
}

- (BOOL) exportGraphTo:(NSURL *)url {
	NSString* data = [NSString stringWithCString:graph->toString().c_str() encoding:NSUTF8StringEncoding];
	return [data writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void) connectNode {
	self.currentState = CONNECTING;
}

- (void) deleteSelectedNode {
	graph->removeNode(selectedNode);
	[self.nodePositions removeObjectForKey:[NSString stringWithCString:selectedNode->getName().c_str() encoding:NSUTF8StringEncoding]];
	[self clearState];
}

- (void) clearPath {
	pathNodes.clear();
	self.hasPath = NO;
	[self setNeedsDisplay:YES];
}

- (void) pathFind:(PathfindAlgo)algo {
	self.currentState = WAITINGFORDEST;
	self.desiredAlgo = algo;
}

- (NSRect) rectForOvalAroundPoint:(NSPoint)point {
	return NSMakeRect(point.x - 10, point.y - 10, 20, 20);
}

- (void) drawRect:(NSRect)rect {
	[[NSColor whiteColor] set];
	NSRectFill(rect);

	[[NSColor blackColor] set];
	std::map<std::string, Node*> nodes = graph->getNodes();
	NSBezierPath* path = [NSBezierPath bezierPath];
	for (std::map<std::string, Node*>::iterator it = nodes.begin(); it != nodes.end(); it++) {
		std::map<std::string, float> adjacentNodes = it->second->getAdjacentNodes();
		NSString* name = [NSString stringWithCString:it->first.c_str() encoding:NSUTF8StringEncoding];
		NSPoint pos = NSPointFromString(self.nodePositions[name]);
		for (std::map<std::string, float>::iterator it2 = adjacentNodes.begin(); it2 != adjacentNodes.end(); it2++) {
			[path removeAllPoints];

			NSString* name2 = [NSString stringWithCString:it2->first.c_str() encoding:NSUTF8StringEncoding];
			NSPoint pos2 = NSPointFromString(self.nodePositions[name2]);

			[path moveToPoint:pos];
			[path lineToPoint:pos2];
			[path stroke];

			if (self.showWeights) {
				NSPoint mid = NSMakePoint((pos.x + pos2.x) / 2, (pos.y + pos2.y) / 2);
				NSString* dist = [NSString stringWithFormat:@"%.2f", it2->second];
				[dist drawAtPoint:mid withAttributes:nil];
			}
		}
	}

	if (self.currentState & (PLACING | DRAGGING)) {
		[[NSColor grayColor] set];
		NSBezierPath* path = [NSBezierPath bezierPathWithOvalInRect:
							  [self rectForOvalAroundPoint:self.activeNodePos]];
		[path fill];
	} else if (self.currentState & CONNECTING) {
		[[NSColor blackColor] set];
		NSBezierPath* path = [NSBezierPath bezierPath];
		[path moveToPoint:self.selectedNodePos];
		[path lineToPoint:self.activeNodePos];
		[path stroke];
	}

	if (self.hasPath) {
		[[NSColor redColor] set];
		NSBezierPath* path = [NSBezierPath bezierPath];
		[path setLineWidth:3];

		std::list<Node*>::iterator it = pathNodes.begin();

		NSString* nodeName = [NSString stringWithCString:(*it)->getName().c_str() encoding:NSUTF8StringEncoding];
		[path moveToPoint:NSPointFromString(self.nodePositions[nodeName])];
		it++;

		for (; it != pathNodes.end(); it++) {
			nodeName = [NSString stringWithCString:(*it)->getName().c_str() encoding:NSUTF8StringEncoding];
			[path lineToPoint:NSPointFromString(self.nodePositions[nodeName])];
		}
		[path stroke];
	}

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
		self.selectedNodePos = NSPointFromString(self.nodePositions[self.activeNodeName]);
		[super rightMouseDown:event];
	}
}

- (void) mouseDown:(NSEvent *)event {
	self.activeNodePos = [event locationInWindow];
	[self loadNodeAt:[event locationInWindow] newState:DRAGGING];
}

- (void) mouseUp:(NSEvent *)event {
	if (self.currentState & (PLACING | DRAGGING)) {
		NSString* newPos = [NSString stringWithFormat:@"%f %f", self.activeNodePos.x, self.activeNodePos.y];
		if (self.currentState == PLACING) {
			NSString* name = [NSString stringWithFormat:@"%d", self.nextNode++];
			self.nodePositions[name] = newPos;

			Node* node = new Node([name cStringUsingEncoding:NSUTF8StringEncoding]);
			graph->addNode(node);
		} else {
			self.nodePositions[self.activeNodeName] = newPos;
		}
	} else if (self.currentState & CONNECTING) {
		NSString* node2 = [self getNodeAt:[event locationInWindow]];
		if (![node2 isEqualToString:@""]) {
			Node* otherNode = graph->getNodes().at([node2 cStringUsingEncoding:NSUTF8StringEncoding]);
			if (self.currentState == CONNECTING) {
				if (selectedNode->getAdjacentNodes().count(otherNode->getName()) == 0 &&
					otherNode->getAdjacentNodes().count(selectedNode->getName()) == 0) {
					selectedNode->addAdjacentNode(otherNode, 1);
					otherNode->addAdjacentNode(selectedNode, 1);
				}
			} else if (self.currentState == WAITINGFORDEST) {
				[self clearPath];
				switch (self.desiredAlgo) {
					case DIJKSTRA:
						pathNodes = Pathfinder::dijkstra(graph, selectedNode, otherNode);
						break;
					default:
						NSLog(@"Something has gone horribly wrong...");
						break;
				}
				if (pathNodes.size() > 0) {
					self.hasPath = YES;
				} else {
					NSAlert* alert = [[NSAlert alloc] init];
					[alert setMessageText:@"Pathfinding failed"];
					[alert setInformativeText:@"Failed to find path between specified nodes"];
					[alert runModal];
				}
			}
		}
	}
	[self clearState];
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
	[self mouseUpdate:event shouldUpdate:(self.currentState & (PLACING | CONNECTING))];
}

@end
