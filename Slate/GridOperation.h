//
//  GridOperation.h
//  Slate
//
//  Created by Jigish Patel on 9/7/12.
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

#import <Carbon/Carbon.h>
#import "Operation.h"

@class ExpressionPoint;

@interface GridOperation : Operation {
  NSDictionary *screenConfigs;
  NSMutableArray *grids;
  EventHotKeyRef escHotKeyRef;
  AccessibilityWrapper *focusedWindow;
  NSInteger padding;
}

@property NSDictionary *screenConfigs;
@property NSMutableArray *grids;
@property AccessibilityWrapper *focusedWindow;
@property NSInteger padding;

- (id)initWithScreenConfigs:(NSDictionary *)myScreenConfigs padding:(NSInteger)myPadding;
- (void)killGrids;
- (void)activateGridKey:(NSInteger)hintId;
- (void)activateLayoutWithOrigin:(ExpressionPoint *)origin size:(ExpressionPoint *)size screenId:(NSInteger)screenId;

+ (id)gridOperationFromString:(NSString *) gridOperation;

@end
