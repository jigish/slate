//
//  ApplicationOptions.h
//  Slate
//
//  Created by Jigish Patel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ApplicationOptions : NSObject {
@private
  BOOL ignoreFail;
  BOOL repeat;
  BOOL mainFirst;
  BOOL mainLast;
  BOOL sortTitle;
  NSArray *titleOrder;
}

@property (assign) BOOL ignoreFail;
@property (assign) BOOL repeat;
@property (assign) BOOL mainFirst;
@property (assign) BOOL mainLast;
@property (assign) BOOL sortTitle;
@property (retain) NSArray *titleOrder;

@end
