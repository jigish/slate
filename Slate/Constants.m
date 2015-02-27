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

NSInteger const MODAL_ESCAPE_ID = 40000;

NSString *const SNAPSHOTS_FILE = @"snapshots";

// Directive Keys
NSString *const BIND = @"bind";
NSString *const CONFIG = @"config";
NSString *const LAYOUT = @"layout";
NSString *const DEFAULT = @"default";
NSString *const ALIAS = @"alias";
NSString *const SOURCE = @"source";

// Source Option Keys
NSString *const IF_EXISTS = @"if_exists";

// Config Keys
NSString *const MENU_BAR_ICON_HIDDEN = @"menuBarIconHidden";
NSString *const MENU_BAR_ICON_HIDDEN_DEFAULT = @"false";
NSString *const DEFAULT_TO_CURRENT_SCREEN = @"defaultToCurrentScreen";
NSString *const DEFAULT_TO_CURRENT_SCREEN_DEFAULT = @"false";
NSString *const NUDGE_PERCENT_OF = @"nudgePercentOf";
NSString *const NUDGE_PERCENT_OF_DEFAULT = @"screenSize";
NSString *const RESIZE_PERCENT_OF = @"resizePercentOf";
NSString *const RESIZE_PERCENT_OF_DEFAULT = @"screenSize";
NSString *const REPEAT_ON_HOLD_OPS = @"repeatOnHoldOps";
NSString *const REPEAT_ON_HOLD_OPS_DEFAULT = @"resize,nudge";
NSString *const SECONDS_BEFORE_REPEAT = @"secondsBeforeRepeat";
NSString *const SECONDS_BEFORE_REPEAT_DEFAULT = @"0.4";
NSString *const SECONDS_BETWEEN_REPEAT = @"secondsBetweenRepeat";
NSString *const SECONDS_BETWEEN_REPEAT_DEFAULT = @"0.2";
NSString *const CHECK_DEFAULTS_ON_LOAD = @"checkDefaultsOnLoad";
NSString *const CHECK_DEFAULTS_ON_LOAD_DEFAULT = @"false";
NSString *const FOCUS_CHECK_WIDTH = @"focusCheckWidth";
NSString *const FOCUS_CHECK_WIDTH_DEFAULT = @"100";
NSString *const FOCUS_CHECK_WIDTH_MAX = @"focusCheckWidthMax";
NSString *const FOCUS_CHECK_WIDTH_MAX_DEFAULT = @"100";
NSString *const FOCUS_PREFER_SAME_APP = @"focusPreferSameApp";
NSString *const FOCUS_PREFER_SAME_APP_DEFAULT = @"true";
NSString *const ORDER_SCREENS_LEFT_TO_RIGHT = @"orderScreensLeftToRight";
NSString *const ORDER_SCREENS_LEFT_TO_RIGHT_DEFAULT = @"true";
NSString *const WINDOW_HINTS_FONT_NAME = @"windowHintsFontName";
NSString *const WINDOW_HINTS_FONT_NAME_DEFAULT = @"Helvetica";
NSString *const WINDOW_HINTS_FONT_SIZE = @"windowHintsFontSize";
NSString *const WINDOW_HINTS_FONT_SIZE_DEFAULT = @"40";
NSString *const WINDOW_HINTS_FONT_COLOR = @"windowHintsFontColor";
NSString *const WINDOW_HINTS_FONT_COLOR_DEFAULT = @"255;255;255;1.0";
NSString *const WINDOW_HINTS_WIDTH = @"windowHintsWidth";
NSString *const WINDOW_HINTS_WIDTH_DEFAULT = @"100";
NSString *const WINDOW_HINTS_HEIGHT = @"windowHintsHeight";
NSString *const WINDOW_HINTS_HEIGHT_DEFAULT = @"100";
NSString *const WINDOW_HINTS_BACKGROUND_COLOR = @"windowHintsBackgroundColor";
NSString *const WINDOW_HINTS_BACKGROUND_COLOR_DEFAULT = @"50;53;58;0.9";
NSString *const WINDOW_HINTS_DURATION = @"windowHintsDuration";
NSString *const WINDOW_HINTS_DURATION_DEFAULT = @"3";
NSString *const WINDOW_HINTS_ROUNDED_CORNER_SIZE = @"windowHintsRoundedCornerSize";
NSString *const WINDOW_HINTS_ROUNDED_CORNER_SIZE_DEFAULT = @"5";
NSString *const WINDOW_HINTS_IGNORE_HIDDEN_WINDOWS = @"windowHintsIgnoreHiddenWindows";
NSString *const WINDOW_HINTS_IGNORE_HIDDEN_WINDOWS_DEFAULT = @"true";
NSString *const WINDOW_HINTS_TOP_LEFT_X = @"windowHintsTopLeftX";
NSString *const WINDOW_HINTS_TOP_LEFT_X_DEFAULT = @"(windowSizeX/2)-(windowHintsWidth/2);0";
NSString *const WINDOW_HINTS_TOP_LEFT_Y = @"windowHintsTopLeftY";
NSString *const WINDOW_HINTS_TOP_LEFT_Y_DEFAULT = @"(windowSizeY/2)-(windowHintsHeight/2);0";
NSString *const WINDOW_HINTS_ORDER = @"windowHintsOrder";
NSString *const WINDOW_HINTS_ORDER_DEFAULT = @"leftToRight";
NSString *const WINDOW_HINTS_SHOW_ICONS = @"windowHintsShowIcons";
NSString *const WINDOW_HINTS_SHOW_ICONS_DEFAULT = @"false";
NSString *const WINDOW_HINTS_ICON_ALPHA = @"windowHintsIconAlpha";
NSString *const WINDOW_HINTS_ICON_ALPHA_DEFAULT = @"1.0";
NSString *const WINDOW_HINTS_SPREAD = @"windowHintsSpread";
NSString *const WINDOW_HINTS_SPREAD_DEFAULT = @"false";
NSString *const WINDOW_HINTS_SPREAD_SEARCH_WIDTH = @"windowHintsSpreadSearchWidth";
NSString *const WINDOW_HINTS_SPREAD_SEARCH_WIDTH_DEFAULT = @"40";
NSString *const WINDOW_HINTS_SPREAD_SEARCH_HEIGHT = @"windowHintsSpreadSearchHeight";
NSString *const WINDOW_HINTS_SPREAD_SEARCH_HEIGHT_DEFAULT = @"40";
NSString *const WINDOW_HINTS_SPREAD_PADDING = @"windowHintsSpreadPadding";
NSString *const WINDOW_HINTS_SPREAD_PADDING_DEFAULT = @"20";
NSString *const SWITCH_ICON_SIZE = @"switchIconSize";
NSString *const SWITCH_ICON_SIZE_DEFAULT = @"100";
NSString *const SWITCH_ICON_PADDING = @"switchIconPadding";
NSString *const SWITCH_ICON_PADDING_DEFAULT = @"5";
NSString *const SWITCH_BACKGROUND_COLOR = @"switchBackgroundColor";
NSString *const SWITCH_BACKGROUND_COLOR_DEFAULT = @"50;53;58;0.3";
NSString *const SWITCH_SELECTED_BACKGROUND_COLOR = @"switchSelectedBackgroundColor";
NSString *const SWITCH_SELECTED_BACKGROUND_COLOR_DEFAULT = @"50;53;58;0.9";
NSString *const SWITCH_SELECTED_BORDER_COLOR = @"switchSelectedBorderColor";
NSString *const SWITCH_SELECTED_BORDER_COLOR_DEFAULT = @"230;230;230;0.9";
NSString *const SWITCH_SELECTED_BORDER_SIZE = @"switchSelectedBorderSize";
NSString *const SWITCH_SELECTED_BORDER_SIZE_DEFAULT = @"2";
NSString *const SWITCH_ROUNDED_CORNER_SIZE = @"switchRoundedCornerSize";
NSString *const SWITCH_ROUNDED_CORNER_SIZE_DEFAULT = @"5";
NSString *const SWITCH_ORIENTATION = @"switchOrientation";
NSString *const SWITCH_ORIENTATION_DEFAULT = @"horizontal";
NSString *const SWITCH_SECONDS_BEFORE_REPEAT = @"switchSecondsBeforeRepeat";
NSString *const SWITCH_SECONDS_BEFORE_REPEAT_DEFAULT = @"0.3";
NSString *const SWITCH_SECONDS_BETWEEN_REPEAT = @"switchSecondsBetweenRepeat";
NSString *const SWITCH_SECONDS_BETWEEN_REPEAT_DEFAULT = @"0.03";
NSString *const SWITCH_STOP_REPEAT_AT_EDGE = @"switchStopRepeatAtEdge";
NSString *const SWITCH_STOP_REPEAT_AT_EDGE_DEFAULT = @"true";
NSString *const SWITCH_ONLY_FOCUS_MAIN_WINDOW = @"switchOnlyFocusMainWindow";
NSString *const SWITCH_ONLY_FOCUS_MAIN_WINDOW_DEFAULT = @"true";
NSString *const SWITCH_FONT_SIZE = @"switchFontSize";
NSString *const SWITCH_FONT_SIZE_DEFAULT = @"14";
NSString *const SWITCH_FONT_COLOR = @"switchFontColor";
NSString *const SWITCH_FONT_COLOR_DEFAULT = @"255;255;255;1.0";
NSString *const SWITCH_FONT_NAME = @"switchFontName";
NSString *const SWITCH_FONT_NAME_DEFAULT = @"Helvetica";
NSString *const SWITCH_SHOW_TITLES = @"switchShowTitles";
NSString *const SWITCH_SHOW_TITLES_DEFAULT = @"false";
NSString *const SWITCH_TYPE = @"switchType";
NSString *const SWITCH_TYPE_DEFAULT = @"app";
NSString *const SWITCH_SELECTED_PADDING = @"switchSelectedPadding";
NSString *const SWITCH_SELECTED_PADDING_DEFAULT = @"10";
NSString *const KEYBOARD_LAYOUT = @"keyboardLayout";
NSString *const KEYBOARD_LAYOUT_DEFAULT = @"qwerty";
NSString *const SNAPSHOT_TITLE_MATCH = @"snapshotTitleMatch";
NSString *const SNAPSHOT_TITLE_MATCH_DEFAULT = @"levenshtein";
NSString *const LEVENSHTEIN = @"levenshtein";
NSString *const SEQUENTIAL = @"sequential";
NSString *const SNAPSHOT_MAX_STACK_SIZE = @"snapshotMaxStackSize";
NSString *const SNAPSHOT_MAX_STACK_SIZE_DEFAULT = @"0";
NSString *const UNDO_MAX_STACK_SIZE = @"undoMaxStackSize";
NSString *const UNDO_MAX_STACK_SIZE_DEFAULT = @"10";
NSString *const UNDO_OPS = @"undoOps";
NSString *const UNDO_OPS_DEFAULT = @"activate-snapshot,chain,grid,layout,move,push,nudge,corner,throw,resize,sequence,shell";
NSString *const GRID_BACKGROUND_COLOR = @"gridBackgroundColor";
NSString *const GRID_BACKGROUND_COLOR_DEFAULT = @"75;77;81;1.0";
NSString *const GRID_ROUNDED_CORNER_SIZE = @"gridRoundedCornerSize";
NSString *const GRID_ROUNDED_CORNER_SIZE_DEFAULT = @"5";
NSString *const GRID_CELL_BACKGROUND_COLOR = @"gridCellBackgroundColor";
NSString *const GRID_CELL_BACKGROUND_COLOR_DEFAULT = @"100;106;116;0.8";
NSString *const GRID_CELL_SELECTED_COLOR = @"gridCellSelectedColor";
NSString *const GRID_CELL_SELECTED_COLOR_DEFAULT = @"50;53;58;0.8";
NSString *const GRID_CELL_ROUNDED_CORNER_SIZE = @"gridCellRoundedCornerSize";
NSString *const GRID_CELL_ROUNDED_CORNER_SIZE_DEFAULT = @"5";
NSString *const LAYOUT_FOCUS_ON_ACTIVATE = @"layoutFocusOnActivate";
NSString *const LAYOUT_FOCUS_ON_ACTIVATE_DEFAULT = @"false";
NSString *const MODAL_ESCAPE_KEY = @"modalEscapeKey";
NSString *const MODAL_ESCAPE_KEY_DEFAULT = @"";
NSString *const JS_RECEIVE_MOVE_EVENT = @"jsReceiveMoveEvent";
NSString *const JS_RECEIVE_MOVE_EVENT_DEFAULT = @"false";
NSString *const JS_RECEIVE_RESIZE_EVENT = @"jsReceiveResizeEvent";
NSString *const JS_RECEIVE_RESIZE_EVENT_DEFAULT = @"false";

