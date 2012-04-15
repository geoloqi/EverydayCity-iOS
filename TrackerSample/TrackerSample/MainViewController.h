//
//  MainViewController.h
//  EverydayCity
//
//  Created by Aaron Parecki on 2012-04-15.
//  Copyright (c) 2012 Geoloqi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EverydayCityViewController.h"
#import "WelcomeViewController.h"

@interface MainViewController : UIViewController

@property (strong, nonatomic) EverydayCityViewController *cityViewController;
@property (strong, nonatomic) WelcomeViewController *welcomeViewController;

- (void)showCityView:(BOOL)animated;
- (void)showWelcomeView:(BOOL)animated;

- (void)showProperView:(BOOL)animated;

@end
