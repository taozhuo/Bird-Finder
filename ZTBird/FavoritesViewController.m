//
//  FavoritesViewController.m
//  ZTBird
//
//  Created by Zhuo Tao on 11/30/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import "FavoritesViewController.h"
#import "Favorite.h"
#import "BirdDetailViewController.h"
#import "HotSpotDetailViewController.h"
#import "FirstViewController.h"

@interface FavoritesViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation FavoritesViewController
{
    NSFetchedResultsController *_fetchedResultsController0;
    NSFetchedResultsController *_fetchedResultsController1;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Favorites";
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    } else {
        [self.tableView reloadData];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController0 == nil || _fetchedResultsController1 == nil) {
        NSFetchRequest *fetchRequest0 = [[NSFetchRequest alloc] init];
        NSFetchRequest *fetchRequest1 = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Favorite"
                                                  inManagedObjectContext:self.managedOjbectContext];
        [fetchRequest0 setEntity:entity];
        [fetchRequest1 setEntity:entity];

        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor
                                             sortDescriptorWithKey:@"name" ascending:YES];
        [fetchRequest0 setSortDescriptors:@[sortDescriptor]];
        [fetchRequest1 setSortDescriptors:@[sortDescriptor]];
        
        [fetchRequest0 setFetchBatchSize:20];
        [fetchRequest1 setFetchBatchSize:20];
        
        NSPredicate *predicate0 = [NSPredicate predicateWithFormat:@"type == 0"];
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"type == 1"];

        [fetchRequest0 setPredicate:predicate0];
        [fetchRequest1 setPredicate:predicate1];

        //if cacheName is set to non-nil, will have the error:
        //CoreData: FATAL ERROR: The persistent cache of section information does not match the current configuration.  You have illegally mutated the
        //NSFetchedResultsController's fetch request, its predicate, or its sort descriptor without either disabling caching or using +deleteCacheWithName:
        
        _fetchedResultsController0 = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:fetchRequest0
                                     managedObjectContext:self.managedOjbectContext
                                     sectionNameKeyPath:nil
                                     cacheName:nil];
        _fetchedResultsController1 = [[NSFetchedResultsController alloc]
                                      initWithFetchRequest:fetchRequest1
                                      managedObjectContext:self.managedOjbectContext
                                      sectionNameKeyPath:nil
                                      cacheName:nil];
        _fetchedResultsController0.delegate = self;
        _fetchedResultsController1.delegate = self;
    }
    if (self.segmentedControll.selectedSegmentIndex == 0) _fetchedResultsController=_fetchedResultsController0;
    else _fetchedResultsController = _fetchedResultsController1;
    return _fetchedResultsController;
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender
{
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self.tableView reloadData];
}


#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoriteCell"
                                                            forIndexPath:indexPath];
    Favorite *fav = (Favorite *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *combinedName = fav.name;
    cell.textLabel.text = [combinedName componentsSeparatedByString:@"^"][0];
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //delete record from core data
        Favorite *toDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedOjbectContext deleteObject:toDelete];
        NSError *error = nil;
        if (![self.managedOjbectContext save:&error]) {
            // handle error
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.segmentedControll.selectedSegmentIndex == 0) {
        [self performSegueWithIdentifier:@"FavoriteBirdDetail" sender:indexPath];
    } else {
        [self performSegueWithIdentifier:@"FavoriteHotspotDetail" sender:indexPath];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = (NSIndexPath *)sender;
    Favorite *fav = (Favorite *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *combinedName = fav.name;
    
    //get current location from first view controller
    UINavigationController *nav = (UINavigationController *)self.tabBarController.viewControllers[0];
    [nav popToRootViewControllerAnimated:NO];
    FirstViewController *controller = (FirstViewController *)nav.topViewController;
    CLLocation *currentLocation = controller.currentLocation;
    
    if ([segue.identifier isEqualToString:@"FavoriteBirdDetail"]) {
        BirdDetailViewController *detailViewController = (BirdDetailViewController*)[segue destinationViewController];
        detailViewController.birdName = [combinedName componentsSeparatedByString:@"^"][0];;
        detailViewController.sciName = [combinedName componentsSeparatedByString:@"^"][1];;
        detailViewController.currentLocation = currentLocation;
        detailViewController.managedOjbectContext = self.managedOjbectContext;
    } else if ([segue.identifier isEqualToString:@"FavoriteHotspotDetail"]) {
        HotSpotDetailViewController *detailViewController = (HotSpotDetailViewController *)[segue destinationViewController];
        detailViewController.locName = [combinedName componentsSeparatedByString:@"^"][0];
        detailViewController.locID = [combinedName componentsSeparatedByString:@"^"][1];
        detailViewController.coordinate = CLLocationCoordinate2DMake([fav.latitude doubleValue], [fav.longitude doubleValue]);
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[fav.latitude doubleValue]
                                                          longitude:[fav.longitude doubleValue]];
        detailViewController.location = location;
        detailViewController.currentLocation = currentLocation;
        detailViewController.managedOjbectContext = self.managedOjbectContext;
    }
}

#pragma  mark - Fetched Result Controller Delegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type == NSFetchedResultsChangeDelete) {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
