//
//  Binding.h
//  Slate
//
//  Created by Jigish Patel on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Carbon/Carbon.h>
#import <Foundation/Foundation.h>
#import "Operation.h"


@interface Binding : NSObject {
@private
  Operation *op;
  UInt32 keyCode;
  UInt32 modifiers;
  EventHotKeyRef hotKeyRef;
}

+ (NSDictionary *)asciiToCodeDict;
- (id)initWithString: (NSString *)binding;

@property (assign) Operation *op;
@property (assign) UInt32 keyCode;
@property (assign) UInt32 modifiers;
@property (assign) EventHotKeyRef hotKeyRef;

@end
