//
//  HotSpotDetailViewController.m
//  ZTBird
//
//  Created by Zhuo Tao on 8/24/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import "HotSpotDetailViewController.h"
#include "HotspotDetailStaticCell.h"
#import  "QuartzCore/QuartzCore.h"
#import "BirdDetailViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "Favorite.h"
#import "FavoritesViewController.h"
#import "SpeciesViewController.h"
#import "BirdImage.h"
#import "BirdInfo.h"

@interface HotSpotDetailViewController ()

@property (nonatomic, weak) IBOutlet UITableView *obServationTableView;
@property (nonatomic, weak) IBOutlet UILabel *locNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UIButton *favButton;
@property (nonatomic, weak) IBOutlet UILabel *obsCountLabel;

- (IBAction)favClicked:(id)sender;

@end

@implementation HotSpotDetailViewController
{
    CLLocation *_hotspotLocation;
    CLGeocoder *_geocoder;
    CLPlacemark *_placemark;
    HotspotDetailStaticCell *_staticCell;
    NSOperationQueue *_queue;
    BOOL _saved;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
- (IBAction)showDirection:(id)sender {
    Class itemClass = [MKMapItem class];
    if (itemClass && [itemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.coordinate
                                                       addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:self.locName];
        
        NSDictionary *launghOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
        MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
        [MKMapItem openMapsWithItems:@[currentLocationMapItem,mapItem] launchOptions:launghOptions];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _saved = NO;
    self.locNameLabel.text = self.locName;
    if (_queue == nil) {
        _queue = [[NSOperationQueue alloc] init];
    }
    
    //set table view top margin
    UIEdgeInsets inset = UIEdgeInsetsMake(-60, 0, 0, 0);
    self.obServationTableView.contentInset = inset;
    self.obServationTableView.rowHeight = 53;

    _hotspotLocation = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance(self.coordinate, 1000, 1000);
    self.mapView.mapType = MKMapTypeSatellite;
    [self.mapView setRegion:region animated:YES];

    if ((self.birdArray == nil || self.birdArray.count == 0) && self.locID) {
        [self loadObsAtHotspot];
    }
    _geocoder = [[CLGeocoder alloc] init];
    [_geocoder reverseGeocodeLocation:_hotspotLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0) {
            _placemark = [placemarks lastObject];
        } else {
            _placemark = nil;
        }
        [self updateAddressLabel];
    }];
    
    //set up favorite button
    NSString *matchedName = [NSString stringWithFormat:@"%@^%@", self.locName, self.locID];
    NSFetchRequest *findExisting = [[NSFetchRequest alloc] init];
    [findExisting setEntity:
     [NSEntityDescription entityForName:@"Favorite" inManagedObjectContext:self.managedOjbectContext]];
    [findExisting setPredicate:[NSPredicate predicateWithFormat:@"name == %@",matchedName]];
    NSError *error;
    NSArray *matchedRecords = [self.managedOjbectContext executeFetchRequest:findExisting error:&error];
    if ([matchedRecords count]!=0) {
        UIImage *image = [UIImage imageNamed:@"Hearts-50-filled.png"];
        [self.favButton setImage:image forState:UIControlStateNormal];
        _saved = YES;
    }

}

- (void)favClicked:(id)sender
{
    if (_saved) return;
    
    //save to core data
    Favorite *favEntity = [NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:self.managedOjbectContext];
    favEntity.type = [NSNumber numberWithInt:1];
    NSString *matchedName = [NSString stringWithFormat:@"%@^%@", self.locName, self.locID];
    favEntity.name = matchedName;
    favEntity.latitude = [NSNumber numberWithDouble:self.coordinate.latitude];
    favEntity.longitude = [NSNumber numberWithDouble:self.coordinate.longitude];
    NSError *error;
    if (![self.managedOjbectContext save:&error]) {
        //NSLog(@"Error: %@", error);
        abort();
    } else {
        _saved = YES;
        UIImage *image = [UIImage imageNamed:@"Hearts-50-filled.png"];
        [sender setImage:image forState:UIControlStateNormal];
    }
}

- (void)loadObsAtHotspot
{
    NSString *urlString;
    urlString =[NSString
                stringWithFormat:kEbirdURLObsAtHotspot, self.locID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:responseObject];
        NSMutableIndexSet *indexesToDelete = [NSMutableIndexSet indexSet];
        NSUInteger currentIndex = 0;
        for(NSDictionary *dict in tempArr) {
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
        [tempArr removeObjectsAtIndexes:indexesToDelete];
        [tempArr sortUsingDescriptors:[NSArray arrayWithObjects:
                                                  [NSSortDescriptor sortDescriptorWithKey:@"comName" ascending:YES],
                                                  nil]];
        self.birdArray = tempArr;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.obsCountLabel.text = [NSString stringWithFormat:@"  %ld Observations:",(unsigned long)self.birdArray.count];
            [self.obServationTableView reloadData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Failed");
    }];
    [_queue addOperation:operation];
}

- (void)updateAddressLabel
{
    if (_hotspotLocation != nil && _placemark != nil) {
        NSDictionary *addressDict = _placemark.addressDictionary;
        self.addressLabel.text = ABCreateStringWithAddressDictionary(addressDict, YES);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowBirdDetailFromHotspot"]) {
        BirdDetailViewController *detailViewController = (BirdDetailViewController*)[segue destinationViewController];
        NSIndexPath *path = [self.obServationTableView indexPathForSelectedRow];
        [self.obServationTableView deselectRowAtIndexPath:path animated:YES];
        NSDictionary *dict = (NSDictionary*)[self.birdArray objectAtIndex:path.row];
        detailViewController.birdName = dict[@"comName"];
        detailViewController.sciName = dict[@"sciName"];
        detailViewController.currentLocation = self.currentLocation;
        detailViewController.managedOjbectContext = self.managedOjbectContext;
    }
}

#pragma mark - Table View Delegate & Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.birdArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.obServationTableView dequeueReusableCellWithIdentifier:@"ObservationCell"];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    UILabel *nameLabel = (UILabel*)[cell viewWithTag:2];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:3];
    NSDictionary *dict = (NSDictionary*)[self.birdArray objectAtIndex:indexPath.row];
    nameLabel.text = dict[@"comName"];
    
    //use image from core data
    if (self.allSpecies == nil) {
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if([vc isKindOfClass:[SpeciesViewController class]]) {
                self.allSpecies = [(SpeciesViewController *)vc allSpecies];
                break;
            }
        }
        if (self.allSpecies == nil ) {
            UINavigationController *nav = (UINavigationController *)self.tabBarController.viewControllers[2];
            [nav popToRootViewControllerAnimated:NO];
            SpeciesViewController *speciesVC = (SpeciesViewController *)[nav topViewController];
            self.allSpecies = speciesVC.allSpecies;
        }
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"com_name CONTAINS [cd] %@", dict[@"comName"]];
    NSArray *searchResult = [self.allSpecies filteredArrayUsingPredicate:predicate];
    if ([searchResult count] >0) {
        BirdInfo *birdInfo = (BirdInfo *)searchResult[0];
        imageView.layer.cornerRadius = 6;
        imageView.clipsToBounds = YES;
        imageView.image = [UIImage imageWithData:birdInfo.thumbnailImage.image];
    }

    dateLabel.text = dict[@"obsDt"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.obServationTableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"ShowBirdDetailFromHotspot" sender:cell];
}

@end
