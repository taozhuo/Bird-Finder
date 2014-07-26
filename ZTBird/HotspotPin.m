//
//  HotspotPin.m
//  ZTBird
//
//  Created by Zhuo Tao on 7/26/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import "HotspotPin.h"

@implementation HotspotPin

- (id)initWithCoordinate:(CLLocationCoordinate2D)location title:(NSString *)pinName subtitle:(NSString *)pinDescription
{
    self = [super init];
    if (self) {
        _coordinate = location;
        _title = pinName;
        _subtitle = pinDescription;
    }
    return self;
}

@end
