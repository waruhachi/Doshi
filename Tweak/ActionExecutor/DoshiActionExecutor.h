#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/message.h>
#import <objc/runtime.h>

extern BOOL DoshiPerformingDefaultAction;

@interface DoshiActionExecutor : NSObject

@property (nonatomic, weak) id buttonInstance;
@property (nonatomic, strong) id lastDownEvent;

+ (instancetype)sharedExecutor;
- (void)executeActionForClickType:(NSInteger)clickType;
- (void)executeAction:(NSString *)actionID;
- (void)reloadPreferences;

@end