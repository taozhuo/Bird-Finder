//
//  NearbyViewController.m
//  ZTBird
//
//  Created by Zhuo Tao on 2/22/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import "NearbyViewController.h"
#import "BirdResultCell.h"
#import "HotspotResultCell.h"
#import "BirdPin.h"
#import "HotspotPin.h"
#import "BirdDetailViewController.h"
#import "HotSpotDetailViewController.h"
#import "Favorite.h"
#import "FilterViewController.h"
#import "BirdInfo.h"
#import "BirdImage.h"
#import "SpeciesViewController.h"

@interface NearbyViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, MKMapViewDelegate, FilterDelegate,UITabBarControllerDelegate>
@property (nonatomic, strong) NSArray *allSpecies;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *mapOrList;

- (IBAction)changeDisplay:(id)sender;
@end

@implementation NearbyViewController
{
    MKMapView *_mapView;
    BOOL _isUserLocationSet;
    NSOperationQueue *_queue;
    NSArray *_birdArray;
    NSArray *_searchResult;
    NSMutableDictionary *_hotspotDict;
    BOOL _isBirdsArrayLoaded;
    BOOL _isHotspotArrayLoaded;
    NSMutableArray *_birdPins;
    NSMutableArray *_hotspotPins;
    BOOL _isRegionSet;
    BOOL _didSearch;
    NSMutableDictionary *_speciesDict;
    NSMutableDictionary *_locationDict;
    NSMutableDictionary *_distanceDict;
    
    NSMutableArray *_unSortedBirdArray;
    NSMutableArray *_unSortedHotspotArray;
    NSArray *_sortedBirddArray;
    NSArray *_sortedHotspotArray;
    NSMutableDictionary *_allObservations;
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
    self.isUserLocation = YES;
    self.displayMode = 1;
    self.tabBarController.delegate = self;
    self.distance = 50;
    self.backdays = 30;
    if (self.task == nil) self.task = @"FindBirds";
    if ([self.task isEqualToString:@"FindBirds"])  {
        self.segmentedControll.selectedSegmentIndex = 0;
    }
    else {
        self.segmentedControll.selectedSegmentIndex = 1;
    }
    

    self.tableView.keyboardDismissMode  = UIScrollViewKeyboardDismissModeInteractive;
    [self configureTableView];

    //create map view
    if (_mapView == nil) {
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0,
                                                               0,
                                                               self.tableView.frame.size.width,
                                                               self.tableView.frame.size.height)];
    }
    [_mapView setDelegate:self];
    _mapView.showsUserLocation = YES;
    _hotspotDict = [[NSMutableDictionary alloc] init];
    _speciesDict = [[NSMutableDictionary alloc] init];
    _locationDict = [[NSMutableDictionary alloc] init];
    _distanceDict = [[NSMutableDictionary alloc] init];
    _allObservations = [[NSMutableDictionary alloc] init];

    //load data from eBird web services
    [self loadObservations];
    [self loadHotspots];
  }


- (IBAction)segmentChanged:(UISegmentedControl *)sender
{
    if (_didSearch) {
        [self.searchBar resignFirstResponder];
        [self.searchBar setShowsCancelButton:NO animated:YES];
        self.searchBar.text = nil;
        _didSearch = NO;
    }
    
    if (sender.selectedSegmentIndex == 0) {
        self.task = @"FindBirds";
        if (self.displayMode == 2) [self changeDisplay:self.mapOrList];
    }
    else {self.task = @"FindHotspots";}
    [self configureTableView];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

    [self.tableView reloadData];
}


//sort both birds array and hotspots array
- (NSArray *)sortArray:(NSArray *)array by:(int)what
{
    NSArray *sortedArray;
    if (what == 0) {  //sort bird array by name
        sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDictionary *dict1 = (NSDictionary *)obj1;
            NSDictionary *dict2 = (NSDictionary *)obj2;
            NSString *comName1 = dict1[@"comName"];
            NSString *comName2 = dict2[@"comName"];
            return [comName1 compare:comName2];
        }];
    }
    if (what == 1) {  //sort hotspot array by distance
        sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDictionary *dict1 = (NSDictionary *)obj1;
            NSDictionary *dict2 = (NSDictionary *)obj2;
            NSNumber *dist1 = _distanceDict[dict1[@"locID"]];
            NSNumber *dist2 = _distanceDict[dict2[@"locID"]];
            return [dist1 compare:dist2];
        }];
    }
    return sortedArray;
}

