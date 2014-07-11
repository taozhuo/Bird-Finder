//
//  BirdDetailViewController.h
//  ZTBird
//
//  Created by Zhuo Tao on 7/4/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BirdDetailViewController : UIViewController
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, assign) NSString *birdName;

@end
