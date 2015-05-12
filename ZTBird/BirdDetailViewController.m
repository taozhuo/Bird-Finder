//
//  BirdDetailViewController.m
//  ZTBird
//
//  Created by Zhuo Tao on 7/4/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import "BirdDetailViewController.h"
#import "FlickrCell.h"
#import "FlickrLargeViewController.h"
#import "WikiWebViewController.h"
#import "BirdInfo.h"
#import "BirdImage.h"
#import "HotspotPin.h"
#import "HotSpotDetailViewController.h"
#import "Favorite.h"
#import "FavoritesViewController.h"
#import "LargeMapViewController.h"

@interface BirdDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MKMapViewDelegate>

@property (nonatomic, strong) NSArray *flickrResults;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) MKMapView *mapView2;
@property (nonatomic, weak) IBOutlet UILabel *notFoundOnMapLabel;
@property (nonatomic, weak) IBOutlet UIButton *favButton;
- (IBAction)favClicked:(id)sender;

@end

@implementation BirdDetailViewController
{
    NSArray *_photos;
    NSOperationQueue *_queue;
    UIWebView *_webView;
    NSArray *_freeBaseResult;
    BOOL _coredataSaved;
    NSMutableDictionary *_images;
    NSArray *_hotspots;
    NSMutableArray *_hotspotPins;
    BOOL _saved;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) { 
        if (self) {
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.mapView) self.mapView.delegate = self;
    [self.navigationItem setHidesBackButton:NO];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _coredataSaved = NO;
    _saved = NO;
    
    self.textDescription.text = @"Loading...";
    [self loadFreeBase1];
    //[self loadWikiExtract];
    [self loadPicArray];
    self.nameLabel.text = self.birdName;
    self.tableView.sectionHeaderHeight = 0.0;
    self.tableView.sectionFooterHeight = 5.0;
    _images = [[NSMutableDictionary alloc] init];
    self.collectionView.allowsMultipleSelection = NO;
    
    //set up map view
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, 50000, 50000);
    [self.mapView setRegion:region animated:NO];
    self.mapView.showsUserLocation = YES;
    
    //detect tapping on mapview
    UITapGestureRecognizer *tapOnMap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnMap)];
    [self.mapView addGestureRecognizer:tapOnMap];

    //set up favorite button
    NSString *matchedName = [NSString stringWithFormat:@"%@^%@", self.birdName, self.sciName];
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
    
    [self loadObsOfASpecies];
}

- (void)favClicked:(id)sender
{
    if (_saved) return;
    
    //save to core data
    Favorite *favEntity = [NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:self.managedOjbectContext];
    favEntity.type = [NSNumber numberWithInt:0];
    NSString *matchedName = [NSString stringWithFormat:@"%@^%@", self.birdName, self.sciName];
    favEntity.name = matchedName;
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
    /*if (mapView == self.mapView2) {
        [self dismiss];
    }*/
    
    [self performSegueWithIdentifier:@"ShowHotspotDetailFromBirdDetail" sender:view];
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
        /*
        UIImage *image = [UIImage imageNamed:@"binoculars_filled-50.png"];
        
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

- (void)tapOnMap
{
    /*[[self tableView] beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    [[self tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self tableView] endUpdates];

    [UIView animateWithDuration:.4f animations:^{
        self.mapView.frame = CGRectMake(0,
                                        0,
                                        self.mapView.frame.size.width,
                                        self.mapView.frame.size.height * 3);
    }];*/
    
    if (self.mapView2 == nil) self.mapView2 = [[MKMapView alloc] initWithFrame:CGRectMake(0,
                                                           0,
                                                           self.tableView.frame.size.width,
                                                           self.tableView.frame.size.height)];
    [self.view.superview addSubview:self.mapView2];
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, 50000, 50000);
    [self.mapView2 setRegion:region animated:NO];
    self.mapView2.showsUserLocation = YES;
    self.mapView2.delegate = self;
    self.mapView.delegate = nil;
    if (_hotspotPins.count > 0) [self.mapView2 addAnnotations:_hotspotPins];
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];

    //[self performSegueWithIdentifier:@"ShowLargeMapView" sender:nil];
    
}

- (void)dismiss
{
    [self.mapView2 removeFromSuperview];
    self.mapView2.delegate = nil;
    self.mapView.delegate = self;
    [self.navigationItem setHidesBackButton:NO];
    self.navigationItem.rightBarButtonItem = nil;
}


