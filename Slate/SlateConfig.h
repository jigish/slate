//
//  SlateConfig.h
//  Slate
//
//  Created by Jigish Patel on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SlateConfig : NSObject {
@private
  NSMutableDictionary *configs;
  NSMutableArray *bindings;
}

@property (retain) NSMutableDictionary *configs;
@property (retain) NSMutableArray *bindings;

+ (SlateConfig *)getInstance;
- (BOOL)load;

@end
