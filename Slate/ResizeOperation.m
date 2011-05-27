//
//  ResizeOperation.m
//  Slate
//
//  Created by Jigish Patel on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ResizeOperation.h"


@implementation ResizeOperation

@synthesize anchor;
@synthesize xResize;
@synthesize yResize;

- (id)init {
  self = [super init];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (id)initWithAnchor:(NSString *)a xResize:(NSString *)x yResize:(NSString *)y {
  self = [super init];
  if (self) {
    if ([a isEqualToString:@"top-left"] || [a isEqualToString:@"top-right"] || [a isEqualToString:@"bottom-left"] || [a isEqualToString:@"bottom-right"]) {
      [self setAnchor:a];
    } else {
      NSLog(@"ERROR: Unrecognized anchor '%s'", [a cStringUsingEncoding:NSASCIIStringEncoding]);
      return nil;
    }
    [self setXResize:x];
    [self setYResize:y];
  }
  return self;
}

- (NSPoint) getTopLeftWithCurrentTopLeft:(NSPoint)cTopLeft currentSize:(NSSize)cSize newSize:(NSSize)nSize {
  if ([anchor isEqualToString:@"top-left"]) {
    return cTopLeft;
  } else if ([anchor isEqualToString:@"top-right"]) {
    NSInteger x = cTopLeft.x + cSize.width - nSize.width;
    NSInteger y = cTopLeft.y;
    return NSMakePoint(x,y);
  } else if ([anchor isEqualToString:@"bottom-left"]) {
    NSInteger x = cTopLeft.x;
    NSInteger y = cTopLeft.y + cSize.height - nSize.height;
    return NSMakePoint(x,y);
  } else if ([anchor isEqualToString:@"bottom-right"]) {
    NSInteger x = cTopLeft.x + cSize.width - nSize.width;
    NSInteger y = cTopLeft.y + cSize.height - nSize.height;
    return NSMakePoint(x,y);
  }
  return NSMakePoint(0,0);
}

// Assumes well-formed resize +100 or -10%
- (NSInteger) resizeStringToInt:(NSString *)resize withValue:(NSInteger) val {
  NSInteger sign = [resize hasPrefix:@"-"] ? -1 : 1;
  NSString *magnitude = [resize stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:@""];
  
  if ([magnitude hasSuffix:@"%"]) {
    magnitude = [magnitude stringByReplacingOccurrencesOfString:@"%" withString:@""];
    return (sign * val * [magnitude integerValue] / 100);
  } else {
    return (sign * [magnitude integerValue]);
  }
}

- (NSSize) getDimensionsWithCurrentTopLeft:(NSPoint)cTopLeft currentSize:(NSSize)cSize {
  NSInteger dimX = cSize.width + [self resizeStringToInt:xResize withValue:cSize.width];
  NSInteger dimY = cSize.height + [self resizeStringToInt:yResize withValue:cSize.height];
  return NSMakeSize(dimX,dimY);
}

- (void)dealloc {
  [self setAnchor:nil];
  [self setXResize:nil];
  [self setYResize:nil];
  [super dealloc];
}

@end
