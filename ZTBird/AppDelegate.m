//
//  AppDelegate.m
//  ZTBird
//
//  Created by Zhuo Tao on 2/22/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import "AppDelegate.h"
#import "BirdInfo.h"
#import "BirdImage.h"
#import "SpeciesViewController.h"
#import "FavoritesViewController.h"
#import "FirstViewController.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "NearbyViewController.h"


@interface AppDelegate ()   //class extension
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSArray *fetchedObjects;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //[self preloadData];   //preload birds info into core data
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    
    //pass managed context to first view controller
    UINavigationController *naviController = (UINavigationController *)tabBarController.viewControllers[0];
    FirstViewController *firstViewController = (FirstViewController *)[naviController topViewController];
    firstViewController.managedOjbectContext = self.managedObjectContext;
    
    //pass managed context to nearby view controller
    naviController = (UINavigationController *)tabBarController.viewControllers[1];
    NearbyViewController *nearbyController = (NearbyViewController *)[naviController topViewController];
    nearbyController.managedOjbectContext = self.managedObjectContext;
    
    //pass managed context to species view controller
    naviController = (UINavigationController *)tabBarController.viewControllers[2];
    SpeciesViewController *catalogViewController = (SpeciesViewController *)[naviController topViewController];
    catalogViewController.managedOjbectContext = self.managedObjectContext;
    
    //pass managed context to favorite view controller
    naviController = (UINavigationController *)tabBarController.viewControllers[3];
    FavoritesViewController *favoriteViewcontroller = (FavoritesViewController *)[naviController topViewController];
    favoriteViewcontroller.managedOjbectContext = self.managedObjectContext;
    
    UIColor* navColor = [UIColor colorWithRed:0.175f green:0.458f blue:0.831f alpha:1.0f];
    [[UINavigationBar appearance] setBarTintColor:navColor];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    //UIColor *barColor = [UIColor colorWithRed:0.012 green:0.286 blue:0.553 alpha:1.0];
    [tabBarController.tabBar setTintColor:navColor];
    
    //[self preLoadSpecies];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    //set tab bar item selected images;
    NSArray *array = tabBarController.tabBar.items;
    ((UITabBarItem *)array[2]).selectedImage = [UIImage imageNamed:@"Pelican Filled"];
    ((UITabBarItem *)array[0]).selectedImage = [UIImage imageNamed:@"Log Cabin Filled"];
    ((UITabBarItem *)array[1]).selectedImage = [UIImage imageNamed:@"Binoculars Filled"];
    ((UITabBarItem *)array[3]).selectedImage = [UIImage imageNamed:@"Like Filled"];

    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSError *error;
    if (self.managedObjectContext != nil) {
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
            //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel == nil) {
        NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"TaxonModel" ofType:@"momd"];
        NSURL *modelUrl = [NSURL fileURLWithPath:modelPath];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];
    }
    return _managedObjectModel;
}

- (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths lastObject];
    //NSLog(@"document directory: %@", documentsDirectory);
    return documentsDirectory;
}

- (NSString *)dataStorePath
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"DataStore.sqlite"];
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    if (_persistentStoreCoordinator == nil) {
        
        //if the expected store doesn't exist, copy the default store from main bundle
       if (![[NSFileManager defaultManager] fileExistsAtPath:[self dataStorePath]]) {
            NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"DataStore" ofType:@"sqlite"];
            if (defaultStorePath) {
                [[NSFileManager defaultManager] copyItemAtPath:defaultStorePath toPath:[self dataStorePath] error:NULL];
            }
       }
        
        NSURL *storeUrl = [NSURL fileURLWithPath:[self dataStorePath]];

        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        NSError *error;
        //NSDictionary *options = @{NSSQLitePragmasOption:@{@"journal_mode":@"DELETE"}};
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil
                                                                 URL:storeUrl
                                                             options:nil
                                                               error:&error]) {
            //NSLog(@"Error adding persistent store %@, %@", error, [error userInfo]);
            abort();
        }
    }
    [self addSkipBackupAttributeToItemAtPath:[self dataStorePath]];
    return _persistentStoreCoordinator;
}

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *) filePathString
{
    NSURL* URL= [NSURL fileURLWithPath: filePathString];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
      //  NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    //NSLog(@"Added %@",[NSNumber numberWithBool: success]);
    return success;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext == nil) {
        NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
        if (coordinator !=nil) {
            _managedObjectContext = [[NSManagedObjectContext alloc] init];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return _managedObjectContext;
}

- (void)preloadData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"acachecklist" ofType:@"txt"];
    NSError *error;
    NSString *allBirds = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (allBirds == nil) {
         //NSLog(@"Error reading file: %@",[error localizedDescription]);
    }
    NSArray *lines=[allBirds componentsSeparatedByString:@"\n"];
    unsigned long count = [lines count];
    NSArray *bird;
    for(int i=0;i<count;i++) {
        bird=[[lines objectAtIndex:i] componentsSeparatedByString:@"\t"];
        
        BirdInfo *info = [NSEntityDescription insertNewObjectForEntityForName:@"BirdInfo"
                                                       inManagedObjectContext:self.managedObjectContext];
        
        BirdImage *imageObj = [NSEntityDescription insertNewObjectForEntityForName:@"BirdImage"
                                                         inManagedObjectContext:self.managedObjectContext];
        
        UIImage *tempImage = [UIImage imageNamed:@"Placeholder"];
        imageObj.image = UIImageJPEGRepresentation(tempImage,1);
        
        info.category = [bird objectAtIndex:0];
        info.com_name = [bird objectAtIndex:1];
        info.sci_name = [bird objectAtIndex:2];
        //info.taxon_id = [bird objectAtIndex:2];
       info.thumbnailImage = imageObj;
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            //NSLog(@"Error: %@", error);
            abort();
        }
    }
}

- (void)preLoadSpecies
{
    NSManagedObjectContext *privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    privateContext.persistentStoreCoordinator = self.managedObjectContext.persistentStoreCoordinator;
    NSEntityDescription *entity = [NSEntityDescription insertNewObjectForEntityForName:@"BirdInfo"
                                                   inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *allSpeciesRequest = [[NSFetchRequest alloc] init];
    [allSpeciesRequest setEntity:entity];
    [privateContext performBlock:^{
        NSError *error;
        self.fetchedObjects = [privateContext executeFetchRequest:allSpeciesRequest error:&error];
        if (error) {
            //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }];
}

@end
