//
//  BirdResultCell.m
//  ZTBird
//
//  Created by Zhuo Tao on 2/22/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import "BirdResultCell.h"

@implementation BirdResultCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