- (void)configureTableView
{
    if ([self.task isEqualToString:@"FindBirds"]) {
        self.navigationItem.title = @"Birds";
        self.tableView.rowHeight = 75;
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else if ([self.task isEqualToString:@"FindHotspots"]) {
        self.navigationItem.title = @"Hotspots";
        self.tableView.rowHeight = 45;
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)processBirdArray:(NSArray *)array
{
    [_speciesDict removeAllObjects];
    
    for (NSDictionary *dict in array) {
        NSString *comName=dict[@"comName"];
        if (comName == nil) continue;
        if ([_speciesDict valueForKey:comName] == nil) {
            [_speciesDict setValue:dict forKey:comName];
        }
        /*if ([_allObservations valueForKey:comName] == nil) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            [_allObservations setValue:tempArray forKey:comName];
        }
        [[_allObservations valueForKey:comName] addObject:dict];*/
    }
    
    //sort observations by date
    /*for (NSString *key in [_allObservations allKeys]) {
        NSArray *array = [_allObservations valueForKey:key];
        NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDictionary *dict1 = (NSDictionary *)obj1;
            NSDictionary *dict2 = (NSDictionary *)obj2;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd hh:mm"];
            NSDate *date1 = [dateFormat dateFromString:dict1[@"obsDt"]];
            NSDate *date2 = [dateFormat dateFromString:dict2[@"obsDt"]];
            return [date1 compare:date2];
        }];
        NSLog(@"%@:",key);
        for (NSDictionary *dict in sortedArray) {
            NSLog(@"    %@", dict[@"obsDt"]);
        }
    }*/
    
    _sortedBirddArray = [self sortArray:_unSortedBirdArray by:0]; //sort bird array by name
}

- (void)processHotspotArray:(NSArray *)array
{
    [_locationDict removeAllObjects];
    [_distanceDict removeAllObjects];
    
    for (NSDictionary *dict in array) {
        NSString *locName = dict[@"locName"];
        if (locName == nil) continue;
        if ([_locationDict valueForKey:locName] == nil) {
            [_locationDict setValue:dict forKey:locName];
        }
        //calculate distance from all locations
        NSString *locID = dict[@"locID"];
        [_distanceDict setObject:[self distanceFromLatitude:[dict[@"lat"] doubleValue]
                                                  longitude:[dict[@"lng"] doubleValue]] forKey:locID];
    }
    _sortedHotspotArray = [self sortArray:array by:1]; //sort hotspot array by distance
}

- (NSNumber *)distanceFromLatitude:(double)latitude longitude:(double)longitude
{
    CLLocation *userloc = [[CLLocation alloc]initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    CLLocation *dest = [[CLLocation alloc]initWithLatitude:latitude  longitude:longitude];
    CLLocationDistance dist = [userloc distanceFromLocation:dest]/1600 ;
    return [NSNumber numberWithDouble:dist];
}

#pragma mark - Loading data

- (void)loadObservations
{
    _isRegionSet = NO;
    _isBirdsArrayLoaded = NO;
    
    double latitude = self.coordinate.latitude;
    double longitude = self.coordinate.longitude;
    [_unSortedBirdArray removeAllObjects];
    
    NSString *urlString;
    urlString =[NSString
            stringWithFormat:kEbirdUrlRecentObserv,longitude,latitude, self.distance, self.backdays];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        _unSortedBirdArray = [NSMutableArray arrayWithArray:responseObject];
        //NSLog(@"observations: %lu", (unsigned long)_unSortedHotspotArray.count);
        NSMutableIndexSet *indexesToDelete = [NSMutableIndexSet indexSet];
        NSUInteger currentIndex = 0;
        for(NSDictionary *dict in _unSortedBirdArray) {
            if (dict[@"comName"] == nil) [indexesToDelete addIndex:currentIndex];
            else {
                NSString *comName = (NSString *)dict[@"comName"];
                NSRange range = [comName rangeOfString:@"sp."];
                
                if (range.location != NSNotFound) {
                    [indexesToDelete addIndex:currentIndex];
                }
                range = [comName rangeOfString:@"/"];
                if (range.location != NSNotFound) {
                    [indexesToDelete addIndex:currentIndex];
                }
                range = [comName rangeOfString:@"("];
                if (range.location != NSNotFound) {
                    [indexesToDelete addIndex:currentIndex];
                }
            }
            currentIndex++;
        }
        [_unSortedBirdArray removeObjectsAtIndexes:indexesToDelete];
        [_unSortedBirdArray sortUsingDescriptors:[NSArray arrayWithObjects:
                                                [NSSortDescriptor sortDescriptorWithKey:@"comName" ascending:YES],
                                                nil]];
        [self processBirdArray:_unSortedBirdArray];
        if ([responseObject count] > 0) {
            _isBirdsArrayLoaded = YES;
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       /* dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });*/
    }];
    [_queue addOperation:operation];
}

- (void)loadHotspots {
    _isHotspotArrayLoaded = NO;
    
    double latitude = self.coordinate.latitude;
    double longitude = self.coordinate.longitude;
    [_unSortedHotspotArray removeAllObjects];
    
    NSString *urlString;
    urlString =[NSString
                stringWithFormat:kEbirdHotspots,longitude,latitude,self.distance,self.backdays];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Hotspots loaded!");
        _unSortedHotspotArray = [NSMutableArray arrayWithArray:responseObject];
        
        if ([responseObject count] > 0) {
            _isHotspotArrayLoaded = YES;
            [self processHotspotArray:_unSortedHotspotArray];
            
            //remove all pins
            [_mapView removeAnnotations:_mapView.annotations];
            
            /*if (userLocation != nil) {
                [_mapView addAnnotation:userLocation];
            }*/
            //add new annotations
            
            MKCoordinateRegion region =
            MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, 10000, 10000);
            
            if (!_isRegionSet) {
                [_mapView setRegion:region animated:NO];
                _isRegionSet = YES;
            }
            
            if ([responseObject count] > 0) {
                _isHotspotArrayLoaded = YES;
                [self.tableView reloadData];
            }

            //[self sortArray:_unSortedHotspotArray by:1];//sort by distance
            [self buildHotspotPins];
            [_mapView addAnnotations:_hotspotPins];
            [self.tableView reloadData];
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];*/
    }];
    [_queue addOperation:operation];
}
     
