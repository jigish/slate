//
//  ScreenState.h
//  Slate
//
//  Created by Jigish Patel on 6/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ScreenState : NSObject {
@private
  NSString *layout;
  NSInteger type;
  NSInteger count;
  NSMutableArray *resolutions;
}

@property (retain) NSString *layout;
@property (assign) NSInteger type;
@property (assign) NSInteger count;
@property (retain) NSMutableArray *resolutions;

- (id)initWithString:(NSString *)state;

@end
