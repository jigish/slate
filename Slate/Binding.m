//
//  Binding.m
//  Slate
//
//  Created by Jigish Patel on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Binding.h"
#import "MoveOperation.h"


@implementation Binding

@synthesize op;
@synthesize keyCode;
@synthesize modifiers;
@synthesize hotKeyRef;

static NSDictionary *dictionary = nil;

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
    if ([tokens count] <=2) {
      return nil;
    }
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
          } else {
            NSLog(@"ERROR: Unrecognized modifier '%s'", [mod cStringUsingEncoding:NSASCIIStringEncoding]);
          }
          mod = [modEnum nextObject];
        }
      }
    }
    NSString *opString = [tokens objectAtIndex:2];
    if ([opString isEqualToString:@"move"] && [tokens count] >= 5) {
      // bind <key:modifiers> move <topLeft> <dimensions> <optional:monitor>
      op = [[MoveOperation alloc] initWithTopLeft:[tokens objectAtIndex:3] dimensions:[tokens objectAtIndex:4] monitor:([tokens count] >=6 ? [[tokens objectAtIndex:5] intValue] : -1)];
    } else if ([opString isEqualToString:@"resize"] && [tokens count] >= 5) {
      // bind <key:modifiers> resize <x> <y>
      NSString *dimX = @"windowSizeX";
      NSString *x = [tokens objectAtIndex:3];
      if ([x hasSuffix:@"%"]) {
        // % Resize
        dimX = [dimX stringByAppendingString:[x stringByReplacingOccurrencesOfString:@"%" withString:@"*windowSizeX/100"]];
      } else {
        // Hard Resize
        dimX = [dimX stringByAppendingString:x];
      }

      NSString *dimY = @"windowSizeY";
      NSString *y = [tokens objectAtIndex:4];
      if ([y hasSuffix:@"%"]) {
        // % Resize
        dimY = [dimY stringByAppendingString:[y stringByReplacingOccurrencesOfString:@"%" withString:@"*windowSizeY/100"]];
      } else {
        // Hard Resize
        dimY = [dimY stringByAppendingString:y];
      }
      op = [[MoveOperation alloc] initWithTopLeft:@"windowTopLeftX,windowTopLeftY" dimensions:([[dimX stringByAppendingString:@","] stringByAppendingString:dimY]) monitor:-1];
    } else if ([opString isEqualToString:@"push"] && [tokens count] >= 4) {
      // bind <key:modifiers> push <top|bottom|up|down|left|right>
      NSString *direction = [tokens objectAtIndex:3];
      NSString *dimensions = @"windowSizeX,windowSizeY";
      NSString *topLeft = nil;
      if ([direction isEqualToString:@"top"] || [direction isEqualToString:@"up"]) {
        topLeft = @"windowTopLeftX,screenOriginY";
      } else if ([direction isEqualToString:@"bottom"] || [direction isEqualToString:@"down"]) {
        topLeft = @"windowTopLeftX,screenOriginY+screenSizeY-windowSizeY";
      } else if ([direction isEqualToString:@"left"]) {
        topLeft = @"screenOriginX,windowTopLeftY";
      } else if ([direction isEqualToString:@"right"]) {
        topLeft = @"screenOriginX+screenSizeX-windowSizeX,windowTopLeftY";
      } else {
        NSLog(@"ERROR: Unrecognized direction '%s'", [direction cStringUsingEncoding:NSASCIIStringEncoding]);
        return nil;
      }
      op = [[MoveOperation alloc] initWithTopLeft:topLeft dimensions:dimensions monitor:-1];
    } else if ([opString isEqualToString:@"nudge"] && [tokens count] >= 5) {
      // bind <key:modifiers> nudge x y
      NSString *tlX = @"windowTopLeftX";
      NSString *x = [tokens objectAtIndex:3];
      if ([x hasSuffix:@"%"]) {
        // % Nudge
        tlX = [tlX stringByAppendingString:[x stringByReplacingOccurrencesOfString:@"%" withString:@"*windowSizeX/100"]];
      } else {
        // Hard Nudge
        tlX = [tlX stringByAppendingString:x];
      }
      
      NSString *tlY = @"windowTopLeftY";
      NSString *y = [tokens objectAtIndex:4];
      if ([y hasSuffix:@"%"]) {
        // % Nudge
        tlY = [tlY stringByAppendingString:[y stringByReplacingOccurrencesOfString:@"%" withString:@"*windowSizeY/100"]];
      } else {
        // Hard Nudge
        tlY = [tlY stringByAppendingString:y];
      }
      op = [[MoveOperation alloc] initWithTopLeft:[[tlX stringByAppendingString:@","] stringByAppendingString:tlY] dimensions:@"windowSizeX,windowSizeY" monitor:-1];
    } else if ([opString isEqualToString:@"throw"] && [tokens count] >= 4) {
      // bind <key:modifiers> throw <monitor> <optional:style (default is noresize)>
      NSString *tl = @"screenOriginX,screenOriginY";
      NSString *dim = @"windowSizeX,windowSizeY";
      if ([tokens count] >= 5) {
        NSString *style = [tokens objectAtIndex:4];
        if ([style isEqualToString:@"resize"]) {
          tl = @"screenOriginX,screenOriginY";
          dim = @"screenSizeX,screenSizeY";
        }
      }
      op = [[MoveOperation alloc] initWithTopLeft:tl dimensions:dim monitor:[[tokens objectAtIndex:3] intValue]];
    } else {
      NSLog(@"ERROR: Unrecognized operation '%s'", [opString cStringUsingEncoding:NSASCIIStringEncoding]);
      return nil;
    }
  }

  return self;
}

- (void)dealloc {
  [super dealloc];
}

// This returns a dictionary containing mappings from ASCII to keyCode
+ (NSDictionary *)asciiToCodeDict {
  if (dictionary == nil) {
    dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ASCIIToCode" ofType:@"plist"]];
    [dictionary retain];
  }
  return dictionary;
}

@end
