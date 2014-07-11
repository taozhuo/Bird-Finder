//
//  FirstViewController.h
//  ZTBird
//
//  Created by Zhuo Tao on 2/23/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface FirstViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UIButton *birdButton;
@property (nonatomic, weak) IBOutlet UIButton *hotspotButton;


@end
