//
//  EverydayCityViewController.m
//  EverydayCity
//
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "EverydayCityViewController.h"


@implementation EverydayCityViewController

@synthesize currentTrackingProfile;
@synthesize currentLocationField, currentLocationActivityIndicator;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.currentTrackingProfile.selectedSegmentIndex = [self segmentIndexForTrackingProfile:[[LQTracker sharedTracker] profile]];
    [self refreshPushNotificationStatus];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

#pragma mark -

- (int)segmentIndexForTrackingProfile:(LQTrackerProfile)profile
{
    switch(profile) {
        case LQTrackerProfileOff:      return 0;
        case LQTrackerProfilePassive:  return 1;
        case LQTrackerProfileRealtime: return 2;
        case LQTrackerProfileLogging:  return 3;
    }
}

- (LQTrackerProfile)profileForSegmentIndex:(int)index
{
    switch(index) {
        case 0: return LQTrackerProfileOff;
        case 1: return LQTrackerProfilePassive;
        case 2: return LQTrackerProfileRealtime;
        case 3: return LQTrackerProfileLogging;
        default: return LQTrackerProfileOff;
    }
}

- (IBAction)trackingProfileWasTapped:(UISegmentedControl *)sender
{
    NSLog(@"Tapped %d", sender.selectedSegmentIndex);
    [[LQTracker sharedTracker] setProfile:[self profileForSegmentIndex:sender.selectedSegmentIndex]];
}

#pragma mark -

- (IBAction)registerForPushWasTapped:(UIButton *)sender
{
    [LQSession registerForPushNotificationsWithCallback:^(NSData *deviceToken, NSError *error) {
        [self refreshPushNotificationStatus];
        if(error){
            NSLog(@"Failed to register for push tokens: %@", error);
        } else {
            NSLog(@"Got a push token! %@", deviceToken);
        }
    }];
}

- (IBAction)getLocationButtonWasTapped:(UIButton *)sender
{
    self.currentLocationField.text = @"Loading...";
    self.currentLocationActivityIndicator.hidden = NO;
    NSURLRequest *req = [[LQSession savedSession] requestWithMethod:@"GET" path:@"/location/context" payload:nil];
    
	[[LQSession savedSession] runAPIRequest:req completion:^(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error) {
		NSLog(@"Response: %@ error:%@", responseDictionary, error);
        if(error) {
            self.currentLocationField.text = [error localizedDescription];
        } else {
            NSMutableArray *loc = [NSMutableArray arrayWithCapacity:4];
            if([responseDictionary objectForKey:@"intersection"]) {
                [loc addObject:[responseDictionary objectForKey:@"intersection"]];
            }
            if([responseDictionary objectForKey:@"locality_name"]) {
                [loc addObject:[responseDictionary objectForKey:@"locality_name"]];
            }
            if([responseDictionary objectForKey:@"region_name"]) {
                [loc addObject:[responseDictionary objectForKey:@"region_name"]];
            }
            if([responseDictionary objectForKey:@"country_name"]) {
                [loc addObject:[responseDictionary objectForKey:@"country_name"]];
            }
            self.currentLocationField.text = [loc componentsJoinedByString:@", "];
        }
        self.currentLocationActivityIndicator.hidden = YES;
	}];
}

@end
