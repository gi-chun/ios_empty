//
//  CPPriceDetailCompPrcListCell.h
//  11st
//
//  Created by 김응학 on 2015. 7. 8..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPPriceDetailCompPrcListCellDelegate;

@interface CPPriceDetailCompPrcListCell : UITableViewCell

@property (nonatomic, weak) id <CPPriceDetailCompPrcListCellDelegate> delegate;
@property (nonatomic, strong) NSDictionary *item;
@property (nonatomic, assign) BOOL isLastCell;
@property (nonatomic, assign) BOOL isMore;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end

@protocol CPPriceDetailCompPrcListCellDelegate <NSObject>
@optional
- (void)didTouchBannerButton:(NSString *)url;
- (void)compPrcListCellShowNextItem;
@end