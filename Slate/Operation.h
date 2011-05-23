//
//  Operation.h
//  Slate
//
//  Created by Jigish Patel on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Operation : NSObject {
@private

}

- (NSPoint) getTopLeftWithCurrentTopLeft: (NSPoint)cTopLeft currentSize: (NSSize)cSize;
- (NSSize) getDimensionsWithCurrentTopLeft: (NSPoint)cTopLeft currentSize: (NSSize)cSize;

@end
