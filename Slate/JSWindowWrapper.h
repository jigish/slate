//
//  JSWindowWrapper.h
//  Slate
//
//  Created by Jigish Patel on 1/21/13.
//
//

#import <Foundation/Foundation.h>

@class AccessibilityWrapper;

@interface JSWindowWrapper : NSObject {
  AccessibilityWrapper *aw;
}
@property (strong) AccessibilityWrapper *aw;
- (id)initWithAccessibilityWrapper:(AccessibilityWrapper *)_aw;
@end
