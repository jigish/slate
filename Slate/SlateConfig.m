//
//  SlateConfig.m
//  Slate
//
//  Created by Jigish Patel on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SlateConfig.h"
#import "Binding.h"

@implementation SlateConfig
static SlateConfig *_instance = nil;

+ (SlateConfig *)getInstance {
  @synchronized([SlateConfig class]) {
    if (!_instance)
      _instance = [[[SlateConfig class] alloc] init];
    return _instance;
  }
}

- (id)init {
  self = [super init];
  if (self) {
    configs = [[NSMutableDictionary alloc] init];
    bindings = [[NSMutableArray alloc] initWithCapacity:10];
  }
  return self;
}

- (BOOL)load {
  NSLog(@"Loading config...");

  // Reset configs and bindings in case we are calling from menu
  configs = [[NSMutableDictionary alloc] init];
  bindings = [[NSMutableArray alloc] initWithCapacity:10];

  NSString *homeDir = NSHomeDirectory();
  NSString *configFile = [homeDir stringByAppendingString:@"/.slate"];
  NSString *fileString = [NSString stringWithContentsOfFile:configFile encoding:NSUTF8StringEncoding error:nil];
  if (fileString == nil)
    return NO;
  NSArray *lines = [fileString componentsSeparatedByString:@"\n"];

  NSEnumerator *e = [lines objectEnumerator];
  NSString *line = [e nextObject];
  while (line) {
    NSArray *tokens = [line componentsSeparatedByString:@" "];
      if ([tokens count] >= 3 && [[tokens objectAtIndex:0] isEqualToString:@"config"]) {
        // config <key> <value>
        NSLog(@"  LoadingC: %s",[line cStringUsingEncoding:NSASCIIStringEncoding]);
        [configs setObject:[tokens objectAtIndex:2] forKey:[tokens objectAtIndex:1]];
      } else if ([tokens count] >= 3 && [[tokens objectAtIndex:0] isEqualToString:@"bind"]) {
        // bind <key:modifiers> <op> <parameters>
        Binding *bind = [[Binding alloc] initWithString:line];
        if (bind != nil) {
          NSLog(@"  LoadingB: %s",[line cStringUsingEncoding:NSASCIIStringEncoding]);
          [bindings addObject:bind];
          [bind release];
        } else {
          NSLog(@"  ERROR LoadingB: %s",[line cStringUsingEncoding:NSASCIIStringEncoding]);
        }
      }
    line = [e nextObject];
  }

  NSLog(@"Config loaded.");
  return YES;
}

- (NSMutableArray *)getBindings {
  return bindings;
}

- (void)dealloc {
  [super dealloc];
}

@end
