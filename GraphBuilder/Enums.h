//
//  Enums.h
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

#ifndef Enums_h
#define Enums_h

typedef enum : int {
	IDLE			= 0b00000001,
	PLACING			= 0b00000010,
	DRAGGING		= 0b00000100,
	SELECTED		= 0b00001000,
	CONNECTING		= 0b00011000,
	WAITINGFORDEST	= 0b00111000
} State;

typedef enum : int {
	DIJKSTRA
} PathfindAlgo;

#endif
