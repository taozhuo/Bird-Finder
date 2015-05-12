//
//  BirdInfo.h
//  ZTBird
//
//  Created by Zhuo Tao on 2/12/15.
//  Copyright (c) 2015 Zhuo Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BirdImage;

@interface BirdInfo : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * com_name;
@property (nonatomic, retain) NSString * sci_name;
@property (nonatomic, retain) NSString * taxon_id;
@property (nonatomic, retain) BirdImage *thumbnailImage;

@end
