//
//  BirdDetailViewController.m
//  ZTBird
//
//  Created by Zhuo Tao on 7/4/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import "BirdDetailViewController.h"
#import "Flickr.h"
#import "FlickrPhoto.h"
#import "FlickrCell.h"
#import "FlickrLargeViewController.h"

#define kFlickrAPIKey @"97bf61b0cb5de432ad70112467e1d734";

@interface BirdDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *flickrResults;
@property (nonatomic, strong) Flickr *flickr;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@end

@implementation BirdDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) { 
       
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nameLabel.text = self.birdName;
    self.flickrResults = [@{} mutableCopy];
    self.flickr = [[Flickr alloc] init];
    
    [self.flickr searchFlickrForTerm:self.birdName completionBlock:^(NSString *searchTerm, NSArray *results, NSError *error) {
        if(results && [results count] > 0) {
            self.flickrResults = results;
            NSLog(@"Found %d images", [results count]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
            
        } else {
            NSLog(@"Error searching Flickr: %@", error.localizedDescription);
        } }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection View Data Source etc.

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.flickrResults count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FlickrCell *cell = (FlickrCell *)[collectionView
                                  dequeueReusableCellWithReuseIdentifier:@"FlickrCell"forIndexPath:indexPath];
    //cell.backgroundColor = [UIColor whiteColor];
    FlickrPhoto *photo = (FlickrPhoto*)self.flickrResults[indexPath.row];
    cell.imageView.image = photo.thumbnail;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FlickrPhoto *photo = (FlickrPhoto*)self.flickrResults[indexPath.row];
    [self performSegueWithIdentifier:@"ShowLargePhoto" sender:photo];
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowLargePhoto"]) {
        FlickrLargeViewController *largePhotoViewController = [segue destinationViewController];
        largePhotoViewController.flickrPhoto = sender;
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
