//
//  FirstViewController.h
//  ZTBird
//
//  Created by Zhuo Tao on 2/23/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface FirstViewController : UITableViewController <CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, strong) NSManagedObjectContext *managedOjbectContext;
@property (nonatomic, weak) IBOutlet UIButton *trackButton;
@property (nonatomic, weak) IBOutlet UIButton *searchLocationButton;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, assign) BOOL isUserLocation;

@end
