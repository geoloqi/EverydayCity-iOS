//
//  EverydayCityAppDelegate.h
//  EverydayCity
//
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

static NSString *const ECTrackingStateChanged = @"com.everydaycity.ECTrackingStateChanged";
static NSString *const ECDidLogInNotification = @"com.everydaycity.ECDidLogInNotification";

@class EverydayCityViewController;

@interface EverydayCityAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate,UIAlertViewDelegate, FBSessionDelegate> {
    Facebook *facebook;
}

@property (nonatomic, retain) Facebook *facebook;

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end

extern EverydayCityAppDelegate *appDelegate;
