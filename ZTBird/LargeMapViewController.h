//
//  LargeMapViewController.h
//  ZTBird
//
//  Created by Zhuo Tao on 4/19/15.
//  Copyright (c) 2015 Zhuo Tao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LargeMapViewController : UIViewController
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSArray *hotspots;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSManagedObjectContext *managedOjbectContext;
@property (nonatomic, strong) NSString *birdName;

@end
