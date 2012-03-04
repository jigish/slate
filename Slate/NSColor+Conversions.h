//
//  NSColor+Conversions.h
//  Slate
//
//  Created by Jigish Patel on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface NSColor (Conversions)

/**
 * Return CGColor representation of the NSColor in the RGB color space
 */
@property (readonly) CGColorRef cgColor;

/**
 * Create new NSColor from a CGColorRef
 */
+ (NSColor*)colorWithCGColor:(CGColorRef)aColor;

@end
