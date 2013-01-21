//
//  ScriptingController.h
//  Slate
//
//  Created by Alex Morega on 2013-01-16.
//
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "Operation.h"

@interface ScriptingController : NSObject {
  WebView *webView;
  WebScriptObject *scriptObject;
  NSMutableArray *bindings;
  NSMutableDictionary *operations;
  NSMutableDictionary *functions;
}
@property NSMutableArray *bindings;
@property NSMutableDictionary *operations;
@property NSMutableDictionary *functions;

- (void)loadConfig;
- (NSString *)addCallableFunction:(WebScriptObject *)function;
- (id)runCallableFunction:(NSString *)key;
+ (ScriptingController *)getInstance;

@end


@interface ScriptingOperation : Operation

@property WebScriptObject *function;
@property ScriptingController *controller;

+ (ScriptingOperation *)operationWithController:(ScriptingController*)controller function:(WebScriptObject*)function;

@end