// Application Option Keys
NSString *const IGNORE_FAIL = @"IGNORE_FAIL";
NSString *const REPEAT = @"REPEAT";
NSString *const REPEAT_LAST = @"REPEAT_LAST";
NSString *const SORT_TITLE = @"SORT_TITLE";
NSString *const MAIN_FIRST = @"MAIN_FIRST";
NSString *const MAIN_LAST = @"MAIN_LAST";
NSString *const TITLE_ORDER = @"TITLE_ORDER=";
NSString *const TITLE_ORDER_REGEX = @"TITLE_ORDER_REGEX=";

// Modifier Keys
NSString *const CONTROL = @"ctrl";
NSString *const COMMAND = @"cmd";
NSString *const OPTION = @"alt";
NSString *const SHIFT = @"shift";
NSString *const FUNCTION = @"fn";
UInt32 const FUNCTION_KEY = 0x800000;

// Expression Keys
NSString *const SCREEN_ORIGIN_X = @"screenOriginX";
NSString *const SCREEN_ORIGIN_Y = @"screenOriginY";
NSString *const SCREEN_SIZE = @"screenSize";
NSString *const SCREEN_SIZE_X = @"screenSizeX";
NSString *const SCREEN_SIZE_Y = @"screenSizeY";
NSString *const WINDOW_TOP_LEFT_X = @"windowTopLeftX";
NSString *const WINDOW_TOP_LEFT_Y = @"windowTopLeftY";
NSString *const WINDOW_SIZE_X = @"windowSizeX";
NSString *const WINDOW_SIZE_Y = @"windowSizeY";
NSString *const NEW_WINDOW_SIZE = @"newWindowSize";
NSString *const NEW_WINDOW_SIZE_X = @"newWindowSizeX";
NSString *const NEW_WINDOW_SIZE_Y = @"newWindowSizeY";

