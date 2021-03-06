//
//  EverydayCityViewController.m
//  EverydayCity
//
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "EverydayCityViewController.h"
#import "EverydayCityAppDelegate.h"

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
    
    [[LQTracker sharedTracker] appDidBecomeActive];

    NSLog(@"Date of last location update: %@", [[LQTracker sharedTracker] dateOfLastLocationUpdate]);
    if([LQSession savedSession]) {
        [self getLocationButtonWasTapped:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(trackingStateChanged:)
												 name:ECTrackingStateChanged
											   object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUploadLocation:)
                                                 name:LQTrackerDidUploadLocationNotification
                                               object:nil];

    [self updateToggleState];
}

- (void)trackingStateChanged:(NSNotificationCenter *)notification
{
    [self updateToggleState];
}

- (void)didUploadLocation:(NSNotificationCenter *)notification
{
    [self getLocationButtonWasTapped:nil];
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

- (void)updateToggleState
{
    self.currentTrackingProfile.selectedSegmentIndex = [self segmentIndexForTrackingProfile:[[LQTracker sharedTracker] profile]];
}

- (IBAction)fbLogoutWasTapped:(UIButton *)sender 
{
    [[appDelegate facebook] logout];
}

- (int)segmentIndexForTrackingProfile:(LQTrackerProfile)profile
{
    switch(profile) {
        case LQTrackerProfileRough:    return 1;
        default:                       return 0;
    }
}

- (LQTrackerProfile)profileForSegmentIndex:(int)index
{
    switch(index) {
        case 1:  return LQTrackerProfileRough;
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
        if(error){
            NSLog(@"Failed to register for push tokens: %@", error);
        } else {
            NSLog(@"Got a push token! %@", deviceToken);
        }
    }];
}

- (void)viewRefreshTimerDidFire:(NSTimer *)timer {
    [self getLocationButtonWasTapped:nil];
}

- (IBAction)getLocationButtonWasTapped:(UIButton *)sender
{
    [[LQTracker sharedTracker] appDidBecomeActive];

    // self.currentLocationField.text = @"Loading...";
    self.currentLocationActivityIndicator.hidden = NO;

    NSURL *url = [NSURL URLWithString:@"http://everydaycity.com/api/status"];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url 
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                            timeoutInterval:10.0];
	[request setHTTPMethod:@"GET"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", [LQSession savedSession].accessToken] forHTTPHeaderField:@"Authorization"];
    
	[[LQSession savedSession] runAPIRequest:request completion:^(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error) {
		NSLog(@"Response: %@ error:%@", responseDictionary, error);
        if(error) {
            self.currentLocationField.text = @"";
            // If there was an error, set a timer to try updating the view again in a few seconds

            [NSTimer scheduledTimerWithTimeInterval:6.0
                                             target:self
                                           selector:@selector(viewRefreshTimerDidFire:)
                                           userInfo:nil
                                            repeats:NO];    
            
            
        } else {
            self.currentLocationField.text = [responseDictionary objectForKey:@"response"];
        }
        self.currentLocationActivityIndicator.hidden = YES;
        
	}];
}

@end
