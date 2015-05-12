//
//  BirdDetailViewController.h
//  ZTBird
//
//  Created by Zhuo Tao on 7/4/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BirdInfo;
@class BirdImage;

@interface BirdDetailViewController : UITableViewController
@property (nonatomic, copy) NSString *birdName;
@property (nonatomic, copy) NSString *sciName;
@property (nonatomic, weak) IBOutlet UITextView *textDescription;
@property (nonatomic, strong) BirdInfo *birdInfo;
@property (nonatomic, strong) BirdImage *birdImage;
@property (nonatomic, strong) NSManagedObjectContext *managedOjbectContext;
@property (nonatomic, strong) CLLocation *currentLocation;

@end