// Operations
NSString *const MOVE = @"move";
NSString *const RESIZE = @"resize";
NSString *const PUSH = @"push";
NSString *const NUDGE = @"nudge";
NSString *const THROW = @"throw";
NSString *const CORNER = @"corner";
NSString *const CHAIN = @"chain";
NSString *const FOCUS = @"focus";
NSString *const SNAPSHOT = @"snapshot";
NSString *const ACTIVATE_SNAPSHOT = @"activate-snapshot";
NSString *const DELETE_SNAPSHOT = @"delete-snapshot";
NSString *const HINT = @"hint";
NSString *const SWITCH = @"switch";
NSString *const GRID = @"grid";
NSString *const SEQUENCE = @"sequence";
NSString *const HIDE = @"hide";
NSString *const SHOW = @"show";
NSString *const TOGGLE = @"toggle";
NSString *const RELAUNCH = @"relaunch";
NSString *const SHELL = @"shell";
NSString *const UNDO = @"undo";

// Parameters and Options
NSString *const CENTER = @"center";
NSString *const BAR = @"bar";
NSString *const BAR_RESIZE_WITH_VALUE = @"bar-resize:";
NSString *const NONE = @"none";
NSString *const NORESIZE = @"noresize";
NSString *const RESIZE_WITH_VALUE = @"resize:";
NSString *const SAVE_TO_DISK = @"save-to-disk";
NSString *const STACK = @"stack";
NSString *const NAME = @"name";
NSString *const SNAPSHOTS = @"snapshots";
NSString *const APPS = @"apps";
NSString *const APP_NAME = @"app-name";
NSString *const TITLE = @"title";
NSString *const SIZE = @"size";
NSString *const ALL = @"all";
NSString *const DELETE = @"delete";
NSString *const BACK = @"back";
NSString *const QUIT = @"quit";
NSString *const FORCE_QUIT = @"force-quit";
NSString *const WINDOW_HINTS_ORDER_NONE = @"none";
NSString *const WINDOW_HINTS_ORDER_PERSIST = @"persist";
NSString *const WINDOW_HINTS_ORDER_LEFT_TO_RIGHT = @"leftToRight";
NSString *const WINDOW_HINTS_ORDER_RIGHT_TO_LEFT = @"rightToLeft";
NSString *const SWITCH_ORIENTATION_HORIZONTAL = @"horizontal";
NSString *const SWITCH_ORIENTATION_VERTICAL = @"vertical";
NSString *const KEYBOARD_LAYOUT_DVORAK = @"dvorak";
NSString *const KEYBOARD_LAYOUT_COLEMAK = @"colemak";
NSString *const KEYBOARD_LAYOUT_AZERTY = @"azerty";
NSString *const PADDING = @"padding";
NSString *const CURRENT = @"current";
NSString *const ALL_BUT = @"all-but:";
NSString *const WAIT = @"wait";
NSString *const PATH = @"path:";
NSString *const APP_NAME_BEFORE = @"BEFORE";
NSString *const APP_NAME_AFTER = @"AFTER";

