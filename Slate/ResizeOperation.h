//
//  ResizeOperation.h
//  Slate
//
//  Created by Jigish Patel on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Operation.h"


@interface ResizeOperation : Operation {
  NSString *anchor;
  NSString *xResize;
  NSString *yResize;
}

@property (copy) NSString *anchor;
@property (copy) NSString *xResize;
@property (copy) NSString *yResize;

- (id)initWithAnchor:(NSString *)a xResize:(NSString *)x yResize:(NSString *)y;

- (NSInteger) resizeStringToInt:(NSString *)resize withValue:(NSInteger) val;

@end
