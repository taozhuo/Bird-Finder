//
//  LargeMapViewController.m
//  ZTBird
//
//  Created by Zhuo Tao on 4/19/15.
//  Copyright (c) 2015 Zhuo Tao. All rights reserved.
//

#import "LargeMapViewController.h"
#import "HotspotPin.h"
#import "HotSpotDetailViewController.h"

@interface LargeMapViewController () <MKMapViewDelegate>
-(IBAction)dismiss:(id)sender;

@end

@implementation LargeMapViewController
{
    NSMutableArray *_hotspotPins;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.birdName;
    //set up map view
    self.mapView.showsUserLocation = YES;
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, 50000, 50000);
    [self.mapView setRegion:region animated:NO];
    
    [self buildHotspotPins];
    [self.mapView addAnnotations:_hotspotPins];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismiss:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Map view related

- (void)buildHotspotPins
{
    if (_hotspotPins == nil) _hotspotPins = [[NSMutableArray alloc] init];
    [_hotspotPins removeAllObjects];
    for (NSDictionary *dict in _hotspots) {
        CLLocationCoordinate2D newCoordinate = CLLocationCoordinate2DMake([dict[@"lat"] doubleValue],
                                                                          [dict[@"lng"] doubleValue]);
        HotspotPin *newPin = [[HotspotPin alloc] initWithCoordinate:newCoordinate
                                                              title:dict[@"locName"]
                                                           subtitle:[NSString stringWithFormat:@"Last observed:%@",dict[@"obsDt"]]];
        [_hotspotPins addObject:newPin];
    }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"ShowHotspotDetailFromLargeMap" sender:view];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if([annotation isEqual:[mapView userLocation]])
    {
        return nil;
    }
    static NSString *HotspotAnnotationViewID = @"hotspotAnnotationViewID";
    MKPinAnnotationView *pinView =
    (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:HotspotAnnotationViewID];
    if (pinView == nil) {
        MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:HotspotAnnotationViewID];
        
        customPinView.pinColor = MKPinAnnotationColorRed;
        customPinView.animatesDrop = NO;
        customPinView.canShowCallout = YES;
        
        //call out button
        customPinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return customPinView;
    }
    else {
        pinView.annotation = annotation;
    }
    return pinView;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowHotspotDetailFromLargeMap"]) {
        HotSpotDetailViewController *detailViewController = (HotSpotDetailViewController *)[segue destinationViewController];
        MKAnnotationView *annotationView = (MKAnnotationView*)sender;
        NSString *locName = annotationView.annotation.title;
        detailViewController.locName = locName;
        detailViewController.coordinate = annotationView.annotation.coordinate;
        detailViewController.managedOjbectContext = self.managedOjbectContext;
        detailViewController.currentLocation = self.currentLocation;
        //detailViewController.birdArray = _locationDict[locName];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:detailViewController.coordinate.latitude
                                                          longitude:detailViewController.coordinate.longitude];
        detailViewController.location = location;
        for(NSDictionary *dict in _hotspots) {
            if ([dict[@"locName"] isEqualToString:locName]) {
                detailViewController.locID = dict[@"locID"];
                break;
            }
        }
    }
}


@end
