#import "Doshi.h"

static BOOL longPressActive = NO;

// Calibration state
static BOOL calibrationMode = NO;
static NSTimeInterval calibrationFirstPress = 0;

static void disableArbiterMultiClick(id buttonInstance) {
	Ivar arbiterIvar = class_getInstanceVariable(object_getClass(buttonInstance), "_buttonArbiter");
	if (!arbiterIvar) return;
	id arbiter = object_getIvar(buttonInstance, arbiterIvar);
	if (!arbiter) return;

	SEL setMaxSel = NSSelectorFromString(@"setMaximumRepeatedPressCount:");
	if ([arbiter respondsToSelector:setMaxSel]) {
		((void (*)(id, SEL, unsigned long long))objc_msgSend)(arbiter, setMaxSel, 0);
	}
}

static void handleCalibrationPress(void) {
	NSTimeInterval now = [[NSProcessInfo processInfo] systemUptime];

	if (calibrationFirstPress == 0) {
		// First press — record and wait
		calibrationFirstPress = now;
		return;
	}

	// Second press — calculate interval
	double interval = now - calibrationFirstPress;
	calibrationFirstPress = 0;
	calibrationMode = NO;

	// Add 0.3s buffer so the user has some margin
	double timeout = interval + 0.3;
	if (timeout < 0.3) timeout = 0.3;
	if (timeout > 3.0) timeout = 3.0;

	// Save to preferences
	CFPreferencesSetAppValue(CFSTR("clickTimeout"),
		(__bridge CFPropertyListRef) @(timeout),
		CFSTR("moe.waru.doshi"));
	CFPreferencesAppSynchronize(CFSTR("moe.waru.doshi"));

	// Update the click manager
	[DoshiClickManager sharedManager].clickTimeout = timeout;

	// Notify preferences UI to refresh
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
		CFSTR("moe.waru.doshi.preferences.changed"),
		NULL, NULL, YES);

	// Post calibration result so Settings can show it
	NSString *resultStr = [NSString stringWithFormat:@"%.2f", interval];
	CFPreferencesSetAppValue(CFSTR("lastCalibrationInterval"),
		(__bridge CFPropertyListRef)resultStr,
		CFSTR("moe.waru.doshi"));
	CFPreferencesSetAppValue(CFSTR("lastCalibrationTimeout"),
		(__bridge CFPropertyListRef) @(timeout),
		CFSTR("moe.waru.doshi"));
	CFPreferencesAppSynchronize(CFSTR("moe.waru.doshi"));

	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
		CFSTR("moe.waru.doshi.calibration.done"),
		NULL, NULL, YES);
}

static void startCalibration(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	calibrationMode = YES;
	calibrationFirstPress = 0;
	[[DoshiClickManager sharedManager] cancelPendingClicks];
}

static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[[DoshiActionExecutor sharedExecutor] reloadPreferences];

	CFPreferencesAppSynchronize(CFSTR("moe.waru.doshi"));
	CFPropertyListRef val = CFPreferencesCopyAppValue(CFSTR("clickTimeout"), CFSTR("moe.waru.doshi"));
	if (val) {
		double timeout = [(__bridge NSNumber *)val doubleValue];
		[DoshiClickManager sharedManager].clickTimeout = timeout;
		CFRelease(val);
	}
}

// iOS 26+
%hook SBActionHardwareButton

- (void)_configureButtonArbiter {
	%orig;
	disableArbiterMultiClick(self);
}

- (void)performActionsForButtonDown:(id)event {
	if (calibrationMode) return;
	if (DoshiPerformingDefaultAction) {
		%orig;
		return;
	}
	[DoshiActionExecutor sharedExecutor].buttonInstance = self;
	[DoshiActionExecutor sharedExecutor].lastDownEvent = event;
}

- (void)performActionsForButtonUp:(id)event {
	if (calibrationMode) {
		handleCalibrationPress();
		return;
	}
	if (DoshiPerformingDefaultAction) {
		%orig;
		return;
	}
	if (longPressActive) {
		longPressActive = NO;
		return;
	}

	[[DoshiClickManager sharedManager] registerClick];
}

- (void)performActionsForButtonLongPress:(id)event {
	if (calibrationMode) return;
	if (DoshiPerformingDefaultAction) {
		%orig;
		return;
	}
	longPressActive = YES;
	[[DoshiClickManager sharedManager] cancelPendingClicks];
	[[DoshiActionExecutor sharedExecutor] executeActionForClickType:DoshiClickTypeHold];
}

%end

// iOS 17-18
%hook SBRingerHardwareButton

- (void)_configureButtonArbiter {
	%orig;
	disableArbiterMultiClick(self);
}

- (void)performActionsForButtonDown:(id)event {
	if (calibrationMode) return;
	if (DoshiPerformingDefaultAction) {
		%orig;
		return;
	}
	[DoshiActionExecutor sharedExecutor].buttonInstance = self;
	[DoshiActionExecutor sharedExecutor].lastDownEvent = event;
}

- (void)performActionsForButtonUp:(id)event {
	if (calibrationMode) {
		handleCalibrationPress();
		return;
	}
	if (DoshiPerformingDefaultAction) {
		%orig;
		return;
	}
	if (longPressActive) {
		longPressActive = NO;
		return;
	}

	[[DoshiClickManager sharedManager] registerClick];
}

- (void)performActionsForButtonLongPress:(id)event {
	if (calibrationMode) return;
	if (DoshiPerformingDefaultAction) {
		%orig;
		return;
	}
	longPressActive = YES;
	[[DoshiClickManager sharedManager] cancelPendingClicks];
	[[DoshiActionExecutor sharedExecutor] executeActionForClickType:DoshiClickTypeHold];
}

%end

%ctor {
	[DoshiClickManager sharedManager].clickCallback = ^(DoshiClickType clickType) {
		[[DoshiActionExecutor sharedExecutor] executeActionForClickType:clickType];
	};

	prefsChanged(NULL, NULL, NULL, NULL, NULL);

	CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(),
		NULL,
		prefsChanged,
		CFSTR("moe.waru.doshi.preferences.changed"),
		NULL,
		CFNotificationSuspensionBehaviorDeliverImmediately);

	CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(),
		NULL,
		startCalibration,
		CFSTR("moe.waru.doshi.calibration.start"),
		NULL,
		CFNotificationSuspensionBehaviorDeliverImmediately);
}
