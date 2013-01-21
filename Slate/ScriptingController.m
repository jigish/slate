//
//  ScriptingController.m
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

#import "ScriptingController.h"
#import "Binding.h"
#import "SlateLogger.h"
#import "SlateConfig.h"

@implementation ScriptingController

@synthesize bindings, operations, functions;

static ScriptingController *_instance = nil;
static NSDictionary *jsMethods;

- (ScriptingController *) init {
  self = [super init];
  if (self) {
    inited = NO;
    self.bindings = [NSMutableArray array];
    self.operations = [NSMutableDictionary dictionary];
    self.functions = [NSMutableDictionary dictionary];
    webView = [[WebView alloc] init];
    jsMethods = @{
      NSStringFromSelector(@selector(log:)): @"log",
      NSStringFromSelector(@selector(bindFunction:callback:repeat:)): @"bindFunction",
      NSStringFromSelector(@selector(bindNative:callback:repeat:)): @"bindNative",
      NSStringFromSelector(@selector(configFunction:callback:)): @"configFunction",
      NSStringFromSelector(@selector(configNative:callback:)): @"configNative",
      NSStringFromSelector(@selector(doOperation:)): @"doOperation",
      NSStringFromSelector(@selector(operation:options:)): @"operation",
      NSStringFromSelector(@selector(operationFromString:)): @"operationFromString",
    };
  }
  return self;
}

- (id)run:(NSString*)code {
	NSString* script = [NSString stringWithFormat:@"try { %@ } catch (___ex___) { 'EXCEPTION: '+___ex___.toString(); }", code];
	id data = [scriptObject evaluateWebScript:script];
	if(![data isMemberOfClass:[WebUndefined class]]) {
		SlateLogger(@"%@", data);
    if ([data isKindOfClass:[NSString class]] && [data hasPrefix:@"EXCEPTION: "]) {
      @throw([NSException exceptionWithName:@"JavaScript Error" reason:data userInfo:nil]);
    }
  }
  return [self returnedToSomething:data];
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

- (id)runFunction:(WebScriptObject*)function {
  [scriptObject setValue:function forKey:@"_slate_callback"];
  return [self run:@"window._slate_callback();"];
}

- (void)runFile:(NSString*)path {
  NSString *fileString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
  if(fileString != NULL) {
    [self run:fileString];
  }
}

- (void)initializeWebView {
  if (inited) { return; }
  [[webView mainFrame] loadHTMLString:@"" baseURL:NULL];
  scriptObject = [webView windowScriptObject];
  [scriptObject setValue:self forKey:@"_controller"];
  @try {
    [self runFile:[[NSBundle mainBundle] pathForResource:@"underscore" ofType:@"js"]];
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
    [self runFile:[path stringByExpandingTildeInPath]];
  } @catch (NSException *ex) {
    SlateLogger(@"   ERROR %@",[ex name]);
    NSAlert *alert = [SlateConfig warningAlertWithKeyEquivalents: [NSArray arrayWithObjects:@"Quit", @"Skip", nil]];
    [alert setMessageText:[ex name]];
    [alert setInformativeText:[ex reason]];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
      SlateLogger(@"User selected exit");
      [NSApp terminate:nil];
    }
    return NO;
  }
  return YES;
}

- (void)configFunction:(NSString *)key callback:(WebScriptObject *)callback {
  NSString *fkey = [self addCallableFunction:callback];
  [[[SlateConfig getInstance] configs] setValue:[NSString stringWithFormat:@"_javascript_::%@", fkey] forKey:key];
}

- (void)configNative:(NSString *)key callback:(id)callback {
  [[[SlateConfig getInstance] configs] setValue:[NSString stringWithFormat:@"%@", callback] forKey:key];
}

- (void)bindFunction:(NSString *)hotkey callback:(WebScriptObject *)callback repeat:(BOOL)repeat {
  ScriptingOperation *op = [ScriptingOperation operationWithController:self function:callback];
  Binding *bind = [[Binding alloc] initWithKeystroke:hotkey operation:op repeat:repeat];
  [self.bindings addObject:bind];
}

