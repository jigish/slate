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

extern NSString *const SNAPSHOTS_FILE;

#define MODAL_BEGIN_ID 20000;
#define CURRENT_MODAL_BEGIN_ID 30000;
extern NSInteger const MODAL_ESCAPE_ID;

// Directive Keys
extern NSString *const BIND;
extern NSString *const CONFIG;
extern NSString *const DEFAULT;
extern NSString *const LAYOUT;
extern NSString *const ALIAS;
extern NSString *const SOURCE;

// Source Option Keys
extern NSString *const IF_EXISTS;

// Config Keys
extern NSString *const MENU_BAR_ICON_HIDDEN;
extern NSString *const MENU_BAR_ICON_HIDDEN_DEFAULT;
extern NSString *const DEFAULT_TO_CURRENT_SCREEN;
extern NSString *const DEFAULT_TO_CURRENT_SCREEN_DEFAULT;
extern NSString *const NUDGE_PERCENT_OF;
extern NSString *const NUDGE_PERCENT_OF_DEFAULT;
extern NSString *const RESIZE_PERCENT_OF;
extern NSString *const RESIZE_PERCENT_OF_DEFAULT;
extern NSString *const REPEAT_ON_HOLD_OPS;
extern NSString *const REPEAT_ON_HOLD_OPS_DEFAULT;
extern NSString *const SECONDS_BEFORE_REPEAT;
extern NSString *const SECONDS_BEFORE_REPEAT_DEFAULT;
extern NSString *const SECONDS_BETWEEN_REPEAT;
extern NSString *const SECONDS_BETWEEN_REPEAT_DEFAULT;
extern NSString *const CHECK_DEFAULTS_ON_LOAD;
extern NSString *const CHECK_DEFAULTS_ON_LOAD_DEFAULT;
extern NSString *const FOCUS_CHECK_WIDTH;
extern NSString *const FOCUS_CHECK_WIDTH_DEFAULT;
extern NSString *const FOCUS_CHECK_WIDTH_MAX;
extern NSString *const FOCUS_CHECK_WIDTH_MAX_DEFAULT;
extern NSString *const FOCUS_PREFER_SAME_APP;
extern NSString *const FOCUS_PREFER_SAME_APP_DEFAULT;
extern NSString *const ORDER_SCREENS_LEFT_TO_RIGHT;
extern NSString *const ORDER_SCREENS_LEFT_TO_RIGHT_DEFAULT;
extern NSString *const WINDOW_HINTS_FONT_NAME;
extern NSString *const WINDOW_HINTS_FONT_NAME_DEFAULT;
extern NSString *const WINDOW_HINTS_FONT_SIZE;
extern NSString *const WINDOW_HINTS_FONT_SIZE_DEFAULT;
extern NSString *const WINDOW_HINTS_FONT_COLOR;
extern NSString *const WINDOW_HINTS_FONT_COLOR_DEFAULT;
extern NSString *const WINDOW_HINTS_WIDTH;
extern NSString *const WINDOW_HINTS_WIDTH_DEFAULT;
extern NSString *const WINDOW_HINTS_HEIGHT;
extern NSString *const WINDOW_HINTS_HEIGHT_DEFAULT;
extern NSString *const WINDOW_HINTS_BACKGROUND_COLOR;
extern NSString *const WINDOW_HINTS_BACKGROUND_COLOR_DEFAULT;
extern NSString *const WINDOW_HINTS_DURATION;
extern NSString *const WINDOW_HINTS_DURATION_DEFAULT;
extern NSString *const WINDOW_HINTS_ROUNDED_CORNER_SIZE;
extern NSString *const WINDOW_HINTS_ROUNDED_CORNER_SIZE_DEFAULT;
extern NSString *const WINDOW_HINTS_IGNORE_HIDDEN_WINDOWS;
extern NSString *const WINDOW_HINTS_IGNORE_HIDDEN_WINDOWS_DEFAULT;
extern NSString *const WINDOW_HINTS_TOP_LEFT_X;
extern NSString *const WINDOW_HINTS_TOP_LEFT_X_DEFAULT;
extern NSString *const WINDOW_HINTS_TOP_LEFT_Y;
extern NSString *const WINDOW_HINTS_TOP_LEFT_Y_DEFAULT;
extern NSString *const WINDOW_HINTS_ORDER;
extern NSString *const WINDOW_HINTS_ORDER_DEFAULT;
extern NSString *const WINDOW_HINTS_SHOW_ICONS;
extern NSString *const WINDOW_HINTS_SHOW_ICONS_DEFAULT;
extern NSString *const WINDOW_HINTS_ICON_ALPHA;
extern NSString *const WINDOW_HINTS_ICON_ALPHA_DEFAULT;
extern NSString *const WINDOW_HINTS_SPREAD;
extern NSString *const WINDOW_HINTS_SPREAD_DEFAULT;
extern NSString *const WINDOW_HINTS_SPREAD_SEARCH_WIDTH;
extern NSString *const WINDOW_HINTS_SPREAD_SEARCH_WIDTH_DEFAULT;
extern NSString *const WINDOW_HINTS_SPREAD_SEARCH_HEIGHT;
extern NSString *const WINDOW_HINTS_SPREAD_SEARCH_HEIGHT_DEFAULT;
extern NSString *const WINDOW_HINTS_SPREAD_PADDING;
extern NSString *const WINDOW_HINTS_SPREAD_PADDING_DEFAULT;
extern NSString *const SWITCH_ICON_SIZE;
extern NSString *const SWITCH_ICON_SIZE_DEFAULT;
extern NSString *const SWITCH_ICON_PADDING;
extern NSString *const SWITCH_ICON_PADDING_DEFAULT;
extern NSString *const SWITCH_BACKGROUND_COLOR;
extern NSString *const SWITCH_BACKGROUND_COLOR_DEFAULT;
extern NSString *const SWITCH_SELECTED_BACKGROUND_COLOR;
extern NSString *const SWITCH_SELECTED_BACKGROUND_COLOR_DEFAULT;
extern NSString *const SWITCH_SELECTED_BORDER_COLOR;
extern NSString *const SWITCH_SELECTED_BORDER_COLOR_DEFAULT;
extern NSString *const SWITCH_SELECTED_BORDER_SIZE;
extern NSString *const SWITCH_SELECTED_BORDER_SIZE_DEFAULT;
extern NSString *const SWITCH_ROUNDED_CORNER_SIZE;
extern NSString *const SWITCH_ROUNDED_CORNER_SIZE_DEFAULT;
extern NSString *const SWITCH_ORIENTATION;
extern NSString *const SWITCH_ORIENTATION_DEFAULT;
extern NSString *const SWITCH_SECONDS_BEFORE_REPEAT;
extern NSString *const SWITCH_SECONDS_BEFORE_REPEAT_DEFAULT;
extern NSString *const SWITCH_SECONDS_BETWEEN_REPEAT;
extern NSString *const SWITCH_SECONDS_BETWEEN_REPEAT_DEFAULT;
extern NSString *const SWITCH_STOP_REPEAT_AT_EDGE;
extern NSString *const SWITCH_STOP_REPEAT_AT_EDGE_DEFAULT;
extern NSString *const SWITCH_ONLY_FOCUS_MAIN_WINDOW;
extern NSString *const SWITCH_ONLY_FOCUS_MAIN_WINDOW_DEFAULT;
extern NSString *const SWITCH_FONT_SIZE;
extern NSString *const SWITCH_FONT_SIZE_DEFAULT;
extern NSString *const SWITCH_FONT_COLOR;
extern NSString *const SWITCH_FONT_COLOR_DEFAULT;
extern NSString *const SWITCH_FONT_NAME;
extern NSString *const SWITCH_FONT_NAME_DEFAULT;
extern NSString *const SWITCH_SHOW_TITLES;
extern NSString *const SWITCH_SHOW_TITLES_DEFAULT;
extern NSString *const SWITCH_TYPE;
extern NSString *const SWITCH_TYPE_DEFAULT;
extern NSString *const SWITCH_SELECTED_PADDING;
extern NSString *const SWITCH_SELECTED_PADDING_DEFAULT;
extern NSString *const KEYBOARD_LAYOUT;
extern NSString *const KEYBOARD_LAYOUT_DEFAULT;
extern NSString *const SNAPSHOT_TITLE_MATCH;
extern NSString *const SNAPSHOT_TITLE_MATCH_DEFAULT;
extern NSString *const LEVENSHTEIN;
extern NSString *const SEQUENTIAL;
extern NSString *const SNAPSHOT_MAX_STACK_SIZE;
extern NSString *const SNAPSHOT_MAX_STACK_SIZE_DEFAULT;
extern NSString *const UNDO_MAX_STACK_SIZE;
extern NSString *const UNDO_MAX_STACK_SIZE_DEFAULT;
extern NSString *const UNDO_OPS;
extern NSString *const UNDO_OPS_DEFAULT;
extern NSString *const GRID_BACKGROUND_COLOR;
extern NSString *const GRID_BACKGROUND_COLOR_DEFAULT;
extern NSString *const GRID_ROUNDED_CORNER_SIZE;
extern NSString *const GRID_ROUNDED_CORNER_SIZE_DEFAULT;
extern NSString *const GRID_CELL_BACKGROUND_COLOR;
extern NSString *const GRID_CELL_BACKGROUND_COLOR_DEFAULT;
extern NSString *const GRID_CELL_SELECTED_COLOR;
extern NSString *const GRID_CELL_SELECTED_COLOR_DEFAULT;
extern NSString *const GRID_CELL_ROUNDED_CORNER_SIZE;
extern NSString *const GRID_CELL_ROUNDED_CORNER_SIZE_DEFAULT;
extern NSString *const LAYOUT_FOCUS_ON_ACTIVATE;
extern NSString *const LAYOUT_FOCUS_ON_ACTIVATE_DEFAULT;
extern NSString *const MODAL_ESCAPE_KEY;
extern NSString *const MODAL_ESCAPE_KEY_DEFAULT;
extern NSString *const JS_RECEIVE_MOVE_EVENT;
extern NSString *const JS_RECEIVE_MOVE_EVENT_DEFAULT;
extern NSString *const JS_RECEIVE_RESIZE_EVENT;
extern NSString *const JS_RECEIVE_RESIZE_EVENT_DEFAULT;

