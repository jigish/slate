//
//  ApplicationOptions.h
//  Slate
//
//  Created by Jigish Patel on 6/14/11.
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

#import <Foundation/Foundation.h>


@interface ApplicationOptions : NSObject {
@private
  BOOL ignoreFail;
  BOOL repeat;
  BOOL repeatLast;
  BOOL mainFirst;
  BOOL mainLast;
  BOOL sortTitle;
  NSArray *titleOrder;
  NSArray *titleOrderRegex;
}

@property (assign) BOOL ignoreFail;
@property (assign) BOOL repeat;
@property (assign) BOOL repeatLast;
@property (assign) BOOL mainFirst;
@property (assign) BOOL mainLast;
@property (assign) BOOL sortTitle;
@property NSArray *titleOrder;
@property NSArray *titleOrderRegex;

@end
