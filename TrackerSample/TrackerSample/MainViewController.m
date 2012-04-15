//
//  MainViewController.m
//  EverydayCity
//
//  Created by Aaron Parecki on 2012-04-15.
//  Copyright (c) 2012 Geoloqi. All rights reserved.
//

#import "MainViewController.h"
#import "EverydayCityAppDelegate.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize welcomeViewController, cityViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.welcomeViewController = [[WelcomeViewController alloc] initWithNibName:nil bundle:nil];
        self.cityViewController = [[EverydayCityViewController alloc] initWithNibName:nil bundle:nil];
    }
    return self;
}

- (void)hideCurrentAndPresentModalViewController:(UIViewController *)_viewController 
                                    hideAnimated:(BOOL)hideAnimated 
                                    showAnimated:(BOOL)showAnimated {
    // NSLog(@"Current presented modal view: %@", [self presentedViewController]);
    if([self presentedViewController]) {
        // NSLog(@"Dismissing currently displayed view");
        [self dismissViewControllerAnimated:hideAnimated completion:^{
            // NSLog(@"Presenting modal view controller: %@", _viewController);
            [self presentModalViewController:_viewController animated:showAnimated];
        }];
    } else {
        // NSLog(@"Presenting modal view controller: %@", _viewController);
        [self presentModalViewController:_viewController animated:showAnimated];
    }
}

- (void)showCityView:(BOOL)animated {
    [self hideCurrentAndPresentModalViewController:self.cityViewController hideAnimated:NO showAnimated:animated];
}

- (void)showWelcomeView:(BOOL)animated {
    [self hideCurrentAndPresentModalViewController:self.welcomeViewController hideAnimated:YES showAnimated:animated];
}

- (void)showProperView:(BOOL)animated {
    if (![LQSession savedSession] || ![appDelegate.facebook isSessionValid]) {
        // NSLog(@"Showing Welcome View");
        [self showWelcomeView:animated];
    } else {
        // NSLog(@"Showing City View");
        [self showCityView:animated];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
