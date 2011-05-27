//
//  Binding.m
//  Slate
//
//  Created by Jigish Patel on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Binding.h"
#import "Constants.h"
#import "MoveOperation.h"
#import "ResizeOperation.h"
#import "StringTokenizer.h"


@implementation Binding

@synthesize op;
@synthesize keyCode;
@synthesize modifiers;
@synthesize hotKeyRef;
@synthesize moveFirst;

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
    [self setMoveFirst:YES];
    
    // bind <key:modifiers> <op> <parameters>
    NSArray *tokens = [StringTokenizer tokenize:binding];
    if ([tokens count] <=2) {
      @throw([NSException exceptionWithName:@"Unrecognized Bind" reason:binding userInfo:nil]);
    }
    NSString *keystroke = [tokens objectAtIndex:1];
    NSArray *keyAndModifiers = [keystroke componentsSeparatedByString:COLON];
    if ([keyAndModifiers count] >= 1) {
      [self setKeyCode:(UInt32)[[[Binding asciiToCodeDict] objectForKey:[keyAndModifiers objectAtIndex:0]] integerValue]];
      [self setModifiers:0];
      if ([keyAndModifiers count] >= 2) {
        NSArray *modifiersArray = [[keyAndModifiers objectAtIndex:1] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",;"]];
        NSEnumerator *modEnum = [modifiersArray objectEnumerator];
        NSString *mod = [modEnum nextObject];
        while (mod) {
          if ([mod isEqualToString:CONTROL]) {
            modifiers += controlKey;
          } else if ([mod isEqualToString:OPTION]) {
            modifiers += optionKey;
          } else if ([mod isEqualToString:COMMAND]) {
            modifiers += cmdKey;
          } else if ([mod isEqualToString:SHIFT]) {
            modifiers += shiftKey;
          } else {
            NSLog(@"ERROR: Unrecognized modifier '%s'", [mod cStringUsingEncoding:NSASCIIStringEncoding]);
            @throw([NSException exceptionWithName:@"Unrecognized Modifier" reason:[NSString stringWithFormat:@"Unrecognized modifier '%@' in '%@'", mod, binding] userInfo:nil]);
          }
          mod = [modEnum nextObject];
        }
      }
    }
    NSString *opString = [tokens objectAtIndex:2];
    if ([opString isEqualToString:MOVE] && [tokens count] >= 5) {
      // bind <key:modifiers> move <topLeft> <dimensions> <optional:monitor>
      
      if ([binding rangeOfString:NEW_WINDOW_SIZE].location != NSNotFound) {
        [self setMoveFirst:NO];
      }
      
      [self setOp:[[MoveOperation alloc] initWithTopLeft:[tokens objectAtIndex:3] dimensions:[tokens objectAtIndex:4] monitor:([tokens count] >=6 ? [[tokens objectAtIndex:5] integerValue] : -1)]];
    } else if ([opString isEqualToString:RESIZE] && [tokens count] >= 5) {
      // bind <key:modifiers> resize <x> <y> <optional:anchor>
      NSString *anchor = TOP_LEFT;
      if ([tokens count] >= 6) {
        anchor = [tokens objectAtIndex:5];
      }
      [self setMoveFirst:NO];
      [self setOp:[[ResizeOperation alloc] initWithAnchor:anchor xResize:[tokens objectAtIndex:3] yResize:[tokens objectAtIndex:4]]];
    } else if ([opString isEqualToString:PUSH] && [tokens count] >= 4) {
      // bind <key:modifiers> push <top|bottom|up|down|left|right> <optional:none|center|bar|bar-resize:expression>
      NSString *direction = [tokens objectAtIndex:3];
      NSString *dimensions = @"windowSizeX,windowSizeY";
      NSString *topLeft = nil;
      NSString *style = NONE;
      if ([tokens count] >= 5) {
        style = [tokens objectAtIndex:4];
      }
      if ([direction isEqualToString:TOP] || [direction isEqualToString:UP]) {
        if ([style isEqualToString:CENTER]) {
          topLeft = @"screenOriginX+(screenSizeX-windowSizeX)/2,screenOriginY";
        } else if ([style isEqualToString:BAR]) {
          topLeft = @"screenOriginX,screenOriginY";
          dimensions = @"screenSizeX,windowSizeY";
        } else if ([style hasPrefix:BAR_RESIZE_WITH_VALUE]) {
          NSString *resizeExpression = [[style componentsSeparatedByString:COLON] objectAtIndex:1];
          topLeft = @"screenOriginX,screenOriginY";
          dimensions = [@"screenSizeX," stringByAppendingString:resizeExpression];
        } else if ([style isEqualToString:NONE]) {
          topLeft = @"windowTopLeftX,screenOriginY";
        } else {
          NSLog(@"ERROR: Unrecognized style '%s'", [style cStringUsingEncoding:NSASCIIStringEncoding]);
          @throw([NSException exceptionWithName:@"Unrecognized Style" reason:[NSString stringWithFormat:@"Unrecognized style '%@' in '%@'", style, binding] userInfo:nil]);
        }
      } else if ([direction isEqualToString:BOTTOM] || [direction isEqualToString:DOWN]) {
        if ([style isEqualToString:CENTER]) {
          topLeft = @"screenOriginX+(screenSizeX-windowSizeX)/2,screenOriginY+screenSizeY-windowSizeY";
        } else if ([style isEqualToString:BAR]) {
          topLeft = @"screenOriginX,screenOriginY+screenSizeY-windowSizeY";
          dimensions = @"screenSizeX,windowSizeY";
        } else if ([style hasPrefix:BAR_RESIZE_WITH_VALUE]) {
          NSString *resizeExpression = [[style componentsSeparatedByString:COLON] objectAtIndex:1];
          topLeft = [@"screenOriginX,screenOriginY+screenSizeY-" stringByAppendingString:resizeExpression];
          dimensions = [@"screenSizeX," stringByAppendingString:resizeExpression];
        } else if ([style isEqualToString:NONE]) {
          topLeft = @"windowTopLeftX,screenOriginY+screenSizeY-windowSizeY";
        } else {
          NSLog(@"ERROR: Unrecognized style '%s'", [style cStringUsingEncoding:NSASCIIStringEncoding]);
          @throw([NSException exceptionWithName:@"Unrecognized Style" reason:[NSString stringWithFormat:@"Unrecognized style '%@' in '%@'", style, binding] userInfo:nil]);
        }
      } else if ([direction isEqualToString:LEFT]) {
        if ([style isEqualToString:CENTER]) {
          topLeft = @"screenOriginX,screenOriginY+(screenSizeY-windowSizeY)/2";
        } else if ([style isEqualToString:BAR]) {
          topLeft = @"screenOriginX,screenOriginY";
          dimensions = @"windowSizeX,screenSizeY";
        } else if ([style hasPrefix:BAR_RESIZE_WITH_VALUE]) {
          NSString *resizeExpression = [[style componentsSeparatedByString:COLON] objectAtIndex:1];
          topLeft = @"screenOriginX,screenOriginY";
          dimensions = [resizeExpression stringByAppendingString:@",screenSizeY"];
        } else if ([style isEqualToString:NONE]) {
          topLeft = @"screenOriginX,windowTopLeftY";
        } else {
          NSLog(@"ERROR: Unrecognized style '%s'", [style cStringUsingEncoding:NSASCIIStringEncoding]);
          @throw([NSException exceptionWithName:@"Unrecognized Style" reason:[NSString stringWithFormat:@"Unrecognized style '%@' in '%@'", style, binding] userInfo:nil]);
        }
      } else if ([direction isEqualToString:RIGHT]) {
        if ([style isEqualToString:CENTER]) {
          topLeft = @"screenOriginX+screenSizeX-windowSizeX,screenOriginY+(screenSizeY-windowSizeY)/2";
        } else if ([style isEqualToString:BAR]) {
          topLeft = @"screenOriginX+screenSizeX-windowSizeX,screenOriginY";
          dimensions = @"windowSizeX,screenSizeY";
        } else if ([style hasPrefix:BAR_RESIZE_WITH_VALUE]) {
          NSString *resizeExpression = [[style componentsSeparatedByString:COLON] objectAtIndex:1];
          topLeft = [[@"screenOriginX+screenSizeX-" stringByAppendingString:resizeExpression] stringByAppendingString:@",screenOriginY"];
          dimensions = [resizeExpression stringByAppendingString:@",screenSizeY"];
        } else if ([style isEqualToString:NONE]) {
          topLeft = @"screenOriginX+screenSizeX-windowSizeX,windowTopLeftY";
        } else {
          NSLog(@"ERROR: Unrecognized style '%s'", [style cStringUsingEncoding:NSASCIIStringEncoding]);
          @throw([NSException exceptionWithName:@"Unrecognized Style" reason:[NSString stringWithFormat:@"Unrecognized style '%@' in '%@'", style, binding] userInfo:nil]);
        }
      } else {
        NSLog(@"ERROR: Unrecognized direction '%s'", [direction cStringUsingEncoding:NSASCIIStringEncoding]);
        @throw([NSException exceptionWithName:@"Unrecognized Direction" reason:[NSString stringWithFormat:@"Unrecognized direction '%@' in '%@'", direction, binding] userInfo:nil]);
      }
      [self setOp:[[MoveOperation alloc] initWithTopLeft:topLeft dimensions:dimensions monitor:-1]];
    } else if ([opString isEqualToString:NUDGE] && [tokens count] >= 5) {
      // bind <key:modifiers> nudge x y
      NSString *tlX = WINDOW_TOP_LEFT_X;
      NSString *x = [tokens objectAtIndex:3];
      if ([x hasSuffix:PERCENT]) {
        // % Nudge
        tlX = [tlX stringByAppendingString:[x stringByReplacingOccurrencesOfString:PERCENT withString:@"*windowSizeX/100"]];
      } else {
        // Hard Nudge
        tlX = [tlX stringByAppendingString:x];
      }

      NSString *tlY = WINDOW_TOP_LEFT_Y;
      NSString *y = [tokens objectAtIndex:4];
      if ([y hasSuffix:PERCENT]) {
        // % Nudge
        tlY = [tlY stringByAppendingString:[y stringByReplacingOccurrencesOfString:PERCENT withString:@"*windowSizeY/100"]];
      } else {
        // Hard Nudge
        tlY = [tlY stringByAppendingString:y];
      }
      [self setOp:[[MoveOperation alloc] initWithTopLeft:[[tlX stringByAppendingString:COMMA] stringByAppendingString:tlY] dimensions:@"windowSizeX,windowSizeY" monitor:-1]];
    } else if ([opString isEqualToString:THROW] && [tokens count] >= 4) {
      // bind <key:modifiers> throw <monitor> <optional:style (default is noresize)>
      NSString *tl = @"screenOriginX,screenOriginY";
      NSString *dim = @"windowSizeX,windowSizeY";
      if ([tokens count] >= 5) {
        NSString *style = [tokens objectAtIndex:4];
        if ([style isEqualToString:RESIZE]) {
          tl = @"screenOriginX,screenOriginY";
          dim = @"screenSizeX,screenSizeY";
        } else if ([style hasPrefix:RESIZE_WITH_VALUE]) {
          tl = @"screenOriginX,screenOriginY";
          dim = [[style componentsSeparatedByString:COLON] objectAtIndex:1];
        } else if ([style isEqualToString:NORESIZE]) {
          // do nothing
        } else {
          NSLog(@"ERROR: Unrecognized style '%s'", [style cStringUsingEncoding:NSASCIIStringEncoding]);
          @throw([NSException exceptionWithName:@"Unrecognized Style" reason:[NSString stringWithFormat:@"Unrecognized style '%@' in '%@'", style, binding] userInfo:nil]);
        }
      }
      [self setOp:[[MoveOperation alloc] initWithTopLeft:tl dimensions:dim monitor:[[tokens objectAtIndex:3] integerValue]]];
    } else if ([opString isEqualToString:CORNER] && [tokens count] >= 4) {
      // bind <key:modifiers> corner <top-left|top-right|bottom-left|bottom-right> <optional:resize:expression>
      NSString *tl = nil;
      NSString *dim = @"windowSizeX,windowSizeY";
      NSString *direction = [tokens objectAtIndex:3];

      if ([tokens count] >= 5) {
        NSString *style = [tokens objectAtIndex:4];
        if ([style hasPrefix:RESIZE_WITH_VALUE]) {
          dim = [[style componentsSeparatedByString:COLON] objectAtIndex:1];
        }
      }

      if ([direction isEqualToString:TOP_LEFT]) {
        tl = @"screenOriginX,screenOriginY";
      } else if ([direction isEqualToString:TOP_RIGHT]) {
        tl = [[@"screenOriginX+screenSizeX-" stringByAppendingString:[[dim componentsSeparatedByString:COMMA] objectAtIndex:0]] stringByAppendingString:@",screenOriginY"];
      } else if ([direction isEqualToString:BOTTOM_LEFT]) {
        tl = [@"screenOriginX,screenOriginY+screenSizeY-" stringByAppendingString:[[dim componentsSeparatedByString:COMMA] objectAtIndex:1]];
      } else if ([direction isEqualToString:BOTTOM_RIGHT]) {
        tl = [[[@"screenOriginX+screenSizeX-" stringByAppendingString:[[dim componentsSeparatedByString:COMMA] objectAtIndex:0]] stringByAppendingString:@",screenOriginY+screenSizeY-"] stringByAppendingString:[[dim componentsSeparatedByString:COMMA] objectAtIndex:1]];
      } else {
        NSLog(@"ERROR: Unrecognized corner '%s'", [direction cStringUsingEncoding:NSASCIIStringEncoding]);
        @throw([NSException exceptionWithName:@"Unrecognized Corner" reason:[NSString stringWithFormat:@"Unrecognized corner '%@' in '%@'", direction, binding] userInfo:nil]);
      }

      [self setOp:[[MoveOperation alloc] initWithTopLeft:tl dimensions:dim monitor:-1]];
    } else {
      NSLog(@"ERROR: Unrecognized operation '%s'", [opString cStringUsingEncoding:NSASCIIStringEncoding]);
      @throw([NSException exceptionWithName:@"Unrecognized Operation" reason:[NSString stringWithFormat:@"Unrecognized operation '%@' in '%@'", opString, binding] userInfo:nil]);
    }
    
    if (op == nil) {
      NSLog(@"ERROR: Unable to create binding");
      @throw([NSException exceptionWithName:@"Unable To Create Binding" reason:[NSString stringWithFormat:@"Unable to create '%@'", binding] userInfo:nil]);
    }
    
    @try {
      [op getDimensionsWithCurrentTopLeft:NSMakePoint(1,1) currentSize:NSMakeSize(1,1)];
      [op getTopLeftWithCurrentTopLeft:NSMakePoint(1,1) currentSize:NSMakeSize(1,1) newSize:NSMakeSize(1,1)];
    } @catch (NSException *ex) {
      NSLog(@"ERROR: Unable to test binding '%s'", [binding cStringUsingEncoding:NSASCIIStringEncoding]);
      @throw([NSException exceptionWithName:@"Unable To Parse Binding" reason:[NSString stringWithFormat:@"Unable to parse '%@' in '%@'", [ex reason], binding] userInfo:nil]);
    }
    [tokens release];
  }

  return self;
}

- (void)dealloc {
  [self setOp:nil];
  [self setHotKeyRef:nil];
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
