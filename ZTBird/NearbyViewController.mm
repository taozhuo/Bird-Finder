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
#import <AFNetworking/AFNetworking.h>
#import "BirdPin.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#include <vector>
using namespace std;

@interface NearbyViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@end

@implementation NearbyViewController
{
    vector<NSURL *> v;
    MKMapView *_mapView;
    BOOL _isUserLocationSet;
    NSOperationQueue *_queue;
    NSArray *_birdArray;
    NSArray *_searchResult;
    NSMutableDictionary *_birdImageDict;
    BOOL _isArrayLoaded;
    NSMutableArray *_birdPins;
    BOOL _isRegionSet;
    BOOL _didSearch;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _queue = [[NSOperationQueue alloc] init];
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
    self.tableView.keyboardDismissMode  = UIScrollViewKeyboardDismissModeInteractive;
    
    //create map view
    if (_mapView == nil) {
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0,105,320,463)];
    }
    [_mapView setDelegate:self];
    _mapView.showsUserLocation = YES;
    _isRegionSet = NO;
    _isArrayLoaded = NO;
    
    _birdImageDict = [[NSMutableDictionary alloc] init];
    
    [self loadURL];
    
   }

- (void)loadURL
{
    double latitude = self.coordinate.latitude;
    double longitude = self.coordinate.longitude;
    NSString *urlString =[NSString
        stringWithFormat:kEbirdUrlRecentObserv,longitude,latitude];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        _birdArray = (NSArray *)responseObject;
        if ([_birdArray count] > 0) {
            [self buildBirdPins];
            _isArrayLoaded = YES;
            [self.tableView reloadData];
            [_mapView addAnnotations:_birdPins];
            
            [self loadBirdImageDict];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed! %@", error);
    }];
    [_queue addOperation:operation];
}

- (void)buildBirdPins
{
    if (_birdPins == nil) _birdPins=[[NSMutableArray alloc]initWithCapacity:[_birdArray count]];
    [_birdPins removeAllObjects];
    for (NSDictionary *dict in _birdArray) {
        CLLocationCoordinate2D newCoordinate = CLLocationCoordinate2DMake([dict[@"lat"] doubleValue],
                                                                          [dict[@"lng"] doubleValue]);
        NSLog(@"lat: %.3f, lng: %.3f", newCoordinate.latitude, newCoordinate.longitude);
        BirdPin *newPin = [[BirdPin alloc] initWithCoordinate:newCoordinate title:dict[@"comName"] subtitle:dict[@"locName"]];
        [_birdPins addObject:newPin];
    }
        
}

- (void)loadBirdImageDict
{
    for (NSDictionary *dict in _birdArray) {
        NSString *escapedSearchText = [dict[@"comName"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *urlString = [NSString stringWithFormat:kFlickrUrl,escapedSearchText];
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        operation.responseSerializer = [AFJSONResponseSerializer serializer];

        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *photos = [[responseObject objectForKey:@"photos"] objectForKey:@"photo"];
            NSDictionary *photo = photos[0];
            NSString *photoURLString =
            [NSString stringWithFormat:kFlickrSinglePicThumbNailUrl,
             [photo objectForKey:@"farm"], [photo objectForKey:@"server"],
             [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
            
            [_birdImageDict setValue:photoURLString forKey:dict[@"comName"]];
            [self.tableView reloadData];
            
        }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Failed! %@", error);
        }];
        
        [_queue addOperation:operation];
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] == 0) {
        _didSearch = NO;
    }
    else _didSearch = YES;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.comName contains[c] %@", searchText];
    _searchResult = [_birdArray filteredArrayUsingPredicate:predicate];
    [self.tableView reloadData];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar
{
    [aSearchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BirdResultCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BirdResultCell"];
    if (_isArrayLoaded) {
        NSDictionary *dict;
        if (_didSearch) dict = _searchResult[indexPath.row];
        else dict = _birdArray[indexPath.row];
              
        //calculate distance
        CLLocation *userloc = [[CLLocation alloc]initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
        CLLocation *dest = [[CLLocation alloc]initWithLatitude:[dict[@"lat"] doubleValue] longitude:[dict[@"lng"] doubleValue]];
        
        CLLocationDistance dist = [userloc distanceFromLocation:dest]/1000;
        cell.distanceLabel.text = [NSString stringWithFormat:@"%.1f mi",dist];
        
        //configure cell labels and image views
        [cell configureForDictionary:dict imageDict:_birdImageDict];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!_isArrayLoaded) return 0;
    if (_didSearch) return [_searchResult count];
    else return [_birdArray count];
}

#pragma mark - Segmented Control
- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 1) {
        _mapView.alpha = 0.0;
        [self.view addSubview:_mapView];
        [UIView animateWithDuration:0.4 animations:^{
            [_mapView setAlpha:1.0];
        } completion:^(BOOL finished) {}];

    }
    else {
        [UIView animateWithDuration:0.4 animations:^{
            [_mapView setAlpha:0.0];
        } completion:^(BOOL finished) {
            [_mapView removeFromSuperview];
        }];
    }
}

#pragma mark - Map View

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region =
        MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 3000, 3000);
    
    if (!_isRegionSet) {
        [mapView setRegion:[mapView regionThatFits:region] animated:YES];
        _isRegionSet = YES;
    }
}

- (NSDictionary *)parseJSON:(NSString *)jsonString
{
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    id resultObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (resultObject == nil) {
        NSLog(@"JSON error: %@", error);
        return nil;
    }
    return resultObject;
}

@end
