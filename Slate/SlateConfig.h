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

+ (SlateConfig *)getInstance;
+ (id)alloc;
- (BOOL)load;
- (NSMutableArray *)getBindings;

@end
