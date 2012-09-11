//
//  GridView.m
//  Slate
//
//  Created by Jigish Patel on 9/7/12.
//  Copyright 2012 Jigish Patel. All rights reserved.
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

#import "GridView.h"
#import "GridCellView.h"
#import "SlateConfig.h"
#import "Constants.h"
#import "GridOperation.h"
#import "ExpressionPoint.h"

@implementation GridView

@synthesize op, width, height, padding, cellWidth, cellHeight, previousActiveRect;

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setGrid:[NSMutableArray array]];
    [self setWantsLayer:YES];
  }
  return self;
}

- (void)drawRect:(NSRect)dirtyRect {
  NSArray *bgColorArr = [[SlateConfig getInstance] getArrayConfig:GRID_BACKGROUND_COLOR];
  if ([bgColorArr count] < 4) bgColorArr = [GRID_BACKGROUND_COLOR_DEFAULT componentsSeparatedByString:SEMICOLON];
  NSColor *backgroundColor = [NSColor colorWithDeviceRed:[[bgColorArr objectAtIndex:0] floatValue]/255.0
                                                   green:[[bgColorArr objectAtIndex:1] floatValue]/255.0
                                                    blue:[[bgColorArr objectAtIndex:2] floatValue]/255.0
                                                   alpha:[[bgColorArr objectAtIndex:3] floatValue]];
  [backgroundColor set];
  float cornerSize = [[SlateConfig getInstance] getFloatConfig:GRID_ROUNDED_CORNER_SIZE];
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:cornerSize yRadius:cornerSize];
  [path fill];
}

- (void)addGridWithWidth:(NSInteger)myWidth height:(NSInteger)myHeight padding:(float)myPadding {
  [self setWidth:myWidth];
  [self setHeight:myHeight];
  [self setPadding:myPadding];
  float usableHeight = self.frame.size.height - [self padding]*2;
  float usableWidth = self.frame.size.width - [self padding]*2;
  float x = [self padding];
  float y = [self padding];
  [self setCellHeight:(usableHeight - (height-1)*[self padding])/height];
  [self setCellWidth:(usableWidth - (width-1)*[self padding])/width];
  for (NSInteger r = 0; r < height; r++) {
    NSMutableArray *rowArr = [NSMutableArray array];
    for (NSInteger c = 0; c < width; c++) {
      GridCellView *newView = [[GridCellView alloc] initWithFrame:NSMakeRect(x,y,[self cellWidth],[self cellHeight])];
      [self addSubview:newView];
      x += [self padding]+[self cellWidth];
      [rowArr addObject:newView];
    }
    x = [self padding];
    y += [self padding]+[self cellHeight];
    [[self grid] addObject:rowArr];
  }
}

- (NSRect)rectFromBegin:(NSPoint)begin end:(NSPoint)end {
  // 0,0 is bottom left
  float myWidth = self.bounds.size.width;
  float myHeight = self.bounds.size.height;
  float bX = begin.x < 0 ? 0 : (begin.x > myWidth ? myWidth : begin.x);
  float bY = begin.y < 0 ? 0 : (begin.y > myHeight ? myHeight : begin.y);
  float eX = end.x < 0 ? 0 : (end.x > myWidth ? myWidth : end.x);
  float eY = end.y < 0 ? 0 : (end.y > myHeight ? myHeight : end.y);
  float blX = 0;
  float blY = 0;
  float trX = 0;
  float trY = 0;
  if (bX <= eX) {
    blX = bX;
    trX = eX;
  } else { // bX > eX
    blX = eX;
    trX = bX;
  }
  if (bY <= eY) {
    blY = bY;
    trY = eY;
  } else { // bY > eY
    blY = eY;
    trY = bY;
  }
  NSLog(@"POINTS: %f,%f -> %f,%f", bX,bY,eX,eY);
  NSInteger cellX = [self linearPosToCell:blX cellLength:[self cellWidth] totalCells:[self width]];
  if (cellX >= [self width]) { cellX = [self width] - 1; }
  NSInteger cellY = [self linearPosToCell:blY cellLength:[self cellHeight] totalCells:[self height]];
  if (cellY >= [self height]) { cellY = [self height] - 1; }
  NSInteger endCellX = [self linearPosToCell:trX cellLength:[self cellWidth] totalCells:[self width]];
  if (endCellX >= [self width]) { endCellX = [self width] - 1; }
  NSInteger endCellY = [self linearPosToCell:trY cellLength:[self cellHeight] totalCells:[self height]];
  if (endCellY >= [self height]) { endCellY = [self height] - 1; }
  NSLog(@"CELLS: %ld,%ld -> %ld,%ld", cellX,cellY,endCellX,endCellY);
  return NSMakeRect(cellX, cellY, endCellX-cellX, endCellY-cellY);
}

