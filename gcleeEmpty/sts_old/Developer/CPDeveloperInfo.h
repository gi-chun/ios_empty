#import <Foundation/Foundation.h>

/******************************************************************************
 
 Enum Developer Mode
 
 ******************************************************************************/
typedef NS_ENUM(NSUInteger, developerModeStatus) {
    developerModeNone = 0,
    developerModeYes,
    developerModeNo,
	developerModeInputReady,
};

typedef NS_ENUM(NSInteger, developerViewOpenStatus) {
    developerviewClose = 0,
    developerviewOpen
};

@interface CPDeveloperInfo : NSObject
- (void)addLongPressedGestureInButtonItem:(UIButton *)viewItem;
- (void)openDeveloperContents;
@end
