#import "FKBaseViewController.h"

@interface FKBaseViewController ()

/** Recursively localizes views loaded from NIB */
- (void)localizeView:(UIView *)view;

@end

@implementation FKBaseViewController

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController
////////////////////////////////////////////////////////////////////////

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        sendInitialReachabilityNotification = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self localizeView:self.view];
    
    [[FKReachability sharedReachability] setupReachabilityFor:self
                                      sendInitialNotification:sendInitialReachabilityNotification];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [[FKReachability sharedReachability] shutdownReachabilityFor:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateUI];
    
    [[UIDevice currentDevice] simulateMemoryWarning];
    FKLogVerbose(@"Received simulated memory warning.");
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Rotation
////////////////////////////////////////////////////////////////////////

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return FKRotateToAllSupportedOrientations(toInterfaceOrientation);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self setupForInterfaceOrientation:toInterfaceOrientation];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark FKBaseViewController
////////////////////////////////////////////////////////////////////////

- (void)updateUI {
    [self setupForInterfaceOrientation:$appOrientation];
}

- (void)setupForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // UIView+FKRotation
    [self.view setSubviewFramesForInterfaceOrientation:interfaceOrientation];
}

- (void)localizeView:(UIView *)view {
    [view localizeViewLoadedFromNIB];
    
    for (UIView *subview in view.subviews) {
        [subview localizeViewLoadedFromNIB];
    }
}

@end