// Directions and Anchors
NSString *const UP = @"up";
NSString *const DOWN = @"down";
NSString *const LEFT = @"left";
NSString *const RIGHT = @"right";
NSString *const TOP = @"top";
NSString *const BOTTOM = @"bottom";
NSString *const ABOVE = @"above";
NSString *const BELOW = @"below";
NSString *const NEXT = @"next";
NSString *const PREVIOUS = @"previous";
NSString *const PREV = @"prev";
NSString *const BEHIND = @"behind";
NSString *const TOP_LEFT = @"top-left";
NSString *const TOP_RIGHT = @"top-right";
NSString *const BOTTOM_LEFT = @"bottom-left";
NSString *const BOTTOM_RIGHT = @"bottom-right";
NSInteger const DIRECTION_UNKNOWN = -1;
NSInteger const DIRECTION_UP = 0;
NSInteger const DIRECTION_DOWN = 1;
NSInteger const DIRECTION_LEFT = 2;
NSInteger const DIRECTION_RIGHT = 3;
NSInteger const DIRECTION_TOP = 4;
NSInteger const DIRECTION_BOTTOM = 5;
NSInteger const DIRECTION_ABOVE = 6;
NSInteger const DIRECTION_BELOW = 7;
NSInteger const DIRECTION_BEHIND = 8;
NSInteger const ANCHOR_TOP_LEFT = 0;
NSInteger const ANCHOR_TOP_RIGHT = 1;
NSInteger const ANCHOR_BOTTOM_LEFT = 2;
NSInteger const ANCHOR_BOTTOM_RIGHT = 3;

