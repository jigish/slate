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
}

- (void)loadConfig;

+ (ScriptingController *)getInstance;

@end


@interface ScriptingOperation : Operation

@property WebScriptObject *function;
@property ScriptingController *controller;

+ (ScriptingOperation *)operationWithController:(ScriptingController*)controller function:(WebScriptObject*)function;

@end
