//
//  CPProductInfoSmartOptionTableViewCell.h
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 10..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ProductSmartOptionModel.h"

@class CPProductInfoSmartOptionTableViewCell;

@protocol CPProductInfoSmartOptionTableViewCellDelegate <NSObject>

@required
- (void)productInfoSmartOptionTableViewCellImageDownloadedAtIndex:(NSNumber *)index withHeight:(NSNumber *)height;

@optional
- (void)productInfoSmartOptionTableViewCell:(CPProductInfoSmartOptionTableViewCell *)cell didClickedOptionDetailButton:(ProductSmartOptionModel *)option;
- (void)productInfoSmartOptionTableViewCell:(CPProductInfoSmartOptionTableViewCell *)cell didClickedOptionSelectButton:(ProductSmartOptionModel *)option;

@end

@interface CPProductInfoSmartOptionTableViewCell : UITableViewCell

+ (CGFloat)contentHeight;

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSNumber *index;
@property (nonatomic, assign) ProductSmartOptionCellType productSmartOptionCellType;
@property (nonatomic, weak) id<CPProductInfoSmartOptionTableViewCellDelegate> delegate;

@end