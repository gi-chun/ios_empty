//
//  CPPriceDetailSpecCell.h
//  11st
//
//  Created by 김응학 on 2015. 7. 7..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPPriceDetailSpecCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *item;
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
