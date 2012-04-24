//
//  NSFileManager+ApplicationSupport.h
//  Slate
//
//  Created by Jigish Patel on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (ApplicationSupport)

- (NSURL *)applicationSupportDirectory;
- (NSURL *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory inDomain:(NSSearchPathDomainMask)domainMask append:(NSString *)appendComponent error:(NSError **)errorOut;

@end
