//
//  NearbyViewController.m
//  ZTBird
//
//  Created by Zhuo Tao on 2/22/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import "NearbyViewController.h"
#import "BirdResultCell.h"
#import <MapKit/MapKit.h>

@interface NearbyViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@end

@implementation NearbyViewController
{
    MKMapView *_mapView;
    BOOL _isUserLocationSet;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UINib *cellNib = [UINib nibWithNibName:@"BirdResultCell" bundle:nil];
    
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"BirdResultCell"];
    self.tableView.rowHeight = 80;
    self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
}

#pragma mark - UITableViewDelegate & UITableViewDataSourc
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BirdResultCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BirdResultCell"];
    cell.nameLabel.text = @"Black Bird";
    cell.locationLabel.text = @"madison wi";
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

#pragma mark - Segmented Control
- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 1) {
        if (_mapView == nil) {
            _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0,105,320,463)];
        }
        [self.view addSubview:_mapView];
        [_mapView setDelegate:self];
        _mapView.showsUserLocation = YES;
    }
    else {
        [_mapView removeFromSuperview];
    }
}

#pragma mark - Map View

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(
                                                                   mapView.userLocation.coordinate, 3000, 3000);
    [mapView setRegion:[mapView regionThatFits:region] animated:YES];
}
- (void)showUser
{
    
    
}






@end