// Application Option Keys
extern NSString *const IGNORE_FAIL;
extern NSString *const REPEAT;
extern NSString *const REPEAT_LAST;
extern NSString *const SORT_TITLE;
extern NSString *const MAIN_FIRST;
extern NSString *const MAIN_LAST;
extern NSString *const TITLE_ORDER;
extern NSString *const TITLE_ORDER_REGEX;

// Modifier Keys
extern NSString *const CONTROL;
extern NSString *const COMMAND;
extern NSString *const OPTION;
extern NSString *const SHIFT;
extern NSString *const FUNCTION;
extern UInt32 const FUNCTION_KEY;

// Expression Keys
extern NSString *const SCREEN_ORIGIN_X;
extern NSString *const SCREEN_ORIGIN_Y;
extern NSString *const SCREEN_SIZE;
extern NSString *const SCREEN_SIZE_X;
extern NSString *const SCREEN_SIZE_Y;
extern NSString *const WINDOW_TOP_LEFT_X;
extern NSString *const WINDOW_TOP_LEFT_Y;
extern NSString *const WINDOW_SIZE_X;
extern NSString *const WINDOW_SIZE_Y;
extern NSString *const NEW_WINDOW_SIZE;
extern NSString *const NEW_WINDOW_SIZE_X;
extern NSString *const NEW_WINDOW_SIZE_Y;

