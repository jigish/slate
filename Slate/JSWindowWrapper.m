//
//  JSWindowWrapper.m
//  Slate
//
//  Created by Jigish Patel on 1/21/13.
//
//

#import "JSWindowWrapper.h"
#import "AccessibilityWrapper.h"

@implementation JSWindowWrapper

static NSDictionary *swJsMethods;

@synthesize aw;

- (id)init {
  self = [super init];
  if (self) {
    [self setAw:[[AccessibilityWrapper alloc] init]];
    [JSWindowWrapper setJsMethods];
  }
  return self;
}

- (id)initWithAccessibilityWrapper:(AccessibilityWrapper *)_aw {
  self = [super init];
  if (self) {
    [self setAw:_aw];
    [JSWindowWrapper setJsMethods];
  }
  return self;
}

- (NSString *)title {
  return [aw getTitle];
}

+ (void)setJsMethods {
  if (swJsMethods == nil) {
    swJsMethods = @{
      NSStringFromSelector(@selector(title)): @"title",
    };
  }
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel {
  return [swJsMethods objectForKey:NSStringFromSelector(sel)] == NULL;
}

+ (NSString *)webScriptNameForSelector:(SEL)sel {
  return [swJsMethods objectForKey:NSStringFromSelector(sel)];
}

@end
