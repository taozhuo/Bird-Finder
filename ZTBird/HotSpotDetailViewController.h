//
//  HotSpotDetailViewController.h
//  ZTBird
//
//  Created by Zhuo Tao on 8/24/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HotspotDetailStaticCell;

@interface HotSpotDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) NSString *locName;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSArray *locationArray;
@property (nonatomic, strong) NSArray *birdArray;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) NSString *locID;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSManagedObjectContext *managedOjbectContext;
@property (nonatomic, strong) NSArray *allSpecies;

@end
