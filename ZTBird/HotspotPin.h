//
//  HotspotPin.h
//  ZTBird
//
//  Created by Zhuo Tao on 7/26/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HotspotPin : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, readonly, copy) NSString *title;

- (id)initWithCoordinate:(CLLocationCoordinate2D)location title:(NSString *)pinName subtitle:(NSString *)pinDescription;

@end
