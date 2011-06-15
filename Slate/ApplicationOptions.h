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
}

@property (assign) BOOL ignoreFail;
@property (assign) BOOL repeat;

@end