// Seperators and such
unichar const COMMENT_CHARACTER = '#';
NSString *const COMMA = @",";
NSString *const COLON = @":";
NSString *const SEMICOLON = @";";
NSString *const MINUS = @"-";
NSString *const PLUS = @"+";
NSString *const PERCENT = @"%";
NSString *const EMPTY = @"";
NSString *const PIPE_PADDED = @" | ";
NSString *const GREATER_THAN_PADDED = @" > ";
NSString *const QUOTES = @"'\"";
NSString *const SPACE_WORD= @"<space>";
NSString *const EQUALS = @"=";
NSString *const TILDA = @"~";
NSString *const SLASH = @"/";
NSString *const X = @"x";
NSString *const Y = @"y";
NSString *const WIDTH = @"width";
NSString *const HEIGHT = @"height";
NSString *const WHITESPACE = @" \t";

// Screen constants
NSString *const REF_CURRENT_SCREEN = @"-1";
NSInteger const ID_MAIN_SCREEN = 0;
NSInteger const ID_CURRENT_SCREEN = -1;
NSInteger const ID_IGNORE_SCREEN = -2;
NSInteger const TYPE_UNKNOWN = -1;
NSInteger const TYPE_COUNT = 0;
NSInteger const TYPE_RESOLUTIONS = 1;
NSString *const COUNT = @"count";
NSString *const RESOLUTIONS = @"resolutions";
NSString *const ORDERED = @"ordered";

