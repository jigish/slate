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