- (void)buildHotspotPins
{
    if (_hotspotPins == nil) _hotspotPins = [[NSMutableArray alloc] init];
    [_hotspotPins removeAllObjects];
    for (NSDictionary *dict in _unSortedHotspotArray) {
        
        CLLocationCoordinate2D newCoordinate = CLLocationCoordinate2DMake([dict[@"lat"] doubleValue],
                                                                          [dict[@"lng"] doubleValue]);
        HotspotPin *newPin = [[HotspotPin alloc] initWithCoordinate:newCoordinate
                                                              title:dict[@"locName"]
                                                           subtitle:nil];
        [_hotspotPins addObject:newPin];
    }
}

/*
- (void)loadBirdImageDict
{
    for (NSDictionary *dict in _unSortedBirdArray) {
        NSString *escapedSearchText = [dict[@"comName"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *urlString = [NSString stringWithFormat:kFlickrSearchURl,escapedSearchText];
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        operation.responseSerializer = [AFJSONResponseSerializer serializer];

        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *photos = [[responseObject objectForKey:@"photos"] objectForKey:@"photo"];
            if ([photos count]>=1) {
                NSDictionary *photo = photos[0];
                NSString *photoURLString =
                [NSString stringWithFormat:kFlickrSinglePicThumbNailUrl,
                 [photo objectForKey:@"farm"], [photo objectForKey:@"server"],
                 [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
                
                [_birdImageDict setValue:photoURLString forKey:dict[@"comName"]];
                [self.tableView reloadData];
            }
            
        }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
        
        [_queue addOperation:operation];
    }
}*/

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] == 0) {
        _didSearch = NO;
    }
    else _didSearch = YES;
    NSString *searchTextWithSpace = [NSString stringWithFormat:@" %@", searchText];
    NSPredicate *predicateBird = [NSPredicate predicateWithFormat:@"(SELF.comName CONTAINS [cd] %@) OR (SELF.comName BEGINSWITH [cd] %@)",
                              searchTextWithSpace, searchText];
    NSPredicate *predicateHotspot = [NSPredicate predicateWithFormat:@"(SELF.locName CONTAINS [cd] %@) OR (locName BEGINSWITH [cd] %@)",
                                  searchTextWithSpace, searchText];
    if ([self.task isEqualToString:@"FindBirds"]) {
        _searchResult = [_sortedBirddArray filteredArrayUsingPredicate:predicateBird];
    } else if ([self.task isEqualToString:@"FindHotspots"]) {
        _searchResult = [_sortedHotspotArray filteredArrayUsingPredicate:predicateHotspot];
    }
    [self.tableView reloadData];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar
{
    [aSearchBar setShowsCancelButton:NO animated:YES];
    [aSearchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    searchBar.text = nil;
}

#pragma mark - UITableView Delegate & UITableView DataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    if ([self.task isEqualToString:@"FindBirds"]) {
        if (self.allSpecies == nil) {
            UINavigationController *nav = (UINavigationController *)self.tabBarController.viewControllers[2];
            [nav popToRootViewControllerAnimated:NO];
            SpeciesViewController *speciesVC = (SpeciesViewController *)[nav topViewController];
            self.allSpecies = speciesVC.allSpecies;
        }
        
        UITableViewCell *cell;
        if (_isBirdsArrayLoaded) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"BirdInfo"];

            NSDictionary *dict;
            if (_didSearch) dict = _searchResult[indexPath.row];
            else dict = _sortedBirddArray[indexPath.row];
            
            //calculate distance
            //CLLocation *userloc = [[CLLocation alloc]initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
            //CLLocation *dest = [[CLLocation alloc]initWithLatitude:[dict[@"lat"] doubleValue] longitude:[dict[@"lng"] doubleValue]];
            //CLLocationDistance dist = [userloc distanceFromLocation:dest]/1000;
            
            //UILabel *distanceLabel = (UILabel *)[cell viewWithTag:400];
            //distanceLabel.text = [NSString stringWithFormat:@"%.1f mi",dist];
            
            //configure cell labels and image views
            UILabel *nl = (UILabel *)[cell viewWithTag:100];
            nl.text = dict[@"comName"];
            
            UILabel *lastObservedLabel = (UILabel *)[cell viewWithTag:200];
            lastObservedLabel.text = [NSString stringWithFormat:@"Last observed: %@",dict[@"obsDt"]];
            
            //use image from core data
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"com_name CONTAINS [cd] %@", dict[@"comName"]];
            NSArray *searchResult = [self.allSpecies filteredArrayUsingPredicate:predicate];
            if ([searchResult count] >0) {
                BirdInfo *birdInfo = (BirdInfo *)searchResult[0];
                UIImageView *iv = (UIImageView *)[cell viewWithTag:300];
                iv.layer.cornerRadius = 6;
                iv.clipsToBounds = YES;
                iv.image = [UIImage imageWithData:birdInfo.thumbnailImage.image];
            }
        } else {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"BirdSpinnerCell"];
            UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:100];
            [spinner startAnimating];
        }
        return cell;
    }
    else if ([self.task isEqualToString:@"FindHotspots"]) {
        UITableViewCell *cell;
        if (_isHotspotArrayLoaded) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"HotspotResultCell"];
            NSString *locName;
            NSDictionary *dict;
            if (_didSearch) dict = _searchResult[indexPath.row];
            else dict = _sortedHotspotArray[indexPath.row];
            locName = dict[@"locName"];
            
            //distance label
            CLLocation *userloc = [[CLLocation alloc]initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
            CLLocation *dest = [[CLLocation alloc]initWithLatitude:[dict[@"lat"] doubleValue] longitude:[dict[@"lng"] doubleValue]];
            CLLocationDistance dist = [userloc distanceFromLocation:dest]/1000;
            UILabel *distanceLabel = (UILabel *)[cell viewWithTag:300];
            distanceLabel.text = [NSString stringWithFormat:@"%.1f mi",dist];

            UILabel *nl = (UILabel *)[cell viewWithTag:100];
            nl.text = locName;
            
            //UILabel *obvCountLabel = (UILabel *)[cell viewWithTag:200];
            //obvCountLabel.text = [NSString stringWithFormat:@"%lu observations", (unsigned long)[_locationDict[locName] count]];
        } else {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"HotspotSpinnerCell"];
            UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:100];
            [spinner startAnimating];
        }
        return cell;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.task isEqualToString:@"FindBirds"] && !_isBirdsArrayLoaded) return 1;
    if ([self.task isEqualToString:@"FindHotspots"] && !_isHotspotArrayLoaded) return 1;
    if (_didSearch) return [_searchResult count];
    if ([self.task isEqualToString:@"FindBirds"]) return [_sortedBirddArray count];
    if ([self.task isEqualToString:@"FindHotspots"]) return [_sortedHotspotArray count];
    else return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // you need to implement this method too or nothing will work:
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *favAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                         title:@"Favorite"
                                                                       handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                                           UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                                                                           [self tableView:tableView addToFavoriteForCell:cell];
                                                                           self.tableView.editing = NO;
                                                                       }];
    return @[favAction];
}


