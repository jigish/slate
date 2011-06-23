//
//  Constants.h
//  Slate
//
//  Created by Jigish Patel on 5/26/11.
//  Copyright 2011 Jigish Patel. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see http://www.gnu.org/licenses

// Directive Keys
extern NSString * const BIND;
extern NSString * const CONFIG;
extern NSString * const DEFAULT;
extern NSString * const LAYOUT;
extern NSString * const ALIAS;
extern NSString * const SOURCE;

// Source Option Keys
extern NSString * const IF_EXISTS;

// Config Keys
extern NSString * const DEFAULT_TO_CURRENT_SCREEN;
extern NSString * const DEFAULT_TO_CURRENT_SCREEN_DEFAULT;
extern NSString * const NUDGE_PERCENT_OF;
extern NSString * const NUDGE_PERCENT_OF_DEFAULT;
extern NSString * const RESIZE_PERCENT_OF;
extern NSString * const RESIZE_PERCENT_OF_DEFAULT;
extern NSString * const REPEAT_ON_HOLD_OPS;
extern NSString * const REPEAT_ON_HOLD_OPS_DEFAULT;
extern NSString * const SECONDS_BETWEEN_REPEAT;
extern NSString * const SECONDS_BETWEEN_REPEAT_DEFAULT;
extern NSString * const CHECK_DEFAULTS_ON_LOAD;
extern NSString * const CHECK_DEFAULTS_ON_LOAD_DEFAULT;
extern NSString * const FOCUS_CHECK_WIDTH;
extern NSString * const FOCUS_CHECK_WIDTH_DEFAULT;
extern NSString * const FOCUS_CHECK_WIDTH_MAX;
extern NSString * const FOCUS_CHECK_WIDTH_MAX_DEFAULT;
extern NSString * const FOCUS_PREFER_SAME_APP;
extern NSString * const FOCUS_PREFER_SAME_APP_DEFAULT;

// Application Option Keys
extern NSString * const IGNORE_FAIL;
extern NSString * const REPEAT;
extern NSString * const SORT_TITLE;
extern NSString * const MAIN_FIRST;
extern NSString * const MAIN_LAST;
extern NSString * const TITLE_ORDER;

// Modifier Keys
extern NSString * const CONTROL;
extern NSString * const COMMAND;
extern NSString * const OPTION;
extern NSString * const SHIFT;

// Expression Keys
extern NSString * const SCREEN_ORIGIN_X;
extern NSString * const SCREEN_ORIGIN_Y;
extern NSString * const SCREEN_SIZE;
extern NSString * const SCREEN_SIZE_X;
extern NSString * const SCREEN_SIZE_Y;
extern NSString * const WINDOW_TOP_LEFT_X;
extern NSString * const WINDOW_TOP_LEFT_Y;
extern NSString * const WINDOW_SIZE_X;
extern NSString * const WINDOW_SIZE_Y;
extern NSString * const NEW_WINDOW_SIZE;
extern NSString * const NEW_WINDOW_SIZE_X;
extern NSString * const NEW_WINDOW_SIZE_Y;

// Operations
extern NSString * const MOVE;
extern NSString * const RESIZE;
extern NSString * const PUSH;
extern NSString * const NUDGE;
extern NSString * const THROW;
extern NSString * const CORNER;
extern NSString * const CHAIN;
extern NSString * const FOCUS;

// Parameters and Options
extern NSString * const CENTER;
extern NSString * const BAR;
extern NSString * const BAR_RESIZE_WITH_VALUE;
extern NSString * const NONE;
extern NSString * const NORESIZE;
extern NSString * const RESIZE_WITH_VALUE;

// Directions and Anchors
extern NSString * const UP;
extern NSString * const DOWN;
extern NSString * const LEFT;
extern NSString * const RIGHT;
extern NSString * const TOP;
extern NSString * const BOTTOM;
extern NSString * const ABOVE;
extern NSString * const BELOW;
extern NSString * const NEXT;
extern NSString * const PREVIOUS;
extern NSString * const PREV;
extern NSString * const BEHIND;
extern NSString * const TOP_LEFT;
extern NSString * const TOP_RIGHT;
extern NSString * const BOTTOM_LEFT;
extern NSString * const BOTTOM_RIGHT;
extern NSInteger  const DIRECTION_UNKNOWN;
extern NSInteger  const DIRECTION_UP;
extern NSInteger  const DIRECTION_DOWN;
extern NSInteger  const DIRECTION_LEFT;
extern NSInteger  const DIRECTION_RIGHT;
extern NSInteger  const DIRECTION_TOP;
extern NSInteger  const DIRECTION_BOTTOM;
extern NSInteger  const DIRECTION_ABOVE;
extern NSInteger  const DIRECTION_BELOW;
extern NSInteger  const DIRECTION_BEHIND;
extern NSInteger  const ANCHOR_TOP_LEFT;
extern NSInteger  const ANCHOR_TOP_RIGHT;
extern NSInteger  const ANCHOR_BOTTOM_LEFT;
extern NSInteger  const ANCHOR_BOTTOM_RIGHT;

// Seperators and such
extern NSString * const COMMA;
extern NSString * const COLON;
extern NSString * const SEMICOLON;
extern NSString * const MINUS;
extern NSString * const PLUS;
extern NSString * const PERCENT;
extern NSString * const EMPTY;
extern NSString * const PIPE;
extern NSString * const QUOTES;
extern NSString * const EQUALS;
extern NSString * const TILDA;
extern NSString * const SLASH;
extern NSString * const X;

// Screen constants
extern NSString * const REF_CURRENT_SCREEN;
extern NSInteger const ID_MAIN_SCREEN;
extern NSInteger const ID_CURRENT_SCREEN;
extern NSInteger const ID_IGNORE_SCREEN;
extern NSInteger const TYPE_UNKNOWN;
extern NSInteger const TYPE_COUNT;
extern NSInteger const TYPE_RESOLUTIONS;
extern NSString * const COUNT;
extern NSString * const RESOLUTIONS;

// Notifications
extern NSString * const NOTIFICATION_SCREEN_CHANGE;

// Applications
extern NSString * const FINDER;