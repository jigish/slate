//
//  JSController.m
//  Slate
//
//  Created by Alex Morega on 2013-01-16.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see http://www.gnu.org/licenses

#import "JSController.h"
#import "Binding.h"
#import "SlateLogger.h"
#import "SlateConfig.h"
#import "JSInfoWrapper.h"
#import "JSScreenWrapper.h"
#import "Constants.h"
#import "JSOperation.h"
#import "ShellUtils.h"
#import "JSApplicationWrapper.h"
#import "JSOperationWrapper.h"

@implementation JSController

@synthesize functions;
@synthesize eventCallbacks;

static JSController *_instance = nil;
static NSDictionary *jscJsMethods;

- (JSController *) init {
  self = [super init];
  if (self) {
    inited = NO;
    self.functions = [NSMutableDictionary dictionary];
    self.eventCallbacks = [NSMutableDictionary dictionary];
    webView = [[WebView alloc] init];
    [JSController setJsMethods];
  }
  return self;
}

- (id)run:(NSString*)code {
	NSString* script = [NSString stringWithFormat:@"try { %@ } catch (___ex___) { 'EXCEPTION: '+___ex___; }", code];
	id data = [scriptObject evaluateWebScript:script];
	if(![data isMemberOfClass:[WebUndefined class]]) {
		SlateLogger(@"%@", data);
    if ([data isKindOfClass:[NSString class]] && [data hasPrefix:@"EXCEPTION: "]) {
      @throw([NSException exceptionWithName:@"JavaScript Error" reason:data userInfo:nil]);
    }
  }
  return [self unmarshall:data];
}

- (NSString *)genFuncKey {
  return [NSString stringWithFormat:@"javascript:function[%ld]", [functions count]];
}

- (NSString *)addCallableFunction:(WebScriptObject *)function {
  NSString *key = [self genFuncKey];
  [functions setObject:function forKey:key];
  return key;
}

- (id)runCallableFunction:(NSString *)key {
  WebScriptObject *func = [functions objectForKey:key];
  if (func == nil) { return nil; }
  return [self runFunction:func];
}

- (id)runCallableFunction:(NSString *)functionName withArgument:(id)argument {
	// Find the function by name
	WebScriptObject *function = [functions objectForKey:functionName];
	// If the function wasn't found, then return nil instead of trying to call a non-existant function
	if(function == nil) return nil;
	// Run the function and return the result
	return [self runFunction:function withArg:argument];
}

- (id)runFunction:(WebScriptObject *)function {
  [scriptObject setValue:function forKey:@"_slate_callback"];
  return [self run:@"window._slate_callback();"];
}

- (id)runFunction:(WebScriptObject *)function withArg:(id)arg {
  [scriptObject setValue:function forKey:@"_slate_callback"];
  [scriptObject setValue:arg forKey:@"_slate_callback_arg"];
  return [self run:@"window._slate_callback(window._slate_callback_arg);"];
}

- (id)runFunction:(WebScriptObject *)function withArg:(id)arg secondArg:(id)arg2 {
  [scriptObject setValue:function forKey:@"_slate_callback"];
  [scriptObject setValue:arg forKey:@"_slate_callback_arg"];
  [scriptObject setValue:arg2 forKey:@"_slate_callback_arg2"];
  return [self run:@"window._slate_callback(window._slate_callback_arg, window._slate_callback_arg2);"];
}

- (BOOL)runFile:(NSString*)path {
  NSError *err;
  NSString *fileString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
  if(err == nil && fileString != nil && fileString != NULL) {
    [self run:fileString];
    return YES;
  }
  return NO;
}

- (void)setInfo {
  [scriptObject setValue:[JSInfoWrapper getInstance] forKey:@"_info"];
}