- (void)tableView:(UITableView *)tableView addToFavoriteForCell:(UITableViewCell *)cell
{
    NSString *matchedName;
    CLLocation *location;
    CLLocationCoordinate2D coordinate;
    if ([self.task isEqualToString:@"FindBirds"]) {
        UILabel *nl = (UILabel *)[cell viewWithTag:100];
        NSString *comName = nl.text;
        NSString *sciName = _speciesDict[comName][@"sciName"];
        matchedName = [NSString stringWithFormat:@"%@^%@", comName, sciName];
        
    } else {
        UILabel *nl = (UILabel *)[cell viewWithTag:100];
        NSString *locName = nl.text;
        NSDictionary *dict = _locationDict[locName];
        NSString *locID = dict[@"locID"];
        matchedName = [NSString stringWithFormat:@"%@^%@", locName, locID];
        location = [[CLLocation alloc] initWithLatitude:[dict[@"lat"] doubleValue]
                                                          longitude:[dict[@"lng"] doubleValue]];
        coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude);
    }
    
    NSFetchRequest *findExisting = [[NSFetchRequest alloc] init];
    [findExisting setEntity:
        [NSEntityDescription entityForName:@"Favorite" inManagedObjectContext:self.managedOjbectContext]];
    [findExisting setPredicate:[NSPredicate predicateWithFormat:@"name == %@",matchedName]];
    NSError *error;
    NSArray *matchedRecords = [self.managedOjbectContext executeFetchRequest:findExisting error:&error];
    if ([matchedRecords count]!=0) return;
    
    Favorite *favEntity = [NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:self.managedOjbectContext];
    if ([self.task isEqualToString:@"FindBirds"]) {
        favEntity.type = [NSNumber numberWithInt:0];
    } else {
        favEntity.type = [NSNumber numberWithInt:1];
    }
    favEntity.name = matchedName;
    
    if ([self.task isEqualToString:@"FindHotspots"]) {
        favEntity.latitude = [NSNumber numberWithDouble:coordinate.latitude];
        favEntity.longitude = [NSNumber numberWithDouble:coordinate.longitude];
    }
    
    if (![self.managedOjbectContext save:&error]) {
        //NSLog(@"Error: %@", error);
        abort();
    }
}

