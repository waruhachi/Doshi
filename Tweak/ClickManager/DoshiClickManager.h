#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DoshiClickType) {
	DoshiClickTypeSingle = 1,
	DoshiClickTypeDouble = 2,
	DoshiClickTypeHold = 3,
};

typedef void (^DoshiClickCallback)(DoshiClickType clickType);

@interface DoshiClickManager : NSObject

@property (nonatomic, copy) DoshiClickCallback clickCallback;
@property (nonatomic, assign) NSTimeInterval clickTimeout;

+ (instancetype)sharedManager;
- (void)registerClick;
- (void)cancelPendingClicks;

@end
