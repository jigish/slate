//
//  OperationUtil.h
//  Slate
//
//  Created by Jigish Patel on 5/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Operation.h"

@interface OperationUtil : NSObject {

}

+ (Operation *)operationFromString:(NSString *)opString;

+ (Operation *)moveOperationFromString:(NSString *)moveOperation;
+ (Operation *)resizeOperationFromString:(NSString *)moveOperation;
+ (Operation *)pushOperationFromString:(NSString *)moveOperation;
+ (Operation *)nudgeOperationFromString:(NSString *)moveOperation;
+ (Operation *)throwOperationFromString:(NSString *)moveOperation;
+ (Operation *)cornerOperationFromString:(NSString *)moveOperation;

@end
