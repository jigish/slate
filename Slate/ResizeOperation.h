//
//  ResizeOperation.h
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

#import <Foundation/Foundation.h>
#import "Operation.h"


@interface ResizeOperation : Operation {
@private
  NSString *anchor;
  NSString *xResize;
  NSString *yResize;
}

@property (copy) NSString *anchor;
@property (copy) NSString *xResize;
@property (copy) NSString *yResize;

- (id)initWithAnchor:(NSString *)a xResize:(NSString *)x yResize:(NSString *)y;
- (NSPoint)getTopLeftWithCurrentTopLeft:(NSPoint)cTopLeft currentSize:(NSSize)cSize newSize:(NSSize)nSize;
- (NSSize)getDimensionsWithCurrentTopLeft:(NSPoint)cTopLeft currentSize:(NSSize)cSize;
- (NSInteger)resizeStringToInt:(NSString *)resize withValue:(NSInteger) val;

@end