- (void)initializeWebView {
  if (inited) { return; }
  [[webView mainFrame] loadHTMLString:@"" baseURL:NULL];
  scriptObject = [webView windowScriptObject];
  [scriptObject setValue:self forKey:@"_controller"];
  [self setInfo];
  @try {
    [self runFile:[[NSBundle mainBundle] pathForResource:@"underscore" ofType:@"js"]];
    [self runFile:[[NSBundle mainBundle] pathForResource:@"utils" ofType:@"js"]];
    [self runFile:[[NSBundle mainBundle] pathForResource:@"initialize" ofType:@"js"]];
  } @catch (NSException *ex) {
    SlateLogger(@"   ERROR %@",[ex name]);
    NSAlert *alert = [SlateConfig warningAlertWithKeyEquivalents: [NSArray arrayWithObjects:@"Quit", @"Skip", nil]];
    [alert setMessageText:[ex name]];
    [alert setInformativeText:[ex reason]];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
      SlateLogger(@"User selected exit");
      [NSApp terminate:nil];
    }
  }
  inited = YES;
}

- (BOOL)loadConfigFileWithPath:(NSString *)path {
  [self initializeWebView];
  @try {
    return [self runFile:[path stringByExpandingTildeInPath]];
  } @catch (NSException *ex) {
    SlateLogger(@"   ERROR %@",[ex name]);
    NSAlert *alert = [SlateConfig warningAlertWithKeyEquivalents: [NSArray arrayWithObjects:@"Quit", @"Skip", nil]];
    [alert setMessageText:[ex name]];
    [alert setInformativeText:[ex reason]];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
      SlateLogger(@"User selected exit");
      [NSApp terminate:nil];
    }
  }
  return NO;
}

- (void)configFunction:(NSString *)key callback:(WebScriptObject *)callback {
  NSString *fkey = [self addCallableFunction:callback];
  [[[SlateConfig getInstance] configs] setValue:[NSString stringWithFormat:@"_javascript_::%@", fkey] forKey:key];
}

- (void)configNative:(NSString *)key callback:(id)callback {
  [[[SlateConfig getInstance] configs] setValue:[NSString stringWithFormat:@"%@", callback] forKey:key];
}

- (void)bindFunction:(NSString *)hotkey callback:(WebScriptObject *)callback repeat:(id)_repeat {
  JSOperation *op = [JSOperation jsOperationWithFunction:callback];
  BOOL repeat = NO;
  if (_repeat != nil && ([_repeat isKindOfClass:[NSNumber class]] || [_repeat isKindOfClass:[NSValue class]] || [_repeat isKindOfClass:[NSString class]])) {
    repeat = [_repeat boolValue];
  } else {
    repeat = [Operation isRepeatOnHoldOp:[op opName]];
  }
  @try {
    Binding *bind = [[Binding alloc] initWithKeystroke:hotkey operation:op repeat:repeat];
    [[SlateConfig getInstance] addBinding:bind];
  } @catch (NSException *ex) {
    SlateLogger(@"   ERROR %@",[ex name]);
    NSAlert *alert = [SlateConfig warningAlertWithKeyEquivalents: [NSArray arrayWithObjects:@"Quit", @"Skip", nil]];
    [alert setMessageText:[ex name]];
    [alert setInformativeText:[ex reason]];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
      SlateLogger(@"User selected exit");
      [NSApp terminate:nil];
    }
  }
}

- (void)bindNative:(NSString *)hotkey callback:(JSOperationWrapper *)opWrapper repeat:(id)_repeat {
  Operation *op = [opWrapper op];
  BOOL repeat = NO;
  if (_repeat != nil && ([_repeat isKindOfClass:[NSNumber class]] || [_repeat isKindOfClass:[NSValue class]] || [_repeat isKindOfClass:[NSString class]])) {
    repeat = [_repeat boolValue];
  } else {
    repeat = [Operation isRepeatOnHoldOp:[op opName]];
  }
  @try {
    Binding *bind = [[Binding alloc] initWithKeystroke:hotkey operation:op repeat:repeat];
    [[SlateConfig getInstance] addBinding:bind];
  } @catch (NSException *ex) {
    SlateLogger(@"   ERROR %@",[ex name]);
    NSAlert *alert = [SlateConfig warningAlertWithKeyEquivalents: [NSArray arrayWithObjects:@"Quit", @"Skip", nil]];
    [alert setMessageText:[ex name]];
    [alert setInformativeText:[ex reason]];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
      SlateLogger(@"User selected exit");
      [NSApp terminate:nil];
    }
  }
}

