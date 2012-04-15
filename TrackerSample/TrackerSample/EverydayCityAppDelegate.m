//
//  EverydayCityAppDelegate.m
//  EverydayCity
//
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "EverydayCityAppDelegate.h"

#import "EverydayCityViewController.h"
#import "WelcomeViewController.h"

@interface LQSDKUtils : NSObject
+ (id)objectFromJSONData:(NSData *)data error:(NSError **)error;
+ (NSData *)dataWithJSONObject:(id)object error:(NSError **)error;
@end


EverydayCityAppDelegate *appDelegate;

@implementation EverydayCityAppDelegate {
}

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize facebook;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    appDelegate = self;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		
    // Sets your API Key and secret
	[LQSession setAPIKey:LQ_APIKey secret:LQ_APISecret];

    // Set up Facebook SDK
    facebook = [[Facebook alloc] initWithAppId:FB_APP_ID andDelegate:self];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    if (![LQSession savedSession] || ![facebook isSessionValid]) {
        self.window.rootViewController = self.viewController = [[WelcomeViewController alloc] initWithNibName:nil bundle:nil];
    } else {
        self.window.rootViewController = self.viewController = [[EverydayCityViewController alloc] initWithNibName:nil bundle:nil];
    }
    [self.window makeKeyAndVisible];
    
    // Tell the SDK the app finished launching so it can properly handle push notifications, etc
    [LQSession application:application didFinishLaunchingWithOptions:launchOptions];

    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
{
	//For push notification support, we need to get the push token from UIApplication via this method.
	//If you like, you can be notified when the relevant web service call to the Geoloqi API succeeds.
    [LQSession registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
{
    [LQSession handleDidFailToRegisterForRemoteNotifications:error];
}

/**
 * This is called when a push notification is received if the app is running in the foreground. If the app was in the
 * background when the push was received, this will be run as soon as the app is brought to the foreground by tapping the notification.
 * The SDK will also call this method in application:didFinishLaunchingWithOptions: if the app was launched because of a push notification.
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [LQSession handlePush:userInfo];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url]; 
}

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    NSLog(@"Logged in to Facebook! Token: %@ Expiration: %@", [facebook accessToken], [facebook expirationDate]);
    
    // Send FB token to the server
    NSURL *url = [NSURL URLWithString:@"http://everydaycity.com/api/users"];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url 
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                            timeoutInterval:10.0];
    
	[request setHTTPMethod:@"POST"];

    NSError *jsonError = nil;
    NSData *jsonData = [LQSDKUtils dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:[facebook accessToken], @"fb_access_token",
                                                       [NSNumber numberWithFloat:[[facebook expirationDate] timeIntervalSince1970]], @"fb_expiration_date", nil] 
                                                error:&jsonError];
    [request setHTTPBody:jsonData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];

    LQSession *tmpSession = [[LQSession alloc] init];
    [tmpSession runAPIRequest:request completion:^(NSHTTPURLResponse *response, NSDictionary *responseDictionary, NSError *error) {
        // On response, store the Geoloqi token and start tracking in passive mode
        NSLog(@"Response! %@", responseDictionary);
        if([responseDictionary objectForKey:@"lq_access_token"]) {
            [[LQTracker sharedTracker] setSession:[LQSession sessionWithAccessToken:[responseDictionary objectForKey:@"lq_access_token"]]];
            [[LQTracker sharedTracker] setProfile:LQTrackerProfilePassive];
            
            // Show the main app window
            [self.viewController presentViewController:[[EverydayCityViewController alloc] initWithNibName:nil bundle:nil] animated:YES completion:NULL]; 
            
        } else {
            // Error logging in
        }
    }];
}

- (void)fbDidLogout {
    NSLog(@"Logged out of Facebook!");

    // Log out of Geoloqi too
    [[LQTracker sharedTracker] setProfile:LQTrackerProfileOff];
    [[LQTracker sharedTracker] setSession:nil];
    [LQSession setSavedSession:nil];

    [self.viewController presentViewController:[[WelcomeViewController alloc] initWithNibName:nil bundle:nil] animated:YES completion:NULL]; 
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    
}

- (void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    
}

- (void)fbSessionInvalidated {
    
}

@end