- (void)loadObsOfASpecies
{
    double longitude = self.currentLocation.coordinate.longitude;
    double latitude = self.currentLocation.coordinate.latitude;
    NSString *escapedSearchText = [self.sciName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString;
    urlString =[NSString
                stringWithFormat:kEBirdURLObsOfASpecies,longitude,latitude,escapedSearchText];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        _hotspots = responseObject;
        [self buildHotspotPins];
        [self.mapView addAnnotations:_hotspotPins];
        if (_hotspots.count == 0) {
            self.mapView.alpha = 0.5;
            self.mapView.scrollEnabled = NO;
            self.mapView.zoomEnabled = NO;
            self.notFoundOnMapLabel.text = @"Not found in this area";
        } else {
            NSDictionary *dict = _hotspots[0];
            CLLocationCoordinate2D coordinateFirst = CLLocationCoordinate2DMake([dict[@"lat"] doubleValue],
                                                                              [dict[@"lng"] doubleValue]);
            MKCoordinateRegion region =
            MKCoordinateRegionMakeWithDistance(coordinateFirst, 50000, 50000);
            [self.mapView setRegion:region animated:NO];
            //[self processHotspotArray];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Failed");
    }];
    [_queue addOperation:operation];
}

- (void)processHotspotArray
{
    NSMutableString *allLocID = [[NSMutableString alloc] init];
    for (NSDictionary *dict in _hotspots) {
        [allLocID appendString:[NSString stringWithFormat:@"r=%@&", dict[@"locID"]]];
    }
    NSString *urlString;
    urlString =[NSString stringWithFormat:kEbirdObsSpAtHotspot, allLocID, self.sciName];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Failed processHotspotArray");
    }];
    [_queue addOperation:operation];
}

- (void)loadWikiExtract
{
    NSString *escapedSearchText = [self.birdName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:kWikiURLExtract, escapedSearchText];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"WikiExtract Failed");
    }];
    [_queue addOperation:operation];
}

-(void)loadFreeBase1
{
    NSString *escapedSearchText = [self.birdName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:kFreeBaseUrlQuery, escapedSearchText];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        _freeBaseResult = [responseObject objectForKey:@"result"];
        NSString *mid=nil;
        for (NSDictionary *dict in _freeBaseResult) {
            NSString *tempStr = [[dict objectForKey:@"notable"] objectForKey:@"name"];
            if ([tempStr isEqualToString:@"Biological Species"]) {
                mid = [dict objectForKey:@"mid"];
                [self loadFreeBase2:mid];
                break;
            }
        }
            
    }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        //[alert show];*/
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    }];
    
    [_queue addOperation:operation];
}

-(NSString *)loadFreeBase2:(NSString *)mid
{
    if (mid) {
        NSString *urlString = [NSString stringWithFormat:kFreeBaseUrlDescription, mid];
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *tempArr = [[[responseObject objectForKey:@"property"] objectForKey:@"/common/topic/description"] objectForKey:@"values"];
            self.textDescription.text = [tempArr[0] objectForKey:@"value"];
        }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
          //  [alert show];*/
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
        
        [_queue addOperation:operation];
    }
    return nil;
}

- (void)loadPicArray
{
    //loading pictures array
    NSString *escapedSearchText = [self.sciName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:kFlickrSearchURl, escapedSearchText];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        _photos = [[responseObject objectForKey:@"photos"] objectForKey:@"photo"];
        [self.collectionView reloadData];
    }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];*/
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    }];
    
    [_queue addOperation:operation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) return CGFLOAT_MIN;
    else return 10.0f;
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    //UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    //header.textLabel.font = [UIFont boldSystemFontOfSize:10.0f];
    //header.textLabel.textColor = [UIColor orangeColor];
}


