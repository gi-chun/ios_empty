//
//  CPPriceDetailReviewItemCell.h
//  11st
//
//  Created by 김응학 on 2015. 7. 9..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPPriceDetailReviewItemCellDelegate;

@interface CPPriceDetailReviewItemCell : UITableViewCell

@property (nonatomic, weak) id <CPPriceDetailReviewItemCellDelegate> delegate;
@property (nonatomic, strong) NSDictionary *item;
@property (nonatomic, assign) BOOL isNoItem;
@property (nonatomic, assign) NSInteger tabIdx;
@property (nonatomic, assign) BOOL isLastCell;
@property (nonatomic, assign) BOOL isMore;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end

@protocol CPPriceDetailReviewItemCellDelegate <NSObject>
@optional
- (void)didTouchBannerButton:(NSString *)url;
- (void)reviewItemCellShowMoreItem:(NSInteger)tabIdx;
@end