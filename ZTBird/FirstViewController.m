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
#import "ChangeLocationViewController.h"
#import "SpeciesViewController.h"
#import "FlickrCell.h"
#import "BirdInfo.h"
#import "BirdImage.h"
#import "BirdDetailViewController.h"
#import "SpeciesViewController.h"
#import "QuartzCore/QuartzCore.h"

@interface FirstViewController () <MKMapViewDelegate, ChangeLocationDelegate, UITabBarControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, assign) BOOL track;
@property (nonatomic, strong) NSArray *allSpecies;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;


- (IBAction)trackButtonClicked:(id)sender;
@end

@implementation FirstViewController
{
    CLLocationManager *_locationManager;
    CLGeocoder *_geocoder;
    CLPlacemark *_placemark;
    NSError *_lastLocationError;
    NSOperationQueue *_queue;
    NSArray *_notableBirds;
    NSMutableDictionary *_nameMap;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    _queue = [[NSOperationQueue alloc] init];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //prompting for location authorization
    /*if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_locationManager requestAlwaysAuthorization];
    }*/
    
    [self startLocationManager];

    
    //set up mapview
    self.mapView.showsUserLocation = YES;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    self.mapView.pitchEnabled = NO;
    self.mapView.rotateEnabled = NO;

    
    self.navigationItem.title = @"Bird Finder";
    //preload species information
    UINavigationController *nav = (UINavigationController *)self.tabBarController.viewControllers[2];
    SpeciesViewController *speciesVC = (SpeciesViewController *)[nav topViewController];
    [speciesVC loadSpecies];

    
    //set up track button in mapview
    [self.trackButton setImage:[UIImage imageNamed:@"near_me_filled-50.png"] forState:UIControlStateSelected];
    [self.trackButton setImage:[UIImage imageNamed:@"near_me-50.png"] forState:UIControlStateNormal];
    
    //set tab bar controller delegate
    self.tabBarController.delegate = self;
    
}

- (void)loadNotableObservations:(CLLocation *)location
{
    double longitude = location.coordinate.longitude;
    double latitude = location.coordinate.latitude;
    _notableBirds = nil;
    if (_nameMap == nil) _nameMap = [[NSMutableDictionary alloc] init];
    [_nameMap removeAllObjects];
    NSString *urlString;
    urlString =[NSString
                stringWithFormat:kEbirdURLNotableObserv,longitude,latitude];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableSet *tempSet = [NSMutableSet set];
        for (NSDictionary *dict in responseObject)
        {
            NSString *name = dict[@"comName"];
            if ([name rangeOfString:@" x "].location == NSNotFound && [name rangeOfString:@"("].location == NSNotFound) {
                [tempSet addObject:dict[@"comName"]];
                [_nameMap setObject:dict[@"sciName"] forKey:dict[@"comName"]];
            }
        }
        _notableBirds = [tempSet allObjects];
        [self.collectionView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Failed");
    }];
    [_queue addOperation:operation];
}

- (void)startLocationManager
{
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (![CLLocationManager locationServicesEnabled]) {
        self.addressLabel.text = @"(Location services disabled)";
        return;
    }

    if (status == kCLAuthorizationStatusDenied) {
        self.addressLabel.text = @"(Location services denied)";
        return;
    }
    if (status == kCLAuthorizationStatusRestricted) {
        self.addressLabel.text = @"(Location services restricted)";
        return;
    }
    
    //check for ios 8
    if (status == kCLAuthorizationStatusNotDetermined) {
    }
    
    if (!_locationManager) _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }

    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.addressLabel.text = @"Locating...";
    
    [_locationManager startUpdatingLocation];

}

- (void)updateAddressLabelForPlaceMark:(CLPlacemark *)placemark
{
    if (placemark != nil) {
        self.addressLabel.text = [NSString stringWithFormat:@"%@ %@",
                                  //placemark.subThoroughfare,
                                  //placemark.thoroughfare,
                                  placemark.locality,
                                  placemark.administrativeArea
                                 // placemark.postalCode
                                  ];
    } else if (_lastLocationError !=nil) {
        if ([_lastLocationError.domain isEqualToString:kCLErrorDomain] && _lastLocationError.code == kCLErrorDenied) {
            self.addressLabel.text = @"(Location Services Disabled)";
        }
        self.addressLabel.text = @"(Error Getting Location)";
    } else if (![CLLocationManager locationServicesEnabled]) {  //location services disabled on the device
        self.addressLabel.text = @"(Location Services Disabled)";
    }
}

