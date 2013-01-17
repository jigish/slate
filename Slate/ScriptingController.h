//
//  ScriptingController.h
//  Slate
//
//  Created by Alex Morega on 2013-01-16.
//
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface ScriptingController : NSObject {
    WebView *webView;
    WebScriptObject *scriptObject;
}

- (void)loadConfig;

+ (ScriptingController *)getInstance;

@end


@interface ScriptingCallback : NSObject

@property WebScriptObject *function;
@property ScriptingController *controller;

- (void)call;

+ (ScriptingCallback *)callbackWithController:(ScriptingController*)controller function:(WebScriptObject*)function;

@end
