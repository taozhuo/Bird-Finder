//
//  ChangeLocationViewController.h
//  ZTBird
//
//  Created by Zhuo Tao on 2/15/15.
//  Copyright (c) 2015 Zhuo Tao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChangeLocationDelegate;

@interface ChangeLocationViewController : UITableViewController
@property (nonatomic, weak) id<ChangeLocationDelegate> delegate;

- (IBAction)exit:(id)sender;


@end

@protocol ChangeLocationDelegate <NSObject>

- (void)changeLocationViewController:(ChangeLocationViewController *)vc didUpdateLocation:(id)newLocation;

@end
