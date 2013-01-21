//
//  ScriptingController.h
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

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "Operation.h"

@interface ScriptingController : NSObject {
  WebView *webView;
  WebScriptObject *scriptObject;
  NSMutableArray *bindings;
  NSMutableDictionary *operations;
  NSMutableDictionary *functions;
  BOOL inited;
}
@property NSMutableArray *bindings;
@property NSMutableDictionary *operations;
@property NSMutableDictionary *functions;

- (BOOL)loadConfigFileWithPath:(NSString *)path;
- (NSString *)addCallableFunction:(WebScriptObject *)function;
- (id)runCallableFunction:(NSString *)key;
+ (ScriptingController *)getInstance;

@end


@interface ScriptingOperation : Operation

@property WebScriptObject *function;
@property ScriptingController *controller;

+ (ScriptingOperation *)operationWithController:(ScriptingController*)controller function:(WebScriptObject*)function;

@end
