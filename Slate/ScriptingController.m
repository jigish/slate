//
//  ScriptingController.m
//  Slate
//
//  Created by Alex Morega on 2013-01-16.
//
//

#import "ScriptingController.h"

@implementation ScriptingController

static ScriptingController *_instance = nil;
static NSDictionary *jsMethods;

- (ScriptingController *) init {
    self = [super init];
    webView = [[WebView alloc] init];
    jsMethods = @{NSStringFromSelector(@selector(log:)): @"log"};
    return self;
}

- (void)run:(NSString*)code {
	NSString* script = [NSString stringWithFormat:@"try { %@ } catch (e) { e.toString() }", code];
	id data = [scriptObject evaluateWebScript:script];
	if(![data isMemberOfClass:[WebUndefined class]]) {
		NSLog(@"%@", data);
    }
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