- (NSString *)layout:(NSString *)name hash:(WebScriptObject *)hash {
  NSMutableDictionary *dict = [[self unmarshall:hash] mutableCopy];
  for (NSString *app in [dict allKeys]) {
    id tmpDict = [dict objectForKey:app];
    if (![tmpDict isKindOfClass:[NSDictionary class]]) {
      continue;
    }
    NSMutableDictionary *appDict = [tmpDict mutableCopy];
    if ([appDict objectForKey:OPT_OPERATIONS] == nil) {
      continue;
    }
    id _operations = [appDict objectForKey:OPT_OPERATIONS];
    NSMutableArray *ops = [NSMutableArray array];
    if ([_operations isKindOfClass:[Operation class]]) {
      // this is an operation wrapper
      [ops addObject:_operations];
    } else if ([_operations isKindOfClass:[WebScriptObject class]]) {
      // this is a function
      Operation *op = [JSOperation jsOperationWithFunction:_operations];
      if (op == nil) { continue; }
      [ops addObject:op];
    } else if ([_operations isKindOfClass:[NSArray class]]) {
      // array of operations and/or functions
      for (id obj in _operations) {
        if ([obj isKindOfClass:[Operation class]]) {
          // this is an operation key
          [ops addObject:obj];
        } else if ([obj isKindOfClass:[WebScriptObject class]]) {
          // this is a function
          Operation *op = [JSOperation jsOperationWithFunction:obj];
          if (op == nil) { continue; }
          [ops addObject:op];
        }
      }
    }
    if ([ops count] == 0) { continue; }
    [appDict setObject:ops forKey:OPT_OPERATIONS];
    [dict setObject:appDict forKey:app];
  }
  if (![[SlateConfig getInstance] addLayout:name dict:dict]) { return nil; }
  return name;
}

- (void)default:(id)config toAction:(id)_action {
  id screenConfig = [self unmarshall:config];
  if ([screenConfig isKindOfClass:[NSNumber class]] || [screenConfig isKindOfClass:[NSValue class]] || [screenConfig isKindOfClass:[NSString class]]) {
    // count
  } else if ([screenConfig isKindOfClass:[NSArray class]]) {
    // resolutions
  } else {
    // wtf?
    return;
  }
  id action = [self unmarshall:_action];
  id name = nil;
  if ([action isKindOfClass:[NSString class]]) {
    name = action;
  } else if ([action isKindOfClass:[WebScriptObject class]]) {
    name = [JSOperation jsOperationWithFunction:action];
  } else {
    // wtf?
    return;
  }
  [[SlateConfig getInstance] addDefault:screenConfig layout:name];
}

- (NSString *)shell:(NSString *)commandAndArgs wait:(NSNumber *)wait path:(NSString *)path {
  if ([path isMemberOfClass:[WebUndefined class]]) {
    return [ShellUtils run:commandAndArgs wait:[wait boolValue] path:nil];
  }
  return [ShellUtils run:commandAndArgs wait:[wait boolValue] path:path];
}

- (JSOperationWrapper *)operation:(NSString *)name options:(WebScriptObject *)opts {
  @try {
    return [JSOperationWrapper operation:name options:opts];
  } @catch (NSException *ex) {
    SlateLogger(@"   ERROR %@",[ex name]);
    NSAlert *alert = [SlateConfig warningAlertWithKeyEquivalents: [NSArray arrayWithObjects:@"Quit", @"Skip", nil]];
    [alert setMessageText:[ex name]];
    [alert setInformativeText:[ex reason]];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
      SlateLogger(@"User selected exit");
      [NSApp terminate:nil];
    }
  }
  return nil;
}

- (BOOL)doOperation:(NSString *)op options:(id)opts {
  @try {
    id options = [self unmarshall:opts];
    if ([options isKindOfClass:[NSDictionary class]]) {
      return [Operation doOperation:op options:options aw:[[AccessibilityWrapper alloc] init] sw:[[ScreenWrapper alloc] init]];
    }
  } @catch (NSException *ex) {
    SlateLogger(@"   ERROR %@",[ex name]);
    NSAlert *alert = [SlateConfig warningAlertWithKeyEquivalents: [NSArray arrayWithObjects:@"Quit", @"Skip", nil]];
    [alert setMessageText:[ex name]];
    [alert setInformativeText:[ex reason]];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
      SlateLogger(@"User selected exit");
      [NSApp terminate:nil];
    }
  }
  return NO;
}

