//
//  Favorite.h
//  ZTBird
//
//  Created by Zhuo Tao on 12/7/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Favorite : NSManagedObject

@property (nonatomic, retain) NSNumber * type;  //0 - species; 1 - hotspot
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;

@end