// Notifications
NSString *const NOTIFICATION_SCREEN_CHANGE = @"O3DeviceTimingChanged";
NSString *const NOTIFICATION_SCREEN_CHANGE_LION = @" com.apple.BezelServices.BMDisplayHWReconfiguredEvent";

// Applications
NSString *const FINDER = @"Finder";

// Window Hints
NSInteger const HINT_X_PADDING = 4;
NSString *const HINT_CHARACTERS = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
NSInteger const MAIN_MENU_HEIGHT = 22;

// Internal Snapshots
NSString *const MENU_SNAPSHOT = @"menuSnapshot"; // need to change this name.
NSString *const UNDO_SNAPSHOT = @"_internal_UndoSnapshot";

// File Extensions
NSString *const EXT_JS = @".js";

// Javascript Operation Options Hash Keys
NSString *const OPT_STYLE = @"style";
NSString *const OPT_DIRECTION = @"direction";
NSString *const OPT_SCREEN = @"screen";
NSString *const OPT_X = @"x";
NSString *const OPT_Y = @"y";
NSString *const OPT_WIDTH = @"width";
NSString *const OPT_HEIGHT = @"height";
NSString *const OPT_ANCHOR = @"anchor";
NSString *const OPT_APP = @"app";
NSString *const OPT_COMMAND = @"command";
NSString *const OPT_WAIT = @"wait";
NSString *const OPT_PATH = @"path";
NSString *const OPT_NAME = @"name";
NSString *const OPT_CHARACTERS = @"characters";
NSString *const OPT_PADDING = @"padding";
NSString *const OPT_GRIDS = @"grids";
NSString *const OPT_BACK = @"back";
NSString *const OPT_QUIT = @"quit";
NSString *const OPT_FORCE_QUIT = @"force-quit";
NSString *const OPT_HIDE = @"hide";
NSString *const OPT_DELETE = @"delete";
NSString *const OPT_ALL = @"all";
NSString *const OPT_SAVE = @"save";
NSString *const OPT_STACK = @"stack";
NSString *const OPT_OPERATIONS = @"operations";
NSString *const OPT_IGNORE_FAIL = @"ignore-fail";
NSString *const OPT_REPEAT = @"repeat";
NSString *const OPT_REPEAT_LAST = @"repeat-last";
NSString *const OPT_SORT_TITLE = @"sort-title";
NSString *const OPT_MAIN_FIRST = @"main-first";
NSString *const OPT_MAIN_LAST = @"main-last";
NSString *const OPT_TITLE_ORDER = @"title-order";
NSString *const OPT_TITLE_ORDER_REGEX = @"title-order-regex";
NSString *const OPT_BEFORE = @"_before_";
NSString *const OPT_AFTER = @"_after_";