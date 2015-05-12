//
//  BirdImage.h
//  ZTBird
//
//  Created by Zhuo Tao on 2/12/15.
//  Copyright (c) 2015 Zhuo Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BirdInfo;

@interface BirdImage : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) BirdInfo *bird;

@end
