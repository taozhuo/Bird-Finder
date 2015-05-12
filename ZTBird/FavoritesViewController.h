//
//  FavoritesViewController.h
//  ZTBird
//
//  Created by Zhuo Tao on 11/30/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoritesViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedOjbectContext;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControll;
@property (nonatomic, weak) CLLocation *currentLocation;

- (IBAction)segmentChanged:(UISegmentedControl *)sender;

@end
