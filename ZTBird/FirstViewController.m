//
//  FirstViewController.m
//  ZTBird
//
//  Created by Zhuo Tao on 2/23/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import "FirstViewController.h"
#import "NearbyViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface FirstViewController ()

- (IBAction)birdsButtonClicked:(id)sender;
- (IBAction)hotspotsButtonClicked:(id)sender;
- (IBAction)birdsButtonReleased:(id)sender;
- (IBAction)hotspotsButtonReleased:(id)sender;

@end

@implementation FirstViewController
{
    CLLocationManager *_locationManager;
    CLLocation *_currentLocation;
    CLGeocoder *_geocoder;
    CLPlacemark *_placemark;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _geocoder = [[CLGeocoder alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [_locationManager startUpdatingLocation];
    self.birdButton.enabled = NO;
    self.birdButton.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:0.2].CGColor;
    self.birdButton.layer.borderWidth = 1.0;
    self.birdButton.layer.cornerRadius = 5;
    
    self.hotspotButton.enabled = NO;
    self.hotspotButton.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:255.0 alpha:0.2].CGColor;
    self.hotspotButton.layer.borderWidth = 1.0;
    self.hotspotButton.layer.cornerRadius = 5;
}

- (void)updateAddressLabel
{
    if (_currentLocation != nil && _placemark != nil) {
        self.addressLabel.text = [NSString stringWithFormat:@"%@ %@\n%@ %@ %@",
                                  _placemark.subThoroughfare,
                                  _placemark.thoroughfare,
                                  _placemark.locality,
                                  _placemark.administrativeArea,
                                  _placemark.postalCode];
        self.birdButton.enabled = YES;
        self.birdButton.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;

        
        self.hotspotButton.enabled = YES;
        self.hotspotButton.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:255.0 alpha:1.0].CGColor;
        
        
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    if ([newLocation.timestamp timeIntervalSinceNow] < -5.0) {
        return;
    }
    
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    if (_currentLocation == nil || _currentLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        _currentLocation = newLocation;
        [self updateAddressLabel];
        
        if (newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy) {
            [_locationManager stopUpdatingLocation];
            NSLog(@"Stop update: %@", _currentLocation);
        }
        
        [_geocoder reverseGeocodeLocation:_currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error == nil && [placemarks count] > 0) {
                _placemark = [placemarks lastObject];
            } else {
                _placemark = nil;
            }
            [self updateAddressLabel];
            
        }];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"FindBirds"]) {
        NearbyViewController *controller = segue.destinationViewController;
        controller.coordinate = _currentLocation.coordinate;
        controller.task = @"FindBirds";
        controller.navigationItem.title = @"Birds";
    } else if ([segue.identifier isEqualToString:@"FindHotspots"]) {
        NearbyViewController *controller = segue.destinationViewController;
        controller.coordinate = _currentLocation.coordinate;
        controller.task = @"FindHotspots";
        controller.navigationItem.title = @"Hotspots";
    }
}

- (IBAction)birdsButtonClicked:(id)sender
{
    
    self.birdButton.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:0.2].CGColor;

}

- (IBAction)birdsButtonReleased:(id)sender
{
    self.birdButton.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
}

- (IBAction)hotspotsButtonClicked:(id)sender
{
    
    self.hotspotButton.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:0.2].CGColor;
    
}

- (IBAction)hotspotsButtonReleased:(id)sender
{
    self.hotspotButton.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
}


@end
