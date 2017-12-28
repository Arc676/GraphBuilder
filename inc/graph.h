//Written by Arc676/Alessandro Vinciguerra <alesvinciguerra@gmail.com>
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

#ifndef GRAPH_H
#define GRAPH_H

#include <string>
#include <fstream>
#include <map>

#include "node.h"

class Graph {
	std::map<std::string, Node*> nodes;
public:
	Graph(const std::string&);
	void save(const std::string&);

	std::map<std::string, Node*> getNodes();
	void addNode(Node*);
	void removeNode(Node*);
};

#endif
