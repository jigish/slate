//
//  StringTokenizer.h
//  Slate
//
//  Created by Jigish Patel on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StringTokenizer : NSObject {

}

+ (BOOL)isSpaceChar:(unichar)c;
+ (NSArray *)tokenize:(NSString *)s;
+ (NSArray *)tokenize:(NSString *)s maxTokens:(NSInteger) maxTokens;

@end
