//
//  FilterViewController.h
//  ZTBird
//
//  Created by Zhuo Tao on 3/2/15.
//  Copyright (c) 2015 Zhuo Tao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterDelegate;

@interface FilterViewController : UITableViewController
@property (nonatomic, weak) id<FilterDelegate> delegate;
@property (nonatomic) int distance;
@property (nonatomic) int backdays;

- (IBAction)exit:(id)sender;
- (IBAction)done:(id)sender;

@end

@protocol FilterDelegate <NSObject>

- (void)filterViewController:(FilterViewController *)vc
                    distance:(int)newDistance
                     backday:(int)newBackday;

@end

