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

@interface FlickrLargeViewController ()
@property (nonatomic,weak) IBOutlet UIImageView *imageView;
- (IBAction)done:(id)sender;
@end

@implementation FlickrLargeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.flickrPhoto.largeImage) {
        self.imageView.image = self.flickrPhoto.largeImage;
    } else {
        self.imageView.image = self.flickrPhoto.thumbnail;
        [Flickr loadImageForPhoto:self.flickrPhoto thumbnail:NO completionBlock:^(UIImage *photoImage, NSError *error) {
            if(!error) {
                dispatch_async(dispatch_get_main_queue(), ^{ self.imageView.image =
                    self.flickrPhoto.largeImage;
                });
            }
        }];

    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
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
