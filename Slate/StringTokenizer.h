//
//  StringTokenizer.h
//  Slate
//
//  Created by Jigish Patel on 5/26/11.
//  Copyright 2011 Jigish Patel. All rights reserved.
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


@interface StringTokenizer : NSObject {}

+ (BOOL)isSpaceChar:(unichar)c;
+ (BOOL)isQuoteChar:(unichar)c quoteChars:(NSCharacterSet *)quoteChars;
+ (void)tokenize:(NSString *)s into:(NSMutableArray *)array;
+ (void)tokenize:(NSString *)s into:(NSMutableArray *)array maxTokens:(NSInteger)maxTokens;
+ (void)tokenize:(NSString *)s into:(NSMutableArray *)array maxTokens:(NSInteger)maxTokens quoteChars:(NSCharacterSet *)quotes;
+ (void)firstToken:(NSString *)s into:(NSMutableString *)token;
+ (NSString *)removeQuotes:(NSString *)s quoteChars:(NSCharacterSet *)quoteChars;

@end
