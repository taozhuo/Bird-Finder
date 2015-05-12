//
//  CatalogViewController.m
//  ZTBird
//
//  Created by Zhuo Tao on 7/2/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import "SpeciesViewController.h"
#import "BirdInfo.h"
#import "BirdImage.h"
#import "BirdDetailViewController.h"
#import "Favorite.h"

@interface SpeciesViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *privateContext;
@property (nonatomic, strong) NSFetchRequest *allSpeciesFetchRequest;

@end

#pragma mark -

@implementation SpeciesViewController
{
    BOOL _didSearch;
    NSArray *_searchResult;
}

#pragma mark - Fetched results controller

- (NSFetchRequest *)allSpeciesFetchRequest
{
    if (_allSpeciesFetchRequest == nil) {
        _allSpeciesFetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"BirdInfo"
                                                  inManagedObjectContext:self.managedOjbectContext];
        [_allSpeciesFetchRequest setEntity:entity];
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor
                                             sortDescriptorWithKey:@"category" ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor
                                             sortDescriptorWithKey:@"com_name" ascending:YES];
        [_allSpeciesFetchRequest setSortDescriptors:@[sortDescriptor1, sortDescriptor2]];
        [_allSpeciesFetchRequest setFetchBatchSize:5];
    }
    return _allSpeciesFetchRequest;
}

- (NSManagedObjectContext *)privateContext
{
    if (_privateContext == nil) {
        _privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _privateContext.persistentStoreCoordinator = self.managedOjbectContext.persistentStoreCoordinator;
    }
    return _privateContext;
}

// private queue version
- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController == nil) {
        _fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:self.allSpeciesFetchRequest
                                     managedObjectContext:self.privateContext
                                     sectionNameKeyPath:@"category"
                                     cacheName:nil];
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}


#pragma mark - View lifecycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"All Species";
    self.tableView.rowHeight = 75;
    _didSearch = NO;
    [self loadSpecies];
}

- (void)loadSpecies
{
    [self.fetchedResultsController.managedObjectContext performBlock:^{
        NSError *error;
        if (![self.fetchedResultsController performFetch:&error]) {
            //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } else {
            self.allSpecies = self.fetchedResultsController.fetchedObjects;
            //NSArray *objs = [self.fetchedResultsController fetchedObjects];
            //NSString *searchText = @" s";
            //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"com_name CONTAINS [cd] %@", searchText];
            //NSArray *temp = [objs filteredArrayUsingPredicate:predicate];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
            }];
            
            
            /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                NSArray *objs = [self.fetchedResultsController fetchedObjects];
                NSString *searchText = @" s";
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"com_name CONTAINS [cd] %@", searchText];
                NSArray *temp = [objs filteredArrayUsingPredicate:predicate];
            });*/
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!_didSearch) {
        return [[self.fetchedResultsController sections] count];
    }
    else return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!_didSearch) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        return [sectionInfo numberOfObjects];
    }
    return [_searchResult count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (!_didSearch) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        return [sectionInfo name];
    } else return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BirdInfo"
                                                            forIndexPath:indexPath];
    BirdInfo *birdInfo;
    if (!_didSearch) {
        birdInfo = (BirdInfo *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    } else {
        birdInfo =(BirdInfo *)_searchResult[indexPath.row];
    }
    UILabel *comNameLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *sciNameLabel = (UILabel *)[cell viewWithTag:200];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:300];
    imageView.layer.cornerRadius = 6;
    imageView.clipsToBounds = YES;
    
    comNameLabel.text = birdInfo.com_name;
    
    sciNameLabel.text = birdInfo.sci_name;
    sciNameLabel.font = [UIFont italicSystemFontOfSize:16.0f];
    //set up image view
    /*CGSize size = CGSizeMake(60, 60);
    UIGraphicsBeginImageContext(size);
    UIImage *oldImage = birdInfo.thumbnailImage;
    [oldImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    imageView.image = newImage;
    UIGraphicsEndImageContext();*/
    imageView.image = [UIImage imageWithData:birdInfo.thumbnailImage.image];
    
    return cell;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *favAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                         title:@"Favorite"
                                                                       handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                                           UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                                                                           [self tableView:tableView addSpeciesToFavoriteForCell:cell];
                                                                           self.tableView.editing = NO;
                                                                       }];
    return @[favAction];
}

- (void)tableView:(UITableView *)tableView addSpeciesToFavoriteForCell:(UITableViewCell *)cell
{
    UILabel *comNameLabel = (UILabel *)[cell viewWithTag:100];
    NSFetchRequest *findExisting = [[NSFetchRequest alloc] init];
    [findExisting setEntity:
     [NSEntityDescription entityForName:@"Favorite" inManagedObjectContext:self.managedOjbectContext]];
    [findExisting setPredicate:[NSPredicate predicateWithFormat:@"name == %@",comNameLabel.text]];
    NSError *error;
    NSArray *matchedRecords = [self.managedOjbectContext executeFetchRequest:findExisting error:&error];
    if ([matchedRecords count]!=0) return;
    
    Favorite *favEntity = [NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:self.managedOjbectContext];
    favEntity.type = [NSNumber numberWithInt:0];
    favEntity.name = comNameLabel.text;

    if (![self.managedOjbectContext save:&error]) {
        //NSLog(@"Error: %@", error);
        abort();
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"commit editing style");
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath 
{
    //fetch request runs in backgroud, ui updates in main queue
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        switch (type) {
            case NSFetchedResultsChangeUpdate:
                [self.tableView cellForRowAtIndexPath:indexPath];
                break;
            default:
                break;
        }
    }];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView reloadData];
    }];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] == 0) {
        _didSearch = NO;
        [self.tableView reloadData];
        return;
    }
    else _didSearch = YES;
    NSArray *objs = [self.fetchedResultsController fetchedObjects];
    NSString *searchTextWithSpace = [NSString stringWithFormat:@" %@", searchText];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(com_name CONTAINS [cd] %@) OR (com_name BEGINSWITH [cd] %@)",
                              searchTextWithSpace, searchText];
    _searchResult = [objs filteredArrayUsingPredicate:predicate];
    [self.tableView reloadData];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar
{
    [aSearchBar setShowsCancelButton:NO animated:YES];
    [aSearchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    searchBar.text = nil;
    _didSearch = NO;
    [self.tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SpeciesDetail"]) {
        BirdDetailViewController *detailViewController = (BirdDetailViewController*)[segue destinationViewController];
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        BirdInfo *info;
        BirdImage *imageObj;
        if (!_didSearch) {
            info = (BirdInfo *)[self.fetchedResultsController objectAtIndexPath:path];
            imageObj = info.thumbnailImage;
        } else {
            info =(BirdInfo *)_searchResult[path.row];
        }
        detailViewController.birdName = info.com_name;
        detailViewController.sciName = info.sci_name;
        detailViewController.birdInfo = info;
        detailViewController.managedOjbectContext = self.managedOjbectContext;
        detailViewController.currentLocation =self.currentLocation;
    }
}

@end