- (NSInteger)linearPosToCell:(float)pos cellLength:(float)cellLength totalCells:(NSInteger)totalCells {
  return [[NSNumber numberWithFloat:totalCells*(pos/(cellLength*totalCells + [self padding]*(totalCells+1)))] integerValue];
}

- (void)activateCellsInRect:(NSRect)rect {
  if (NSEqualRects(rect, [self previousActiveRect])) {
    [self setPreviousActiveRect:rect];
    return;
  }
  [self setPreviousActiveRect:rect];
  NSLog(@"activate cells in: %f,%f,%f,%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
  for (NSInteger r = 0; r < height; r++) {
    for (NSInteger c = 0; c < width; c++) {
      if (r < rect.origin.y) {
        [[[[self grid] objectAtIndex:r] objectAtIndex:c] deactivate];
      } else if (c < rect.origin.x) {
        [[[[self grid] objectAtIndex:r] objectAtIndex:c] deactivate];
      } else if (r > rect.origin.y+rect.size.height) {
        [[[[self grid] objectAtIndex:r] objectAtIndex:c] deactivate];
      } else if (c > rect.origin.x+rect.size.width) {
        [[[[self grid] objectAtIndex:r] objectAtIndex:c] deactivate];
      } else {
        [[[[self grid] objectAtIndex:r] objectAtIndex:c] activate];
      }
    }
  }
  [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
  BOOL keepOn = YES;
  NSPoint mouseLoc;
  NSPoint initialMouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  NSRect activeRect;
  
  while (keepOn) {
    theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask |
                NSLeftMouseDraggedMask];
    mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:self];
    activeRect = [self rectFromBegin:initialMouseLoc end:mouseLoc];
    NSRect flippedRect = NSMakeRect(activeRect.origin.x, [self height]-1-(activeRect.origin.y+activeRect.size.height), activeRect.size.width+1, activeRect.size.height+1);
    switch ([theEvent type]) {
      case NSLeftMouseDragged:
        NSLog(@"Dragged - (%f,%f) -> (%f,%f)", initialMouseLoc.x, initialMouseLoc.y, mouseLoc.x, mouseLoc.y);
        [self activateCellsInRect:activeRect];
        break;
      case NSLeftMouseUp:
        NSLog(@"Up - (%f,%f)", mouseLoc.x, mouseLoc.y);
        // activate shit
        [[self op] activateLayoutWithOrigin:[[ExpressionPoint alloc] initWithX:[NSString stringWithFormat:@"screenOriginX+(screenSizeX*%f/%ld)", flippedRect.origin.x, [self width]]
                                                                             y:[NSString stringWithFormat:@"screenOriginY+(screenSizeY*%f/%ld)", flippedRect.origin.y, [self height]]]
                                       size:[[ExpressionPoint alloc] initWithX:[NSString stringWithFormat:@"screenSizeX*%f/%ld", flippedRect.size.width, [self width]]
                                                                             y:[NSString stringWithFormat:@"screenSizeY*%f/%ld", flippedRect.size.height, [self height]]]
                                   screenId:[[[ScreenWrapper alloc] init] getScreenIdForPoint:[NSEvent mouseLocation]]];
        [[self op] performSelectorOnMainThread:@selector(killGrids) withObject:nil waitUntilDone:NO];
        keepOn = NO;
        break;
      default:
        /* Ignore any other kind of event. */
        break;
    }
    
  };
  
  return;
}

@end
