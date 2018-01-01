//
//  Inspector.m
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

#import "Inspector.h"

@implementation Inspector

- (void) viewDidLoad {
	[_connectionsTable setDelegate:self];
	[_connectionsTable setDataSource:self];
	[super viewDidLoad];
}

- (void) loadNodeData:(NSDictionary *)data {
	self.originalData = data;
	self.nodeData = [self.originalData mutableCopy];

	[self.nodeName setStringValue:self.originalData[@"Name"]];
	[self.connectionsTable reloadData];
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
	return [self.nodeData[@"Connections"] count];
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	NSString* node = [self.nodeData[@"Connections"] allKeys][row];
	if ([[tableColumn title] isEqualToString:@"Node"]) {
		return node;
	} else {
		return self.nodeData[@"Connections"][node];
	}
}

- (void) tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	//
}

- (IBAction)removeConnection:(id)sender {
}

- (IBAction)applyChanges:(id)sender {
}

- (IBAction)revertChanges:(id)sender {
	[self loadNodeData:self.originalData];
}
@end
