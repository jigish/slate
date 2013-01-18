//
//  ScriptingController.m
//  Slate
//
//  Created by Alex Morega on 2013-01-16.
//
//

#import "ScriptingController.h"
#import "Binding.h"

@implementation ScriptingController

@synthesize bindings;

static ScriptingController *_instance = nil;
static NSDictionary *jsMethods;

- (ScriptingController *) init {
    self = [super init];
    self.bindings = [NSMutableArray array];
    webView = [[WebView alloc] init];
    jsMethods = @{
        NSStringFromSelector(@selector(log:)): @"log",
        NSStringFromSelector(@selector(bind:callback:)): @"bind"
    };
    return self;
}

- (void)run:(NSString*)code {
	NSString* script = [NSString stringWithFormat:@"try { %@ } catch (e) { e.toString() }", code];
	id data = [scriptObject evaluateWebScript:script];
	if(![data isMemberOfClass:[WebUndefined class]]) {
		NSLog(@"%@", data);
    }
}

- (void)runFunction:(WebScriptObject*)function {
    [scriptObject setValue:function forKey:@"_slate_callback"];
    [self run:@"window._slate_callback();"];
}

- (void)runFile:(NSString*)path {
    NSString *fileString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if(fileString != NULL) {
        [self run:fileString];
    }
}

- (void)loadConfig {
    [[webView mainFrame] loadHTMLString:@"" baseURL:NULL];
    scriptObject = [webView windowScriptObject];
    [scriptObject setValue:self forKey:@"slate"];
    [self runFile:[[NSBundle mainBundle] pathForResource:@"initialize" ofType:@"js"]];
    [self runFile:[@"~/.slate.js" stringByExpandingTildeInPath]];
}

- (void)bind:(NSString*)hotkey callback:(WebScriptObject*)callback {
    NSLog(@"bind() was called with %@", callback);
    ScriptingOperation *op = [ScriptingOperation operationWithController:self function:callback];
    Binding *bind = [[Binding alloc] initWithKeystroke:hotkey operation:op repeat:false];
    [self.bindings addObject:bind];
}

- (void)log:(NSString*)msg {
    NSLog(@"%@", msg);
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

+ (NSString *)webScriptNameForSelector:(SEL)sel
{
    return [jsMethods objectForKey:NSStringFromSelector(sel)];
}

@end


@implementation ScriptingOperation

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