#pragma mark - Change Map/List
- (IBAction)changeDisplay:(id)sender
{
    if (self.displayMode == 1) {
        _mapView.alpha = 0.0;
        [self.view addSubview:_mapView];
        [UIView animateWithDuration:0.4 animations:^{
            [_mapView setAlpha:1.0];
        } completion:^(BOOL finished) {}];
        self.displayMode = 2;
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        button.title = @"List";
        //button.image = [UIImage imageNamed:@"Menu-25.png"];
    }
    else {
        [UIView animateWithDuration:0.4 animations:^{
            [_mapView setAlpha:0.0];
        } completion:^(BOOL finished) {
            [_mapView removeFromSuperview];
        }];
        self.displayMode = 1;
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        button.title = @"Map";
        //button.image = [UIImage imageNamed:@"Map Marker-25.png"];
    }
}

#pragma mark - Map View

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region =
        MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, 10000, 10000);
    
    if (!_isRegionSet) {
        [mapView setRegion:region animated:NO];
        _isRegionSet = YES;
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
        [self.searchBar setShowsCancelButton:NO animated:YES];
    }
    if ([segue.identifier isEqualToString:@"ShowBirdDetail"]) {
        BirdDetailViewController *detailViewController = (BirdDetailViewController*)[segue destinationViewController];
        UITableViewCell *cell = sender;
        UILabel *nl = (UILabel *)[cell viewWithTag:100];
        detailViewController.birdName = nl.text;
        NSString *comName = nl.text;
        NSString *sciName = _speciesDict[comName][@"sciName"];
        detailViewController.sciName = sciName;
        detailViewController.currentLocation = self.currentLocation;
        detailViewController.managedOjbectContext = self.managedOjbectContext;
    } else if ([segue.identifier isEqualToString:@"ShowHotspotDetailFromMap"]) {
        HotSpotDetailViewController *detailViewController = (HotSpotDetailViewController *)[segue destinationViewController];
        MKAnnotationView *annotationView = (MKAnnotationView*)sender;
        NSString *locName = annotationView.annotation.title;
        NSDictionary *dict = _locationDict[locName];
        detailViewController.locName = locName;
        detailViewController.locID = dict[@"locID"];
        detailViewController.coordinate = annotationView.annotation.coordinate;
        CLLocation *location = [[CLLocation alloc] initWithLatitude:detailViewController.coordinate.latitude
                                                          longitude:detailViewController.coordinate.longitude];
        detailViewController.location = location;
        detailViewController.currentLocation = self.currentLocation;
        detailViewController.managedOjbectContext = self.managedOjbectContext;
    } else if ([segue.identifier isEqualToString:@"ShowHotspotDetailFromTable"]) {
        HotSpotDetailViewController *detailViewController = (HotSpotDetailViewController *)[segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *dict;
        if (!_didSearch) dict = _sortedHotspotArray[indexPath.row];
        else dict = _searchResult[indexPath.row];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[dict[@"lat"] doubleValue]
                                                            longitude:[dict[@"lng"] doubleValue]];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude);
        detailViewController.locName  = dict[@"locName"];
        detailViewController.locID = dict[@"locID"];
        detailViewController.coordinate = coordinate;
        detailViewController.location = location;
        detailViewController.currentLocation = self.currentLocation;
        detailViewController.managedOjbectContext = self.managedOjbectContext;
    } else if ([segue.identifier isEqualToString:@"Filter"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        FilterViewController *filterVC = (FilterViewController *)nav.topViewController;
        filterVC.distance = self.distance;
        filterVC.backdays = self.backdays;
        filterVC.delegate = self;
        if (self.displayMode == 2) [self changeDisplay:self.mapOrList];
    }
}