// Operations
extern NSString *const MOVE;
extern NSString *const RESIZE;
extern NSString *const PUSH;
extern NSString *const NUDGE;
extern NSString *const THROW;
extern NSString *const CORNER;
extern NSString *const CHAIN;
extern NSString *const FOCUS;
extern NSString *const SNAPSHOT;
extern NSString *const ACTIVATE_SNAPSHOT;
extern NSString *const DELETE_SNAPSHOT;
extern NSString *const HINT;
extern NSString *const SWITCH;
extern NSString *const GRID;
extern NSString *const SEQUENCE;
extern NSString *const HIDE;
extern NSString *const SHOW;
extern NSString *const TOGGLE;
extern NSString *const RELAUNCH;
extern NSString *const SHELL;
extern NSString *const UNDO;

// Parameters and Options
extern NSString *const CENTER;
extern NSString *const BAR;
extern NSString *const BAR_RESIZE_WITH_VALUE;
extern NSString *const NONE;
extern NSString *const NORESIZE;
extern NSString *const RESIZE_WITH_VALUE;
extern NSString *const SAVE_TO_DISK;
extern NSString *const STACK;
extern NSString *const NAME;
extern NSString *const SNAPSHOTS;
extern NSString *const APPS;
extern NSString *const APP_NAME;
extern NSString *const TITLE;
extern NSString *const SIZE;
extern NSString *const ALL;
extern NSString *const DELETE;
extern NSString *const BACK;
extern NSString *const QUIT;
extern NSString *const FORCE_QUIT;
extern NSString *const WINDOW_HINTS_ORDER_NONE;
extern NSString *const WINDOW_HINTS_ORDER_PERSIST;
extern NSString *const WINDOW_HINTS_ORDER_LEFT_TO_RIGHT;
extern NSString *const WINDOW_HINTS_ORDER_RIGHT_TO_LEFT;
extern NSString *const SWITCH_ORIENTATION_HORIZONTAL;
extern NSString *const SWITCH_ORIENTATION_VERTICAL;
extern NSString *const KEYBOARD_LAYOUT_DVORAK;
extern NSString *const KEYBOARD_LAYOUT_COLEMAK;
extern NSString *const KEYBOARD_LAYOUT_AZERTY;
extern NSString *const PADDING;
extern NSString *const CURRENT;
extern NSString *const ALL_BUT;
extern NSString *const WAIT;
extern NSString *const PATH;
extern NSString *const APP_NAME_BEFORE;
extern NSString *const APP_NAME_AFTER;

