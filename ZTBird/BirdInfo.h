//
//  BirdInfo.h
//  ZTBird
//
//  Created by Zhuo Tao on 7/16/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BirdInfo : NSManagedObject

@property (nonatomic, retain) NSString * com_name;
@property (nonatomic, retain) NSString * sci_name;
@property (nonatomic, retain) NSString * taxon_id;
@property (nonatomic, retain) NSString * category;

@end