#pragma mark - MKMapViewDelegate

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if([annotation isEqual:[mapView userLocation]])
    {
        return nil;
    }

    if ([annotation coordinate].latitude == self.currentLocation.coordinate.latitude &&
        [annotation coordinate].longitude == self.currentLocation.coordinate.longitude)
        return nil;
    if ([self.task isEqualToString:@"FindHotspots"]) {
        static NSString *HotspotAnnotationViewID = @"hotspotAnnotationViewID";
        MKPinAnnotationView *pinView =
        (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:HotspotAnnotationViewID];
        if (pinView == nil) {
            MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                                                 reuseIdentifier:HotspotAnnotationViewID];
            //customPinView.pinColor = MKPinAnnotationColorPurple;
            if ([annotation isKindOfClass:[MKUserLocation class]]) {
                customPinView.pinColor = MKPinAnnotationColorGreen;
                //NSLog(@"annotation is user location!");
            }
            customPinView.animatesDrop = NO;
            customPinView.canShowCallout = YES;
            if ([annotation coordinate].latitude == self.currentLocation.coordinate.latitude &&
                [annotation coordinate].longitude == self.currentLocation.coordinate.longitude) {
                customPinView.pinColor = MKPinAnnotationColorGreen;
                //NSLog(@"Found current location!");
            } else {
                customPinView.pinColor = MKPinAnnotationColorRed;
            }
            /*UIImage *image = [UIImage imageNamed:@"binoculars_filled-50.png"];
            
            CGSize size20 = CGSizeMake(20, 20);
            UIGraphicsBeginImageContext(size20);
            [image drawInRect:CGRectMake(0, 0, size20.width, size20.height)];
            
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            customPinView.image = newImage;
    
            UIGraphicsEndImageContext();*/
            
            //call out button
            customPinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            return customPinView;
        }
        else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"ShowHotspotDetailFromMap" sender:view];
}

#pragma mark - Filter delegate

- (void)filterViewController:(FilterViewController *)vc distance:(int)newDistance backday:(int)newBackday
{
    self.distance = newDistance;
    self.backdays = newBackday;
    [self configureTableView];
    [self loadObservations];
    [self loadHotspots];
    [self.tableView reloadData];
}

#pragma mark - Tab bar controller delegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (self.tabBarController.selectedIndex != 1) {
        if (self.displayMode == 2) [self changeDisplay:self.mapOrList];
    }
}

@end
