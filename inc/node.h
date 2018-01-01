//Pathfinder library, version 1.1
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

//Based on work by Matthew Chen
//Copyright (C) 2017 Matthew Chen

#ifndef NODE_H
#define NODE_H

#include <map>
#include <sstream>
#include <string>

class Node {
	std::string name;
	std::map<std::string, float> adjacentNodes;
public:
	Node(const std::string&);
	std::string toString();

	std::map<std::string, float> getAdjacentNodes();

	void setName(const std::string&);
	std::string getName();

	void addAdjacentNodeByName(const std::string&, float);
	void addAdjacentNode(Node*, float);

	void removeAdjacentNodeByName(const std::string&);
	void removeAdjacentNode(Node*);
};

#endif