#pragma mark - Table view delegate/data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        UINavigationController *nav = (UINavigationController *)self.tabBarController.viewControllers[1];
        [nav popToRootViewControllerAnimated:NO];
        NearbyViewController *controller = (NearbyViewController *)nav.topViewController;
        controller.coordinate = _currentLocation.coordinate;
        controller.currentLocation = _currentLocation;
        controller.isUserLocation = self.isUserLocation;
        if (indexPath.row == 0) {
            controller.task = @"FindBirds";
            controller.type = 0;
            controller.segmentedControll.selectedSegmentIndex = 0;
        } else { 
            controller.task = @"FindHotspots";
            controller.type = 1;
            controller.segmentedControll.selectedSegmentIndex = 1;
        }
        controller.managedOjbectContext = self.managedOjbectContext;
        if (controller.isViewLoaded) {
            [controller configureTableView];
            [controller loadObservations];
            [controller loadHotspots];
            [controller.tableView reloadData];
        }
        self.tabBarController.selectedIndex = 1;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Map View

/*- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 5000, 5000);
    //[self updateAddressLabelForPlaceMark:_placemark];
 
    //if (!_isRegionSet) {
        [mapView setRegion:[mapView regionThatFits:region] animated:NO];
     //   _isRegionSet = YES;
//    }
}*/


#pragma mark - Map Snapshot
- (void)loadSnapshotForCoordinate:(CLLocationCoordinate2D)coordinate
{
    //set options
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.scale = [[UIScreen mainScreen] scale];
    options.size = CGSizeMake(320, 140);
    MKCoordinateSpan span;
    span.latitudeDelta = 0.01f;
    span.longitudeDelta = 0.01f;
    MKCoordinateRegion region1;
    region1.center = coordinate;
    region1.span = span;
    options.region = region1;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //NSLog(@"location updated!");
    _lastLocationError = nil;
    CLLocation *newLocation = [locations lastObject];
    if ([newLocation.timestamp timeIntervalSinceNow] < -5.0) { //cached result
        return;
    }
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    if (_currentLocation == nil || newLocation.horizontalAccuracy < _currentLocation.horizontalAccuracy) {
        _currentLocation = newLocation;
        _placemark = [self geocode:_geocoder forLocation:_currentLocation];
        MKCoordinateRegion region =
            MKCoordinateRegionMakeWithDistance(_currentLocation.coordinate, 5000, 5000);
        [self.mapView setRegion:region animated:YES];
        if (newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy) {
            [_locationManager stopUpdatingLocation];
            
            //update coordinate in search view controller
            UINavigationController *nav = (UINavigationController *)self.tabBarController.viewControllers[1];
            [nav popToRootViewControllerAnimated:NO];
            NearbyViewController *controller = (NearbyViewController *)nav.topViewController;
            controller.coordinate = _currentLocation.coordinate;
            controller.currentLocation = _currentLocation;
            
            //update location in all species view controller
            nav = (UINavigationController *)self.tabBarController.viewControllers[2];
            [nav popToRootViewControllerAnimated:NO];
            SpeciesViewController  *controller2 = (SpeciesViewController *)nav.topViewController;
            controller2.currentLocation = _currentLocation;
            

            [self updateAddressLabelForPlaceMark:_placemark];
            [self loadNotableObservations:_currentLocation];
            //NSLog(@"Stop update: %@", _currentLocation);
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //NSLog(@"didFailWithError %@", error);
    
    if (error.code == kCLErrorLocationUnknown) {   //retry
        return;
    }
    
    //user declined the app to use location service
    [_locationManager stopUpdatingLocation];
    
    _lastLocationError = error;
    
    [self updateAddressLabelForPlaceMark:nil];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    
    //if (![CLLocationManager locationServicesEnabled]) return;
    

}

- (CLPlacemark *)geocode:(CLGeocoder *)geocoder forLocation:(CLLocation *)location
{
    __block CLPlacemark *placemark;
    [geocoder reverseGeocodeLocation:_currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            [self updateAddressLabelForPlaceMark:placemark];
        } else if (error && error.code == kCLErrorNetwork) {
            placemark = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Network Error"
                                                                               message:[error localizedDescription]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {}];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
                self.addressLabel.text = @"(Network error)";
            });
        }
    }];
    return placemark;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
 /*   if ([segue.identifier isEqualToString:@"FindBirds"]) {
        NearbyViewController *controller = (NearbyViewController *)segue.destinationViewController;
        controller.coordinate = _currentLocation.coordinate;
        controller.currentLocation = _currentLocation;
        controller.task = @"FindBirds";
        controller.navigationItem.title = @"Birds";
        controller.managedOjbectContext = self.managedOjbectContext;
        NSLog(@"tab: %@",self.tabBarController.viewControllers[1]);
        NSLog(@"near: %@",segue.destinationViewController);
        
    } else if ([segue.identifier isEqualToString:@"FindHotspots"]) {
        NearbyViewController *controller = (NearbyViewController *)segue.destinationViewController;
        controller.coordinate = _currentLocation.coordinate;
        controller.currentLocation = _currentLocation;
        controller.task = @"FindHotspots";
        controller.navigationItem.title = @"Hotspots";
        controller.managedOjbectContext = self.managedOjbectContext;
    }*/
    if ([segue.identifier isEqualToString:@"ChangeLocation"]) {
        UINavigationController *nav = segue.destinationViewController;
        ChangeLocationViewController *vc = (ChangeLocationViewController *)nav.topViewController;
        vc.delegate = self;
    }
    if ([segue.identifier isEqualToString:@"NotableBirdDetail"]) {
        NSIndexPath *indexpath = [self.collectionView indexPathForCell:sender];
        NSString *comName = _notableBirds[indexpath.row];
        BirdDetailViewController *detailViewController = (BirdDetailViewController*)[segue destinationViewController];
        detailViewController.birdName = comName;
        NSString *sciName = [_nameMap objectForKey:comName];
        detailViewController.sciName = sciName;
        detailViewController.currentLocation = _currentLocation;
        detailViewController.managedOjbectContext = self.managedOjbectContext;
    }
}

