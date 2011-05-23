//
//  Binding.m
//  Slate
//
//  Created by Jigish Patel on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Carbon/Carbon.h>
#import "Binding.h"
#import "MoveOperation.h"


@implementation Binding

@synthesize op;
@synthesize keyCode;
@synthesize modifiers;
@synthesize hotKeyRef;

- (id)init {
  self = [super init];
  if (self) {
    // Initialization code here.
  }

  return self;
}

- (id)initWithString: (NSString *)binding {
  self = [super init];
  if (self) {
    // bind <key:modifiers> <op> <parameters>
    NSArray *tokens = [binding componentsSeparatedByString:@" "];
    if ([tokens count] <=2)
      return self;
    NSString *keystroke = [tokens objectAtIndex:1];
    NSArray *keyAndModifiers = [keystroke componentsSeparatedByString:@":"];
    if ([keyAndModifiers count] >= 1) {
      keyCode = [[[Binding asciiToCodeDict] objectForKey:[keyAndModifiers objectAtIndex:0]] intValue];
      modifiers = 0;
      if ([keyAndModifiers count] >= 2) {
        NSArray *modifiersArray = [[keyAndModifiers objectAtIndex:1] componentsSeparatedByString:@","];
        NSEnumerator *modEnum = [modifiersArray objectEnumerator];
        NSString *mod = [modEnum nextObject];
        while (mod) {
          if ([mod isEqualToString:@"ctrl"]) {
            modifiers += controlKey;
          } else if ([mod isEqualToString:@"alt"]) {
            modifiers += optionKey;
          } else if ([mod isEqualToString:@"cmd"]) {
            modifiers += cmdKey;
          } else if ([mod isEqualToString:@"shift"]) {
            modifiers += shiftKey;
          }
          mod = [modEnum nextObject];
        }
      }
    }
    NSString *opString = [tokens objectAtIndex:2];
    if ([opString isEqualToString:@"move"] && [tokens count] >= 5) {
      // bind <key:modifiers> move <topLeft> <dimensions> <monitor>
      op = [[MoveOperation alloc] initWithTopLeft:[tokens objectAtIndex:3] dimensions:[tokens objectAtIndex:4] monitor:([tokens count] >=6 ? [[tokens objectAtIndex:5] intValue] : -1)];
    } else if ([opString isEqualToString:@"resize"] && [tokens count] >= 5) {
      // bind <key:modifiers> resize <x%> <y%>
      op = [[MoveOperation alloc] initWithTopLeft:@"windowTopLeftX,windowTopLeftY" dimensions:([[[[@"windowSizeX*" stringByAppendingString:[tokens objectAtIndex:3]] stringByAppendingString:@"/100,windowSizeY*"] stringByAppendingString:[tokens objectAtIndex:4]] stringByAppendingString:@"/100"]) monitor:-1];
    }
  }

  return self;
}

- (void)dealloc {
  [super dealloc];
}

// This returns a dictionary containing mappings from ASCII to keyCode
+ (NSDictionary *)asciiToCodeDict {
  static NSDictionary *dictionary = nil;
  
  if (dictionary == nil) {
    dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ASCIIToCode" ofType:@"plist"]];
  }
  return dictionary;
}

@end
