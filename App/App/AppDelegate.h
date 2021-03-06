// Part of iOSAppTemplate http://foundationk.it

#import "Reachability+FKAdditions.h"

@class FKBaseViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, FKReachabilityAware>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) FKBaseViewController *rootViewController;

@end
