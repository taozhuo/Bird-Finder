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

@interface BirdDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *flickrResults;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@end

@implementation BirdDetailViewController
{
    NSArray *_photos;
    NSOperationQueue *_queue;

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


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nameLabel.text = self.birdName;
    
    //loading pictures array
    NSString *escapedSearchText = [self.birdName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:kFlickrUrl, escapedSearchText];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"%@",urlString);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        _photos = [[responseObject objectForKey:@"photos"] objectForKey:@"photo"];
        NSLog(@"found %d photoes!", [_photos count]);
        [self.collectionView reloadData];
    }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed! %@", error);
    }];
    
    [_queue addOperation:operation];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

    [cell.imageView setImageWithURLRequest:imageRequst placeholderImage:[UIImage imageNamed:@"Placeholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        CGSize size = CGSizeMake(100, 100);
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        cell.imageView.image = newImage;
        UIGraphicsEndImageContext();
        //self.hasLoaded = YES;
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
    
    
    //FlickrPhoto *photo = (FlickrPhoto*)self.flickrResults[indexPath.row];
    //cell.imageView.image = photo.thumbnail;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //FlickrPhoto *photo = (FlickrPhoto*)self.flickrResults[indexPath.row];
    //[self performSegueWithIdentifier:@"ShowLargePhoto" sender:photo];
    //[self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
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