#pragma mark - Collection View Data Source etc.

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_photos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FlickrCell *cell = (FlickrCell *)[collectionView
                                  dequeueReusableCellWithReuseIdentifier:@"FlickrCell"forIndexPath:indexPath];
    //cell.backgroundColor = [UIColor whiteColor];
    
    //load thumbnail picture for cell
    NSDictionary *photo = _photos[indexPath.row];
    NSString *photoURLString =
    [NSString stringWithFormat: kFlickrSinglePicThumbNailUrl,
     [photo objectForKey:@"farm"], [photo objectForKey:@"server"],
     [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
    
    NSURL *imageURL = [NSURL URLWithString:photoURLString];
    NSURLRequest *imageRequst = [NSURLRequest requestWithURL:imageURL];
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:100];
    [spinner startAnimating];

    [cell.imageView setImageWithURLRequest:imageRequst placeholderImage:[UIImage imageNamed:@"Placeholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [spinner stopAnimating];
        NSNumber *key = [NSNumber numberWithLong:indexPath.row];
        [_images setObject:image forKey:key];
        
        //crop the image to squre
        CGSize size = [image size];
        CGRect rect;
        if (size.height > size.width) {
            rect = CGRectMake(0, (size.height-size.width)/2 + size.width, size.width, size.width);
        } else {
            rect = CGRectMake((size.width-size.height)/2, 0, size.height, size.height);
        }
        //CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
        //UIImage *image2 = [UIImage imageWithCGImage:imageRef];
        //CGImageRelease(imageRef);
        //cell.imageView.image = image2;
        
        CGSize size200 = CGSizeMake(200, 200);
        UIGraphicsBeginImageContext(size200);
        [image drawInRect:CGRectMake(0, 0, size200.width, size200.height)];
        
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        cell.imageView.layer.cornerRadius = 10;
        cell.imageView.clipsToBounds = YES;
        cell.imageView.image = newImage;
        UIGraphicsEndImageContext();
        
        //self.hasLoaded = YES;
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
       // [alert show];*/
        [spinner stopAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
    
    //FlickrPhoto *photo = (FlickrPhoto*)self.flickrResults[indexPath.row];
    //cell.imageView.image = photo.thumbnail;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"collection view didselect");
    //FlickrPhoto *photo = (FlickrPhoto*)self.flickrResults[indexPath.row];
    //NSLog(@"count: %lu, row: %ld",(unsigned long)[_images count], (long)indexPath.row);
   // self.imageView.contentMode = UIViewContentModeScaleAspectFill;
   // self.imageView.image = (UIImage *)_images[indexPath.row];
    
    //save image to core data
    NSNumber *key = [NSNumber numberWithLong:indexPath.row];
    UIImage *image = (UIImage *)[_images objectForKey:key];
    
    /*CGSize size200 = CGSizeMake(200, 200);
    UIGraphicsBeginImageContext(size200);
    [image drawInRect:CGRectMake(0, 0, size200.width, size200.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //BirdImage *imageObj = [NSEntityDescription insertNewObjectForEntityForName:@"BirdImage"
//                                                        inManagedObjectContext:self.birdInfo.managedObjectContext];
    
    self.birdInfo.thumbnailImage.image = UIImageJPEGRepresentation(newImage,0.8);;
    UIGraphicsEndImageContext();

    _coredataSaved = YES;
    NSError *error;
    
        if (self.birdInfo.managedObjectContext != nil && self.birdInfo.managedObjectContext.hasChanges) {
            NSLog(@"Save image to core data");
            if (![self.birdInfo.managedObjectContext save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }*/
    [self performSegueWithIdentifier:@"ShowLargePhoto" sender:image];
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowLargePhoto"]) {
        FlickrLargeViewController *largePhotoViewController = [segue destinationViewController];
        largePhotoViewController.image = (UIImage *)sender;
        NSArray *arrayOfIndexPaths = [self.collectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath = [arrayOfIndexPaths firstObject];
        NSDictionary *photo = _photos[indexPath.row];
        largePhotoViewController.flickrWebPageURL = [NSString stringWithFormat:kFlickrWebPageURL, photo[@"owner"], photo[@"id"]];
        largePhotoViewController.ownerID = photo[@"owner"];
        largePhotoViewController.imageID = photo[@"id"];
    } else if ([segue.identifier isEqualToString:@"ShowLargeMapView"]) {
        UINavigationController *nav = [segue destinationViewController];
        LargeMapViewController *largeMapVC = (LargeMapViewController *)[nav topViewController];
        largeMapVC.hotspots = _hotspots;
        largeMapVC.birdName = self.birdName;
        largeMapVC.currentLocation = self.currentLocation;
        largeMapVC.managedOjbectContext = self.managedOjbectContext;
    } else if ([segue.identifier isEqualToString:@"ShowWiki"]) {
        WikiWebViewController *wikiViewController = [segue destinationViewController];
        NSString *escapedSearchText = [self.birdName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *urlString = [NSString stringWithFormat:kWikiUrl, escapedSearchText];
        wikiViewController.urlString = urlString;
        wikiViewController.pageTitle = @"Wiki";
    } else if ([segue.identifier isEqualToString:@"ShowHotspotDetailFromBirdDetail"]) {
        HotSpotDetailViewController *detailViewController = (HotSpotDetailViewController *)[segue destinationViewController];
        MKAnnotationView *annotationView = (MKAnnotationView*)sender;
        NSString *locName = annotationView.annotation.title;
        detailViewController.locName = locName;
        detailViewController.currentLocation = self.currentLocation;
        detailViewController.coordinate = annotationView.annotation.coordinate;
        detailViewController.managedOjbectContext = self.managedOjbectContext;
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

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UICollectionview FlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /*FlickrPhoto *photo = self.flickrResults[indexPath.row];
    CGSize retval = photo.thumbnail.size.width > 0 ? photo.thumbnail.size : CGSizeMake(100, 100);
    retval.height += 35;
    retval.width += 35;
    return retval;*/
    CGSize retval = self.collectionView.frame.size;
    retval.width = retval.height;
    return retval;
}

/*- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(50, 20, 50, 20);
}*/

@end
