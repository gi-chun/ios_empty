//
//  CPProductDetailBestProductItemCell.h
//  11st
//
//  Created by 김응학 on 2015. 7. 9..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPProductDetailBestProductItemCellDelegate;

@interface CPProductDetailBestProductItemCell : UICollectionViewCell

@property (nonatomic, weak) id <CPProductDetailBestProductItemCellDelegate> delegate;
@property (nonatomic, strong) NSDictionary *item;
@property (nonatomic, assign) BOOL isMore;

- (void)updateCell;

@end

@protocol CPProductDetailBestProductItemCellDelegate <NSObject>
@optional
- (void)productDetailBestProductItemCellOnTouchMoreItem;
- (void)productDetailBestProductItemCell:(CPProductDetailBestProductItemCell *)cell onTouchLinkUrl:(NSString *)linkUrl;
@end


