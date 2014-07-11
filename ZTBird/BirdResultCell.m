//
//  BirdResultCell.m
//  ZTBird
//
//  Created by Zhuo Tao on 2/22/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import "BirdResultCell.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation BirdResultCell
{
    NSOperationQueue *_queue;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureForDictionary:(NSDictionary *)dict
                     imageDict:(NSMutableDictionary *)imageDict
{
    if (self.hasLoaded) return;
    
    self.nameLabel.text = dict[@"comName"];
    self.locationLabel.text = dict[@"locName"];
    NSString *imageURLString = imageDict[dict[@"comName"]];
    NSURL *imageURL = [NSURL URLWithString:imageURLString];
    NSURLRequest *imageRequst = [NSURLRequest requestWithURL:imageURL];
    
    [self.activityView setHidden:YES];
    //[self.activityView startAnimating];
    [self.imageView setImageWithURLRequest:imageRequst placeholderImage:[UIImage imageNamed:@"Placeholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
       // [self.activityView setHidden:YES];
     //   [self.activityView stopAnimating];
        
        
        CGSize size = CGSizeMake(60, 60);
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        self.imageView.image = newImage;
        UIGraphicsEndImageContext();
        self.hasLoaded = YES;
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [self.activityView setHidden:YES];
        [self.activityView stopAnimating];
    }];
}
@end