- (JSOperationWrapper *)operationFromString:(NSString *)opString {
  return [JSOperationWrapper operationFromString:opString];
}

- (BOOL)source:(NSString *)path {
  return [[SlateConfig getInstance] loadConfigFileWithPath:path];
}

- (void)log:(id)msg {
  NSLog(@"%@", msg);
}

- (BOOL)isValidEvent:(NSString *)what {
  return [what isEqualToString:@"windowClosed"] || [what isEqualToString:@"windowMoved"] || [what isEqualToString:@"windowResized"] ||
         [what isEqualToString:@"windowOpened"] || [what isEqualToString:@"windowFocused"] || [what isEqualToString:@"windowTitleChanged"] ||
         [what isEqualToString:@"appClosed"] || [what isEqualToString:@"appOpened"] || [what isEqualToString:@"appHidden"] ||
         [what isEqualToString:@"appUnhidden"] || [what isEqualToString:@"appDeactivated"] || [what isEqualToString:@"appActivated"] ||
         [what isEqualToString:@"screenConfigurationChanged"];
}

- (void)on:(NSString *)what do:(WebScriptObject *)callback {
  if (![self isValidEvent:what]) {
    SlateLogger(@"   ERROR: Invalid Event %@",what);
    NSAlert *alert = [SlateConfig warningAlertWithKeyEquivalents: [NSArray arrayWithObjects:@"Quit", @"Skip", nil]];
    [alert setMessageText:@"ERROR: Invalid Event"];
    [alert setInformativeText:what];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
      SlateLogger(@"User selected exit");
      [NSApp terminate:nil];
    }
  }
  if ([what isEqualToString:@"windowMoved"]) {
    [[SlateConfig getInstance] setConfig:JS_RECEIVE_MOVE_EVENT to:@"true"];
  } else if ([what isEqualToString:@"windowResized"]) {
    [[SlateConfig getInstance] setConfig:JS_RECEIVE_RESIZE_EVENT to:@"true"];
  }
  NSMutableArray *callbacks = [[self eventCallbacks] objectForKey:what];
  if (callbacks == nil) {
    callbacks = [NSMutableArray array];
    [[self eventCallbacks] setObject:callbacks forKey:what];
  }
  [callbacks addObject:callback];
}

- (void)runCallbacks:(NSString *)what payload:(id)payload {
  NSArray *callbacks = [[self eventCallbacks] objectForKey:what];
  if (callbacks == nil || [callbacks count] == 0) { return; }
  for (WebScriptObject *callback in callbacks) {
    [self runFunction:callback withArg:what secondArg:payload];
  }
}

- (WebScriptObject *)getJsArray:(NSArray *)arr {
  id type = [scriptObject callWebScriptMethod:@"_array_with_" withArguments:arr];
  if (![type isKindOfClass:[WebScriptObject class]]) {
    return nil;
  }
  return type;
}

- (WebScriptObject *)getJsArray {
  id type = [scriptObject callWebScriptMethod:@"_array_" withArguments:[NSArray array]];
  if ([type isKindOfClass:[WebScriptObject class]]) {
    return type;
  }
  return nil;
}

- (WebScriptObject *)getJsHash {
  id type = [scriptObject callWebScriptMethod:@"_hash_" withArguments:[NSArray array]];
  if ([type isKindOfClass:[WebScriptObject class]]) {
    return type;
  }
  return nil;
}

- (id)marshall:(id)obj {
  if (obj == nil) {
    return [WebUndefined undefined];
  }
  if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSValue class]] ||
      [obj isKindOfClass:[NSNumber class]]) {
    return obj;
  }
  if ([obj isKindOfClass:[NSDictionary class]]) {
    WebScriptObject *hash = [self getJsHash];
    for (NSString *key in [obj allKeys]) {
      [hash setValue:[obj objectForKey:key] forKey:key];
    }
    return hash;
  }
  if ([obj isKindOfClass:[NSArray class]]) {
    WebScriptObject *arr = [self getJsArray:obj];
    return arr;
  }
  return nil;
}

