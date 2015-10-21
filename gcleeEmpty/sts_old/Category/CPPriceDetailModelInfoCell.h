//
//  CPPriceDetailModelInfoCell.h
//  11st
//
//  Created by 11st_mac_17 on 2015. 7. 6..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPPriceDetailModelInfoCellDelegate;

@interface CPPriceDetailModelInfoCell : UITableViewCell

@property (nonatomic, weak) id <CPPriceDetailModelInfoCellDelegate> delegate;
@property (nonatomic, strong) NSDictionary *item;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end

@protocol CPPriceDetailModelInfoCellDelegate <NSObject>
@optional
- (void)didTouchBannerButton:(NSString *)url;
@end
