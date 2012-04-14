//
//  EverydayCityAppDelegate.h
//  EverydayCity
//
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@class EverydayCityViewController;

@interface EverydayCityAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, FBSessionDelegate> {
    Facebook *facebook;
}

@property (nonatomic, retain) Facebook *facebook;

@property (strong, nonatomic) IBOutlet UIWindow *window;

@property (strong, nonatomic) IBOutlet UIViewController *viewController;

@end

extern EverydayCityAppDelegate *appDelegate;