- (void)bindNative:(NSString *)hotkey callback:(NSString *)key repeat:(BOOL)repeat {
  Operation *op = [operations objectForKey:key];
  Binding *bind = [[Binding alloc] initWithKeystroke:hotkey operation:op repeat:repeat];
  [self.bindings addObject:bind];
}

- (NSString *)genOpKey {
  return [NSString stringWithFormat:@"javascript:operation[%ld]", [operations count]];
}

- (NSString *)operation:(NSString*)name options:(WebScriptObject *)opts {
  NSString *opKey = [self genOpKey];
  @try {
    Operation *op = [Operation operationWithName:name options:[self jsToDictionary:opts]];
    [operations setObject:op forKey:opKey];
    return opKey;
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

- (NSString *)operationFromString:(NSString *)opString {
  NSString *opKey = [self genOpKey];
  [operations setObject:[Operation operationFromString:opString] forKey:opKey];
  return opKey;
}

- (BOOL)doOperation:(NSString *)key {
  @try {
    return [[operations objectForKey:key] doOperation];
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

- (void)log:(NSString*)msg {
  SlateLogger(@"%@", msg);
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
    if ([item isKindOfClass:[NSString class]] || [item isKindOfClass:[NSValue class]]) {
      [a addObject:item];
    } else if ([item isKindOfClass:[WebScriptObject class]]) {
      [a addObject:[self jsToSomething:item]];
    }
  }
  return a;
}

- (id)returnedToSomething:(id)obj {
  if (obj == nil || [obj isMemberOfClass:[WebUndefined class]]) {
    return nil;
  }
  if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSValue class]]) {
    return obj;
  } else if ([obj isKindOfClass:[WebScriptObject class]]) {
    return [self jsToSomething:obj];
  }
  return nil;
}

- (id)jsToSomething:(WebScriptObject *)obj {
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
  if ([type isEqualToString:@"operation"]) {
    return [obj valueForKey:@"___objc"];
  }
  // nothing else should be here, primitives become NSString or NSValue
  return nil;
}

- (NSDictionary *)jsToDictionary:(WebScriptObject *)obj {
  NSMutableDictionary *ret = [NSMutableDictionary dictionary];
  if (obj == nil || [obj isMemberOfClass:[WebUndefined class]]) { return ret; }
  id keys = [scriptObject callWebScriptMethod:@"_keys_" withArguments:[NSArray arrayWithObjects:obj, nil]];
  NSArray *keyArr = [self jsToArray:keys];
  for(NSUInteger i = 0; i < [keyArr count]; i++) {
    NSString *key = [keyArr objectAtIndex:i];
    id ele = [obj valueForKey:key];
    if (ele == nil || [ele isMemberOfClass:[WebUndefined class]]) { continue; }
    if ([ele isKindOfClass:[NSString class]] || [ele isKindOfClass:[NSValue class]]) {
      [ret setObject:ele forKey:key];
    } else if ([ele isKindOfClass:[WebScriptObject class]]) {
      [ret setObject:[self jsToSomething:ele] forKey:key];
    }
  }
  return ret;
}

+ (ScriptingController *)getInstance {
  @synchronized([ScriptingController class]) {
    if (!_instance)
      _instance = [[[ScriptingController class] alloc] init];
    return _instance;
  }
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel {
  return [jsMethods objectForKey:NSStringFromSelector(sel)] == NULL;
}

+ (NSString *)webScriptNameForSelector:(SEL)sel {
  return [jsMethods objectForKey:NSStringFromSelector(sel)];
}

@end

@implementation ScriptingOperation

- init {
  self = [super init];
  if (self) {
    [self setOpName:@"scripting"];
  }
  return self;
}

- (BOOL)doOperation {
  [self.controller runFunction:self.function];
  return YES;
}

+ (ScriptingOperation *)operationWithController:(ScriptingController*)controller function:(WebScriptObject*)function {
  ScriptingOperation *op = [[ScriptingOperation alloc] init];
  [op setController:controller];
  [op setFunction:function];
  return op;
}

@end