#pragma mark - Target Actions

- (void)trackButtonClicked:(id)sender
{
    if (!self.trackButton.selected) self.trackButton.selected = YES;
    self.addressLabel.text = @"Locating...";
    _currentLocation = nil;
    _placemark = nil;
    _notableBirds = nil;
    [_locationManager startUpdatingLocation];
}

- (void)buttonClicked:(id)sender
{
    
}

#pragma mark - Change location delegate

- (void)changeLocationViewController:(ChangeLocationViewController *)vc didUpdateLocation:(id)newLocation
{
    CLPlacemark *placemark = (CLPlacemark *)newLocation;
    CLLocation *location = placemark.location;
    _currentLocation = location;
    [self updateLocationInTabs];
    _notableBirds = nil;
    [self.collectionView reloadData];
    [self loadNotableObservations:_currentLocation];
    _placemark = placemark;
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance(location.coordinate, 5000, 5000);
    [self.mapView setRegion:region animated:YES];
    [self updateAddressLabelForPlaceMark:placemark];
    self.trackButton.selected = NO;
}

- (void)updateLocationInTabs
{
    //update location in nearby view controller
    UINavigationController *nav = (UINavigationController *)self.tabBarController.viewControllers[1];
    [nav popToRootViewControllerAnimated:NO];
    NearbyViewController *controller = (NearbyViewController *)nav.topViewController;
    controller.coordinate = _currentLocation.coordinate;
    controller.currentLocation = _currentLocation;
    
    //update location in all species view controller
    nav = (UINavigationController *)self.tabBarController.viewControllers[2];
    [nav popToRootViewControllerAnimated:NO];
    SpeciesViewController  *controller2 = (SpeciesViewController *)nav.topViewController;
    controller2.currentLocation = _currentLocation;
    
    //update location in
}

#pragma mark - Collection View Data Source etc.

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_notableBirds count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_notableBirds.count == 0) return nil;
    FlickrCell *cell = (FlickrCell *)[collectionView
                                      dequeueReusableCellWithReuseIdentifier:@"FlickrCell"forIndexPath:indexPath];
    if (self.allSpecies == nil) {
        UINavigationController *nav = (UINavigationController *)self.tabBarController.viewControllers[2];
        SpeciesViewController *speciesVC = (SpeciesViewController *)[nav topViewController];
        self.allSpecies = speciesVC.allSpecies;
    }
    
    //get image from core data
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"com_name CONTAINS [cd] %@", _notableBirds[indexPath.row]];
    NSArray *searchResult = [self.allSpecies filteredArrayUsingPredicate:predicate];
    if ([searchResult count] >0) {
        cell.imageView.layer.cornerRadius = 10;
        cell.imageView.clipsToBounds = YES;
        BirdInfo *birdInfo = (BirdInfo *)searchResult[0];
        cell.imageView.image = [UIImage imageWithData:birdInfo.thumbnailImage.image];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UICollectionview FlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize retval = self.collectionView.frame.size;
    retval.width = retval.height;
    return retval;

}

@end