- (id)unmarshall:(id)obj {
  if (obj == nil || [obj isMemberOfClass:[WebUndefined class]]) {
    return nil;
  }
  if ([obj isKindOfClass:[JSOperationWrapper class]]) {
    return [obj op];
  }
  if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSValue class]] ||
      [obj isKindOfClass:[NSNumber class]]) {
    return obj;
  }
  if ([obj isKindOfClass:[JSScreenWrapper class]] || [obj isKindOfClass:[JSApplicationWrapper class]]) {
    return [obj toString];
  }
  if ([obj isKindOfClass:[WebScriptObject class]]) {
    return [self jsToSomething:obj];
  }
  return nil;
}

- (id)jsToSomething:(WebScriptObject *)obj {
  if (obj == nil) { return nil; }
  NSString *type = [self jsTypeof:obj];
  if (type == nil) { return nil; }
  if ([type isEqualToString:@"array"]) {
    return [self jsToArray:obj];
  }
  if ([type isEqualToString:@"function"]) {
    return obj;
  }
  if ([type isEqualToString:@"object"]) {
    return [self jsToDictionary:obj];
  }
  // nothing else should be here, primitives become NSString or NSValue or NSNumber
  return nil;
}

- (NSString *)jsTypeof:(WebScriptObject *)obj {
  id type = [scriptObject callWebScriptMethod:@"_typeof_" withArguments:[NSArray arrayWithObjects:obj, nil]];
  if ([type isKindOfClass:[NSString class]]) {
    return type; // should be a string
  }
  return @"unknown";
}

- (NSArray *)jsToArray:(WebScriptObject *)obj {
  UInt16 count = [[obj valueForKey:@"length"] unsignedIntValue];
  NSMutableArray *a = [NSMutableArray array];
  for (UInt16 i = 0; i < count; i++) {
    id item = [obj webScriptValueAtIndex:i];
    if (item == nil || [item isMemberOfClass:[WebUndefined class]]) {
      continue;
    }
    [a addObject:[self unmarshall:item]];
  }
  return a;
}

- (NSDictionary *)jsToDictionary:(WebScriptObject *)obj {
  NSMutableDictionary *ret = [NSMutableDictionary dictionary];
  if (obj == nil || [obj isMemberOfClass:[WebUndefined class]]) { return ret; }
  id keys = [scriptObject callWebScriptMethod:@"_keys_" withArguments:[NSArray arrayWithObjects:obj, nil]];
  NSArray *keyArr = [self jsToArray:keys];
  for(NSUInteger i = 0; i < [keyArr count]; i++) {
    NSString* key = [keyArr objectAtIndex:i];
    id ele = [obj valueForKey:key];
    if (ele == nil || [ele isMemberOfClass:[WebUndefined class]]) { continue; }
    [ret setObject:[self unmarshall:ele] forKey:key];
  }
  return ret;
}

+ (JSController *)getInstance {
  @synchronized([JSController class]) {
    if (!_instance)
      _instance = [[[JSController class] alloc] init];
    return _instance;
  }
}

+ (void)setJsMethods {
  jscJsMethods = @{
    NSStringFromSelector(@selector(log:)): @"log",
    NSStringFromSelector(@selector(bindFunction:callback:repeat:)): @"bindFunction",
    NSStringFromSelector(@selector(bindNative:callback:repeat:)): @"bindNative",
    NSStringFromSelector(@selector(configFunction:callback:)): @"configFunction",
    NSStringFromSelector(@selector(configNative:callback:)): @"configNative",
    NSStringFromSelector(@selector(doOperation:options:)): @"doOperation",
    NSStringFromSelector(@selector(operation:options:)): @"operation",
    NSStringFromSelector(@selector(operationFromString:)): @"operationFromString",
    NSStringFromSelector(@selector(source:)): @"source",
    NSStringFromSelector(@selector(layout:hash:)): @"layout",
    NSStringFromSelector(@selector(default:toAction:)): @"default",
    NSStringFromSelector(@selector(shell:wait:path:)): @"shell",
    NSStringFromSelector(@selector(on:do:)): @"on",
  };
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel {
  return [jscJsMethods objectForKey:NSStringFromSelector(sel)] == NULL;
}

+ (NSString *)webScriptNameForSelector:(SEL)sel {
  return [jscJsMethods objectForKey:NSStringFromSelector(sel)];
}

@end