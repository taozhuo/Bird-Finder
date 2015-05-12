//
//  NearbyViewController.h
//  ZTBird
//
//  Created by Zhuo Tao on 2/22/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface NearbyViewController : UIViewController

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) NSString *task;
@property (nonatomic, strong) NSManagedObjectContext *managedOjbectContext;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) int distance;
@property (nonatomic) int backdays;
@property (nonatomic) int type;
@property (nonatomic) int sortBy;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControll;
@property (nonatomic, assign) int displayMode;
@property (nonatomic, assign) BOOL isUserLocation;

- (void)configureTableView;
- (void)loadObservations;
- (void)loadHotspots;
- (IBAction)segmentChanged:(UISegmentedControl *)sender;

@end
