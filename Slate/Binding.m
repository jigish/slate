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

// Yes, this method is huge. Deal with it.
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
      // bind <key:modifiers> resize <x> <y> <optional:anchor>
      NSString *dimX = @"windowSizeX";
      NSString *x = [tokens objectAtIndex:3];
      NSString *xAugment = [x hasSuffix:@"%"] ? [x stringByReplacingOccurrencesOfString:@"%" withString:@"*windowSizeX/100"] : x;
      dimX = [dimX stringByAppendingString:xAugment];
      NSString *flippedXAugment = [x hasPrefix:@"+"] ? [xAugment stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:@"-"] : [xAugment stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:@"+"];

      NSString *dimY = @"windowSizeY";
      NSString *y = [tokens objectAtIndex:4];
      NSString *yAugment = [y hasSuffix:@"%"] ? [y stringByReplacingOccurrencesOfString:@"%" withString:@"*windowSizeY/100"] : y;
      dimY = [dimY stringByAppendingString:yAugment];
      NSString *flippedYAugment = [y hasPrefix:@"+"] ? [yAugment stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:@"-"] : [yAugment stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:@"+"];

      NSString *tlX = [@"windowTopLeftX" stringByAppendingString:flippedXAugment];
      NSString *tlY = [@"windowTopLeftY" stringByAppendingString:flippedYAugment];
      NSString *anchor = [tokens count] >= 6 ? [tokens objectAtIndex:5] : @"top-left";

      if ([anchor isEqualToString:@"top-left"]) {
        tlX = @"windowTopLeftX";
        tlY = @"windowTopLeftY";
      } else if ([anchor isEqualToString:@"top-right"]) {
        tlX = [@"windowTopLeftX" stringByAppendingString:flippedXAugment];
        tlY = @"windowTopLeftY";
      } else if ([anchor isEqualToString:@"bottom-left"]) {
        tlX = @"windowTopLeftX";
        tlY = [@"windowTopLeftY" stringByAppendingString:flippedYAugment];
      } else if ([anchor isEqualToString:@"bottom-right"]) {
        tlX = [@"windowTopLeftX" stringByAppendingString:flippedXAugment];
        tlY = [@"windowTopLeftY" stringByAppendingString:flippedYAugment];
      } else {
        NSLog(@"ERROR: Unrecognized anchor '%s'", [anchor cStringUsingEncoding:NSASCIIStringEncoding]);
        return nil;
      }

      op = [[MoveOperation alloc] initWithTopLeft:[[tlX stringByAppendingString:@","] stringByAppendingString:tlY] dimensions:[[dimX stringByAppendingString:@","] stringByAppendingString:dimY] monitor:-1];
    } else if ([opString isEqualToString:@"push"] && [tokens count] >= 4) {
      // bind <key:modifiers> push <top|bottom|up|down|left|right> <optional:none|center|bar|bar-resize:expression>
      NSString *direction = [tokens objectAtIndex:3];
      NSString *dimensions = @"windowSizeX,windowSizeY";
      NSString *topLeft = nil;
      NSString *style = @"none";
      if ([tokens count] >= 5) {
        style = [tokens objectAtIndex:4];
      }
      if ([direction isEqualToString:@"top"] || [direction isEqualToString:@"up"]) {
        if ([style isEqualToString:@"center"]) {
          topLeft = @"screenOriginX+(screenSizeX-windowSizeX)/2,screenOriginY";
        } else if ([style isEqualToString:@"bar"]) {
          topLeft = @"screenOriginX,screenOriginY";
          dimensions = @"screenSizeX,windowSizeY";
        } else if ([style hasPrefix:@"bar-resize:"]) {
          NSString *resizeExpression = [[style componentsSeparatedByString:@":"] objectAtIndex:1];
          topLeft = @"screenOriginX,screenOriginY";
          dimensions = [@"screenSizeX," stringByAppendingString:resizeExpression];
        } else {
          topLeft = @"windowTopLeftX,screenOriginY";
        }
      } else if ([direction isEqualToString:@"bottom"] || [direction isEqualToString:@"down"]) {
        if ([style isEqualToString:@"center"]) {
          topLeft = @"screenOriginX+(screenSizeX-windowSizeX)/2,screenOriginY+screenSizeY-windowSizeY";
        } else if ([style isEqualToString:@"bar"]) {
          topLeft = @"screenOriginX,screenOriginY+screenSizeY-windowSizeY";
          dimensions = @"screenSizeX,windowSizeY";
        } else if ([style hasPrefix:@"bar-resize:"]) {
          NSString *resizeExpression = [[style componentsSeparatedByString:@":"] objectAtIndex:1];
          topLeft = [@"screenOriginX,screenOriginY+screenSizeY-" stringByAppendingString:resizeExpression];
          dimensions = [@"screenSizeX," stringByAppendingString:resizeExpression];
        } else {
          topLeft = @"windowTopLeftX,screenOriginY+screenSizeY-windowSizeY";
        }
      } else if ([direction isEqualToString:@"left"]) {
        if ([style isEqualToString:@"center"]) {
          topLeft = @"screenOriginX,screenOriginY+(screenSizeY-windowSizeY)/2";
        } else if ([style isEqualToString:@"bar"]) {
          topLeft = @"screenOriginX,screenOriginY";
          dimensions = @"windowSizeX,screenSizeY";
        } else if ([style hasPrefix:@"bar-resize:"]) {
          NSString *resizeExpression = [[style componentsSeparatedByString:@":"] objectAtIndex:1];
          topLeft = @"screenOriginX,screenOriginY";
          dimensions = [resizeExpression stringByAppendingString:@",screenSizeY"];
        } else {
          topLeft = @"screenOriginX,windowTopLeftY";
        }
      } else if ([direction isEqualToString:@"right"]) {
        if ([style isEqualToString:@"center"]) {
          topLeft = @"screenOriginX+screenSizeX-windowSizeX,screenOriginY+(screenSizeY-windowSizeY)/2";
        } else if ([style isEqualToString:@"bar"]) {
          topLeft = @"screenOriginX+screenSizeX-windowSizeX,screenOriginY";
          dimensions = @"windowSizeX,screenSizeY";
        } else if ([style hasPrefix:@"bar-resize:"]) {
          NSString *resizeExpression = [[style componentsSeparatedByString:@":"] objectAtIndex:1];
          topLeft = [[@"screenOriginX+screenSizeX-" stringByAppendingString:resizeExpression] stringByAppendingString:@",screenOriginY"];
          dimensions = [resizeExpression stringByAppendingString:@",screenSizeY"];
        } else {
          topLeft = @"screenOriginX+screenSizeX-windowSizeX,windowTopLeftY";
        }
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
        } else if ([style hasPrefix:@"resize:"]) {
          tl = @"screenOriginX,screenOriginY";
          dim = [[style componentsSeparatedByString:@":"] objectAtIndex:1];
        }
      }
      op = [[MoveOperation alloc] initWithTopLeft:tl dimensions:dim monitor:[[tokens objectAtIndex:3] intValue]];
    } else if ([opString isEqualToString:@"corner"] && [tokens count] >= 4) {
      // bind <key:modifiers> corner <top-left|top-right|bottom-left|bottom-right> <optional:resize:expression>
      NSString *tl = nil;
      NSString *dim = @"windowSizeX,windowSizeY";
      NSString *direction = [tokens objectAtIndex:3];

      if ([tokens count] >= 5) {
        NSString *style = [tokens objectAtIndex:4];
        if ([style hasPrefix:@"resize:"]) {
          dim = [[style componentsSeparatedByString:@":"] objectAtIndex:1];
        }
      }

      if ([direction isEqualToString:@"top-left"]) {
        tl = @"screenOriginX,screenOriginY";
      } else if ([direction isEqualToString:@"top-right"]) {
        tl = [[@"screenOriginX+screenSizeX-" stringByAppendingString:[[dim componentsSeparatedByString:@","] objectAtIndex:0]] stringByAppendingString:@",screenOriginY"];
      } else if ([direction isEqualToString:@"bottom-left"]) {
        tl = [@"screenOriginX,screenOriginY+screenSizeY-" stringByAppendingString:[[dim componentsSeparatedByString:@","] objectAtIndex:1]];
      } else if ([direction isEqualToString:@"bottom-right"]) {
        tl = [[[@"screenOriginX+screenSizeX-" stringByAppendingString:[[dim componentsSeparatedByString:@","] objectAtIndex:0]] stringByAppendingString:@",screenOriginY+screenSizeY-"] stringByAppendingString:[[dim componentsSeparatedByString:@","] objectAtIndex:1]];
      } else {
        NSLog(@"ERROR: Unrecognized corner '%s'", [direction cStringUsingEncoding:NSASCIIStringEncoding]);
        return nil;
      }

      op = [[MoveOperation alloc] initWithTopLeft:tl dimensions:dim monitor:-1];
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
