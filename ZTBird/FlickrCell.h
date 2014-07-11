//
//  FlickrCell.h
//  ZTBird
//
//  Created by Zhuo Tao on 7/5/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlickrPhoto;
@interface FlickrCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) FlickrPhoto *photo;

@end
