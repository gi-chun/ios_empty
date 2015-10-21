//
//  CPPriceDetailSameCategoryModelsCell.h
//  11st
//
//  Created by 김응학 on 2015. 7. 9..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPPriceDetailSameCategoryModelsCellDelegate;

@interface CPPriceDetailSameCategoryModelsCell : UITableViewCell

@property (nonatomic, weak) id <CPPriceDetailSameCategoryModelsCellDelegate> delegate;
@property (nonatomic, strong) NSDictionary *item;
@property (nonatomic, strong) NSString *groupName;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end

@protocol CPPriceDetailSameCategoryModelsCellDelegate <NSObject>
@optional
- (void)priceDetailSameCategoryModelsCell:(CPPriceDetailSameCategoryModelsCell *)cell onTouchChangeModel:(NSString *)modelNo;
@end