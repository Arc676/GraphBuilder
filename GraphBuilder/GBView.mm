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
	_showNodeNames = YES;

	_activeNodeName = @"";
	[super awakeFromNib];
}

- (BOOL) acceptsFirstResponder {
	return YES;
}

- (NSString*) cToNSString:(std::string)str {
	return [NSString stringWithCString:str.c_str() encoding:NSUTF8StringEncoding];
}

- (std::string) NSToCString:(NSString*)str {
	return [str cStringUsingEncoding:NSUTF8StringEncoding];
}

- (NSDictionary*) getSelectedNodeData {
	NSMutableDictionary* connections = [NSMutableDictionary dictionary];
	std::map<std::string, Edge*> adjacent = selectedNode->getAdjacentNodes();
	for (std::map<std::string, Edge*>::iterator it = adjacent.begin(); it != adjacent.end(); it++) {
		connections[[self cToNSString:it->first]] = [NSNumber numberWithFloat:it->second->getWeight()];
	}
	return @{
			 @"Name" : [self cToNSString:selectedNode->getName()],
			 @"Connections" : connections
			 };
}

- (void) loadModifiedNodeData:(NSDictionary *)data forNode:(NSString *)node {
	NSString* nodeName = data[@"Name"];
	std::string newName = [self NSToCString:nodeName];
	std::string originalName = [self NSToCString:node];

	NSString* pos = self.nodePositions[node];
	[self.nodePositions removeObjectForKey:node];
	self.nodePositions[nodeName] = pos;

	Node* modifiedNode = graph->getNodes()[originalName];
	graph->renameNode(modifiedNode, newName);

	__block std::map<std::string, Edge*> adjacent = modifiedNode->getAdjacentNodes();
	[data[@"Connections"] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSNumber* dist, BOOL* stop) {
		std::string node = [self NSToCString:key];
		float nodeDist = [dist floatValue];
		if (adjacent[node]->getWeight() != nodeDist) {
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
				graph->addNodeFromString([self NSToCString:node]);
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
			Node* n = graph->addNodeFromString([self NSToCString:node]);
			x += 40;
			if (x > 570) {
				x = 10;
				y += 10;
			}
			self.nodePositions[[self cToNSString:n->getName()]] = [NSString stringWithFormat:@"%f %f", x, y];
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
						  [self cToNSString:graph->toString()], @"GraphData", nil];
	return [dict writeToURL:url atomically:YES];
}

- (BOOL) exportGraphTo:(NSURL *)url {
	NSString* data = [self cToNSString:graph->toString()];
	return [data writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void) connectNode {
	self.currentState = CONNECTING;
}

- (void) deleteSelectedNode {
	graph->removeNode(selectedNode);
	[self.nodePositions removeObjectForKey:[self cToNSString:selectedNode->getName()]];
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
		std::map<std::string, Edge*> adjacentNodes = it->second->getAdjacentNodes();
		NSString* name = [self cToNSString:it->first];
		NSPoint pos = NSPointFromString(self.nodePositions[name]);
		for (std::map<std::string, Edge*>::iterator it2 = adjacentNodes.begin(); it2 != adjacentNodes.end(); it2++) {
			[path removeAllPoints];

			NSString* name2 = [self cToNSString:it2->first];
			NSPoint pos2 = NSPointFromString(self.nodePositions[name2]);

			[path moveToPoint:pos];
			[path lineToPoint:pos2];
			[path stroke];

			if (self.showWeights) {
				NSPoint mid = NSMakePoint((pos.x + pos2.x) / 2, (pos.y + pos2.y) / 2);
				NSString* dist = [NSString stringWithFormat:@"%.2f", it2->second->getWeight()];
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

		NSString* nodeName = [self cToNSString:(*it)->getName()];
		[path moveToPoint:NSPointFromString(self.nodePositions[nodeName])];
		it++;

		for (; it != pathNodes.end(); it++) {
			nodeName = [self cToNSString:(*it)->getName()];
			[path lineToPoint:NSPointFromString(self.nodePositions[nodeName])];
		}
		[path stroke];
	}

	for (std::map<std::string, Node*>::iterator it = nodes.begin(); it != nodes.end(); it++) {
		NSString* name = [self cToNSString:it->first];
		NSPoint pos = NSPointFromString(self.nodePositions[name]);

		NSBezierPath* path = [NSBezierPath bezierPathWithOvalInRect:
							  [self rectForOvalAroundPoint:pos]];
		if (self.showNodeNames) {
			[name drawAtPoint:NSMakePoint(pos.x + 20, pos.y) withAttributes:nil];
		}

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
		selectedNode = graph->getNodes().at([self NSToCString:self.activeNodeName]);
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

			Node* node = new Node([self NSToCString:name]);
			graph->addNode(node);
		} else {
			self.nodePositions[self.activeNodeName] = newPos;
		}
	} else if (self.currentState & CONNECTING) {
		NSString* node2 = [self getNodeAt:[event locationInWindow]];
		if (![node2 isEqualToString:@""]) {
			Node* otherNode = graph->getNodes().at([self NSToCString:node2]);
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

- (void) showGraphWeight {
	NSAlert* alert = [[NSAlert alloc] init];
	[alert setMessageText:@"Total graph weight"];
	[alert setInformativeText:[NSString stringWithFormat:@"%f", graph->totalGraphWeight()]];
	[alert runModal];
}

- (void) generateMST {
	graph = graph->minimumSpanningTree();
	[self setNeedsDisplay:YES];
}

@end
