//
//  Constants.m
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

#import "Constants.h"

// Directive Keys
NSString * const BIND = @"bind";
NSString * const CONFIG = @"config";
NSString * const LAYOUT = @"layout";
NSString * const DEFAULT = @"default";
NSString * const ALIAS = @"alias";
NSString * const SOURCE = @"source";

// Source Option Keys
NSString * const IF_EXISTS = @"if_exists";

// Config Keys
NSString * const DEFAULT_TO_CURRENT_SCREEN = @"defaultToCurrentScreen";
NSString * const DEFAULT_TO_CURRENT_SCREEN_DEFAULT = @"false";
NSString * const NUDGE_PERCENT_OF = @"nudgePercentOf";
NSString * const NUDGE_PERCENT_OF_DEFAULT = @"windowSize";
NSString * const RESIZE_PERCENT_OF = @"resizePercentOf";
NSString * const RESIZE_PERCENT_OF_DEFAULT = @"windowSize";
NSString * const REPEAT_ON_HOLD_OPS = @"repeatOnHoldOps";
NSString * const REPEAT_ON_HOLD_OPS_DEFAULT = @"resize,nudge";
NSString * const SECONDS_BETWEEN_REPEAT = @"secondsBetweenRepeat";
NSString * const SECONDS_BETWEEN_REPEAT_DEFAULT = @"0.2";
NSString * const CHECK_DEFAULTS_ON_LOAD = @"checkDefaultsOnLoad";
NSString * const CHECK_DEFAULTS_ON_LOAD_DEFAULT = @"false";
NSString * const FOCUS_CHECK_WIDTH = @"focusCheckWidth";
NSString * const FOCUS_CHECK_WIDTH_DEFAULT = @"100";
NSString * const FOCUS_CHECK_WIDTH_MAX = @"focusCheckWidthMax";
NSString * const FOCUS_CHECK_WIDTH_MAX_DEFAULT = @"100";
NSString * const FOCUS_PREFER_SAME_APP = @"focusPreferSameApp";
NSString * const FOCUS_PREFER_SAME_APP_DEFAULT = @"true";

// Application Option Keys
NSString * const IGNORE_FAIL = @"IGNORE_FAIL";
NSString * const REPEAT = @"REPEAT";
NSString * const SORT_TITLE = @"SORT_TITLE";
NSString * const MAIN_FIRST = @"MAIN_FIRST";
NSString * const MAIN_LAST = @"MAIN_LAST";
NSString * const TITLE_ORDER = @"TITLE_ORDER=";

// Modifier Keys
NSString * const CONTROL = @"ctrl";
NSString * const COMMAND = @"cmd";
NSString * const OPTION = @"alt";
NSString * const SHIFT = @"shift";

// Expression Keys
NSString * const SCREEN_ORIGIN_X = @"screenOriginX";
NSString * const SCREEN_ORIGIN_Y = @"screenOriginY";
NSString * const SCREEN_SIZE = @"screenSize";
NSString * const SCREEN_SIZE_X = @"screenSizeX";
NSString * const SCREEN_SIZE_Y = @"screenSizeY";
NSString * const WINDOW_TOP_LEFT_X = @"windowTopLeftX";
NSString * const WINDOW_TOP_LEFT_Y = @"windowTopLeftY";
NSString * const WINDOW_SIZE_X = @"windowSizeX";
NSString * const WINDOW_SIZE_Y = @"windowSizeY";
NSString * const NEW_WINDOW_SIZE = @"newWindowSize";
NSString * const NEW_WINDOW_SIZE_X = @"newWindowSizeX";
NSString * const NEW_WINDOW_SIZE_Y = @"newWindowSizeY";

// Operations
NSString * const MOVE = @"move";
NSString * const RESIZE = @"resize";
NSString * const PUSH = @"push";
NSString * const NUDGE = @"nudge";
NSString * const THROW = @"throw";
NSString * const CORNER = @"corner";
NSString * const CHAIN = @"chain";
NSString * const FOCUS = @"focus";

// Parameters and Options
NSString * const CENTER = @"center";
NSString * const BAR = @"bar";
NSString * const BAR_RESIZE_WITH_VALUE = @"bar-resize:";
NSString * const NONE = @"none";
NSString * const NORESIZE = @"noresize";
NSString * const RESIZE_WITH_VALUE = @"resize:";

// Directions and Anchors
NSString * const UP = @"up";
NSString * const DOWN = @"down";
NSString * const LEFT = @"left";
NSString * const RIGHT = @"right";
NSString * const TOP = @"top";
NSString * const BOTTOM = @"bottom";
NSString * const ABOVE = @"above";
NSString * const BELOW = @"below";
NSString * const NEXT = @"next";
NSString * const PREVIOUS = @"previous";
NSString * const PREV = @"prev";
NSString * const BEHIND = @"behind";
NSString * const TOP_LEFT = @"top-left";
NSString * const TOP_RIGHT = @"top-right";
NSString * const BOTTOM_LEFT = @"bottom-left";
NSString * const BOTTOM_RIGHT = @"bottom-right";
NSInteger  const DIRECTION_UNKNOWN = -1;
NSInteger  const DIRECTION_UP = 0;
NSInteger  const DIRECTION_DOWN = 1;
NSInteger  const DIRECTION_LEFT = 2;
NSInteger  const DIRECTION_RIGHT = 3;
NSInteger  const DIRECTION_TOP = 4;
NSInteger  const DIRECTION_BOTTOM = 5;
NSInteger  const DIRECTION_ABOVE = 6;
NSInteger  const DIRECTION_BELOW = 7;
NSInteger  const DIRECTION_BEHIND = 8;
NSInteger  const ANCHOR_TOP_LEFT = 0;
NSInteger  const ANCHOR_TOP_RIGHT = 1;
NSInteger  const ANCHOR_BOTTOM_LEFT = 2;
NSInteger  const ANCHOR_BOTTOM_RIGHT = 3;

// Seperators and such
NSString * const COMMA = @",";
NSString * const COLON = @":";
NSString * const SEMICOLON = @";";
NSString * const MINUS = @"-";
NSString * const PLUS = @"+";
NSString * const PERCENT = @"%";
NSString * const EMPTY = @"";
NSString * const PIPE = @" | ";
NSString * const QUOTES = @"'\"";
NSString * const EQUALS = @"=";
NSString * const TILDA = @"~";
NSString * const SLASH = @"/";
NSString * const X = @"x";

// Screen constants
NSString * const REF_CURRENT_SCREEN = @"-1";
NSInteger const ID_MAIN_SCREEN = 0;
NSInteger const ID_CURRENT_SCREEN = -1;
NSInteger const ID_IGNORE_SCREEN = -2;
NSInteger const TYPE_UNKNOWN = -1;
NSInteger const TYPE_COUNT = 0;
NSInteger const TYPE_RESOLUTIONS = 1;
NSString * const COUNT = @"count";
NSString * const RESOLUTIONS = @"resolutions";

// Notifications
NSString * const NOTIFICATION_SCREEN_CHANGE = @"O3DeviceTimingChanged";

// Applications
NSString * const FINDER = @"Finder";