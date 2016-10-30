//
//  AppDelegate.m
//  Nosh
//
//  Created by Themesoft on 5/25/16.
//  Copyright © 2016 Themesoft. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#include <AudioToolbox/AudioToolbox.h>

@interface AppDelegate () {
NSMutableData *urlData;
     NSArray *orderArray;
    AVAudioPlayer *myAudioPlayer;
    CLLocationManager *clLocationManager;
    CLAuthorizationStatus authStatus;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    clLocationManager = [[CLLocationManager alloc] init];
    clLocationManager.delegate = (id)self;
    [clLocationManager requestAlwaysAuthorization];
    if ([self shouldFetchUserLocation]) {
        [clLocationManager startUpdatingLocation];
    }
    [self loadTimer];
    // Override point for customization after application launch.
    return YES;
}

-(BOOL)shouldFetchUserLocation{
    
    BOOL shouldFetchLocation= NO;
    
    return YES;
    
    if ([CLLocationManager locationServicesEnabled]) {
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusAuthorized:
                shouldFetchLocation= YES;
                break;
            case kCLAuthorizationStatusDenied:
            {
                UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"Error" message:@"App level settings has been denied" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
                alert= nil;
            }
                break;
            case kCLAuthorizationStatusNotDetermined:
            {
                UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"Error" message:@"The user is yet to provide the permission" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
                alert= nil;
            }
                break;
            case kCLAuthorizationStatusRestricted:
            {
                UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"Error" message:@"The app is recstricted from using location services." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
                alert= nil;
            }
                break;
                
            default:
                break;
        }
    }
    else{
        UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"Error" message:@"The location services seems to be disabled from the settings." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        alert= nil;
    }
    
    return shouldFetchLocation;
}
-(void)loadTimer {
    NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval: 20.0 target: self
                                                      selector: @selector(callAfterSixtySecond:) userInfo: nil repeats: YES];
}
-(void) callAfterSixtySecond:(NSTimer*) t
{
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate date];
    localNotification.alertBody = @"timer Calling";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    [self checkVersionUpdate];
    
}
-(void)checkVersionUpdate
{
    
    NSString *str = [[_configureDict objectForKey:@"message"]objectForKey:@"file_path"];
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:str]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:10.0];
    
    // Create the NSMutableData to hold the received data.
    // receivedData is an instance variable declared elsewhere.
    urlData = [NSMutableData dataWithCapacity: 0];
    
    
    [theRequest setHTTPMethod:@"POST"];
    //    NSString *postString = [NSString stringWithFormat:@"resturent_id=%@&username=%@&password=%@",_resturauntid.text,_userName.text,_password.text];
    //    [theRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    // create the connection with the request
    // and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection)
    {
        /* initialize the buffer */
        //urlData = [NSMutableData data];
        
        /* start the request */
        [theConnection start];
    }
    else
    {
        NSLog(@"Connection Failed");
    }
    
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    urlData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [urlData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    
    
    clLocationManager = [[CLLocationManager alloc] init];
    clLocationManager.delegate = self;
    [clLocationManager requestWhenInUseAuthorization];
    [clLocationManager startUpdatingLocation];

    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSError *jsonParsingError = nil;
        id object = [NSJSONSerialization JSONObjectWithData:urlData options:0 error:&jsonParsingError];
        if (jsonParsingError) {
            NSLog(@"JSON ERROR: %@", [jsonParsingError localizedDescription]);
        } else {
            NSLog(@"OBJECT: %@", (NSDictionary *)object);
            if([[(NSDictionary *)object objectForKey:@"error"] intValue])
            {
                
                
            }
            else {
                
                if ([[(NSDictionary *)object objectForKey:@"status"]integerValue] == 200) {
                    orderArray = [object objectForKey:@"orders"];
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    NSArray *arrayOfImages = [userDefaults objectForKey:@"noresponse"];
                    BOOL isAlreadyOrderPresent = false;
                    for (NSDictionary *obj in arrayOfImages) {
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"order_id == %@", [obj objectForKey:@"order_id"]];
                        NSArray *rejectedFilteredArray = [orderArray filteredArrayUsingPredicate:predicate];
                        if (rejectedFilteredArray.count) {
                            isAlreadyOrderPresent = YES;
                            break;
                        }
                    }
                    
                    NSMutableArray *array = [NSMutableArray arrayWithArray:arrayOfImages];
                    [array addObjectsFromArray:orderArray];
                    
                    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:array];
                    NSArray *arrayWithoutDuplicates = [orderedSet array];
                    [userDefaults setObject:arrayWithoutDuplicates forKey:@"noresponse"];
                    [userDefaults synchronize];
                    if (orderArray.count && !isAlreadyOrderPresent) {
                       [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadService" object:orderArray];
                    }
                }
            }
        }
    });
}



-(id)init
{
    self = [super init];
    
    clLocationManager = [[CLLocationManager alloc] init];
    clLocationManager.delegate = self;
    [clLocationManager requestWhenInUseAuthorization];
    [clLocationManager startUpdatingLocation];

    
    return self;
}

- (void)getCurrentLocation
{
}

- (BOOL)locationServicesAvailable
{
    BOOL servicesEnabled = [CLLocationManager locationServicesEnabled];
    authStatus = [CLLocationManager authorizationStatus];
    
    if (servicesEnabled && authStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        return YES;
    }
    return NO;
}



#pragma mark - CLLocationManager Delegate
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
//    if (!CLLocationCoordinate2DIsValid(currLocationCoord) || (fabs([newLocation.timestamp timeIntervalSinceNow]) < 600 && [newLocation distanceFromLocation:oldLocation] > 1000.0) )
//    {
//        // Within last 10 minutes, should be good enough if the accuracy is in the desired range
//        if (newLocation.horizontalAccuracy <= 1000)
//        {
//     
//        }
//    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    authStatus = status;
    
    if (status != kCLAuthorizationStatusAuthorizedWhenInUse && status != kCLAuthorizationStatusNotDetermined)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LocationManagerAuthDenied" object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LocationManagerAuthorized" object:nil];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LocationManagerCurrLocError" object:nil];
}

#pragma mark - Forward Geocoding


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.themesoft.Nosh" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Nosh" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Nosh.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