// Directions and Anchors
extern NSString *const UP;
extern NSString *const DOWN;
extern NSString *const LEFT;
extern NSString *const RIGHT;
extern NSString *const TOP;
extern NSString *const BOTTOM;
extern NSString *const ABOVE;
extern NSString *const BELOW;
extern NSString *const NEXT;
extern NSString *const PREVIOUS;
extern NSString *const PREV;
extern NSString *const BEHIND;
extern NSString *const TOP_LEFT;
extern NSString *const TOP_RIGHT;
extern NSString *const BOTTOM_LEFT;
extern NSString *const BOTTOM_RIGHT;
extern NSInteger const DIRECTION_UNKNOWN;
extern NSInteger const DIRECTION_UP;
extern NSInteger const DIRECTION_DOWN;
extern NSInteger const DIRECTION_LEFT;
extern NSInteger const DIRECTION_RIGHT;
extern NSInteger const DIRECTION_TOP;
extern NSInteger const DIRECTION_BOTTOM;
extern NSInteger const DIRECTION_ABOVE;
extern NSInteger const DIRECTION_BELOW;
extern NSInteger const DIRECTION_BEHIND;
extern NSInteger const ANCHOR_TOP_LEFT;
extern NSInteger const ANCHOR_TOP_RIGHT;
extern NSInteger const ANCHOR_BOTTOM_LEFT;
extern NSInteger const ANCHOR_BOTTOM_RIGHT;

// Seperators and such
extern unichar const COMMENT_CHARACTER;
extern NSString *const COMMA;
extern NSString *const COLON;
extern NSString *const SEMICOLON;
extern NSString *const MINUS;
extern NSString *const PLUS;
extern NSString *const PERCENT;
extern NSString *const EMPTY;
extern NSString *const PIPE_PADDED;
extern NSString *const GREATER_THAN_PADDED;
extern NSString *const QUOTES;
extern NSString *const SPACE_WORD;
extern NSString *const EQUALS;
extern NSString *const TILDA;
extern NSString *const SLASH;
extern NSString *const X;
extern NSString *const Y;
extern NSString *const WIDTH;
extern NSString *const HEIGHT;
extern NSString *const WHITESPACE;

// Screen constants
extern NSString *const REF_CURRENT_SCREEN;
extern NSInteger const ID_MAIN_SCREEN;
extern NSInteger const ID_CURRENT_SCREEN;
extern NSInteger const ID_IGNORE_SCREEN;
extern NSInteger const TYPE_UNKNOWN;
extern NSInteger const TYPE_COUNT;
extern NSInteger const TYPE_RESOLUTIONS;
extern NSString *const COUNT;
extern NSString *const RESOLUTIONS;
extern NSString *const ORDERED;

// Notifications
extern NSString *const NOTIFICATION_SCREEN_CHANGE;
extern NSString *const NOTIFICATION_SCREEN_CHANGE_LION;

// Applications
extern NSString *const FINDER;

// Window Hint
extern NSInteger const HINT_X_PADDING;
extern NSString *const HINT_CHARACTERS;
extern NSInteger const MAIN_MENU_HEIGHT;

// Internal Snapshots
extern NSString *const MENU_SNAPSHOT;
extern NSString *const UNDO_SNAPSHOT;

// File Extensions
extern NSString *const EXT_JS;

// Javascript Operation Options Hash Keys
extern NSString *const OPT_STYLE;
extern NSString *const OPT_DIRECTION;
extern NSString *const OPT_SCREEN;
extern NSString *const OPT_X;
extern NSString *const OPT_Y;
extern NSString *const OPT_WIDTH;
extern NSString *const OPT_HEIGHT;
extern NSString *const OPT_ANCHOR;
extern NSString *const OPT_APP;
extern NSString *const OPT_COMMAND;
extern NSString *const OPT_WAIT;
extern NSString *const OPT_PATH;
extern NSString *const OPT_NAME;
extern NSString *const OPT_CHARACTERS;
extern NSString *const OPT_PADDING;
extern NSString *const OPT_GRIDS;
extern NSString *const OPT_BACK;
extern NSString *const OPT_QUIT;
extern NSString *const OPT_FORCE_QUIT;
extern NSString *const OPT_HIDE;
extern NSString *const OPT_DELETE;
extern NSString *const OPT_ALL;
extern NSString *const OPT_SAVE;
extern NSString *const OPT_STACK;
extern NSString *const OPT_OPERATIONS;
extern NSString *const OPT_IGNORE_FAIL;
extern NSString *const OPT_REPEAT;
extern NSString *const OPT_REPEAT_LAST;
extern NSString *const OPT_SORT_TITLE;
extern NSString *const OPT_MAIN_FIRST;
extern NSString *const OPT_MAIN_LAST;
extern NSString *const OPT_TITLE_ORDER;
extern NSString *const OPT_TITLE_ORDER_REGEX;
extern NSString *const OPT_BEFORE;
extern NSString *const OPT_AFTER;