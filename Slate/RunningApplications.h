//
//  RunningApplications.h
//  Slate
//
//  Created by Jigish Patel on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RunningApplications : NSObject <NSFastEnumeration> {
  NSMutableArray *apps;
}

@property NSMutableArray *apps;

+ (RunningApplications *)getInstance;

@end
