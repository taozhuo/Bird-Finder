//
//  FlickrLargeViewController.h
//  ZTBird
//
//  Created by Zhuo Tao on 7/9/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FlickrPhoto;

@interface FlickrLargeViewController : UIViewController
@property (nonatomic,strong) FlickrPhoto *flickrPhoto;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic,weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *linkLabel;
@property (nonatomic, strong) NSString *flickrWebPageURL;
@property (nonatomic, strong) NSString *ownerID;
@property (nonatomic, strong) NSString *imageID;

@end
