//
//  CatalogViewController.h
//  ZTBird
//
//  Created by Zhuo Tao on 7/2/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpeciesViewController : UITableViewController <UISearchBarDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedOjbectContext;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSArray *allSpecies;
@property (nonatomic, strong) CLLocation *currentLocation;

- (void)loadSpecies;
@end
