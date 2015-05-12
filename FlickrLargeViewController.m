//
//  FlickrLargeViewController.m
//  ZTBird
//
//  Created by Zhuo Tao on 7/9/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import "FlickrLargeViewController.h"
#import "Flickr.h"
#import "FlickrPhoto.h"
#import "WikiWebViewController.h"

@interface FlickrLargeViewController ()
@property (nonatomic, weak) IBOutlet UILabel *ownerInfoLabel;
- (IBAction)done:(id)sender;
- (IBAction)visitFlickr:(id)sender;
@end

@implementation FlickrLargeViewController
{
    NSOperationQueue *_queue;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
   // if (self.flickrPhoto.largeImage) {
    //    self.imageView.image = self.flickrPhoto.largeImage;
    //} else {
     //   self.imageView.image = self.flickrPhoto.thumbnail;
        //[Flickr loadImageForPhoto:self.flickrPhoto thumbnail:NO completionBlock:^(UIImage *photoImage, NSError *error) {
          //  if(!error) {
           //     dispatch_async(dispatch_get_main_queue(), ^{ self.imageView.image =
             //       self.flickrPhoto.largeImage;
              //  });
           // }
        //}];

    //}
}

- (void)viewDidLoad
{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    [super viewDidLoad];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = self.image;
    /*UIBarButtonItem *favButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
                                                                             target:self
                                                                             action:@selector(addToFavorite)];
    self.navigationItem.rightBarButtonItem = favButton;*/
    
   // self.linkLabel.userInteractionEnabled = YES;
    //UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnLink:)];
   // [self.linkLabel addGestureRecognizer:recognizer];
    
    //load owner info
    NSString *urlString = [NSString stringWithFormat:kFlickrOwnerInfo,self.ownerID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userDict = (NSDictionary *)responseObject;
            NSString *realName = userDict[@"person"][@"realname"][@"_content"];
            if (! realName) realName = userDict[@"person"][@"username"][@"_content"];
            self.ownerInfoLabel.text = [NSString stringWithFormat:@"©%@", realName];

        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Error loading owner info!");
    }];
    [_queue addOperation:operation];
}

-(void)visitFlickr:(id)sender
{
    [self performSegueWithIdentifier:@"ShowFlickrWebPage" sender:nil];
}

- (void)tapOnLink:(UIGestureRecognizer *)sender
{
    //[self performSegueWithIdentifier:@"ShowFlickrWebPage" sender:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //ShowFlickrWebPage
    if ([segue.identifier isEqualToString:@"ShowFlickrWebPage"]) {
        WikiWebViewController *wikiViewController = [segue destinationViewController];
        wikiViewController.urlString = self.flickrWebPageURL;
        wikiViewController.pageTitle = @"Flickr";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
}

@end
