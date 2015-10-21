//
//  CPProductInfoSmartOptionContentView.h
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 10..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPProductInfoSmartOptionContentView;
@class ProductSmartOptionModel;

@protocol CPProductInfoSmartOptionContentViewDelegate <NSObject>

@required
- (void)productInfoSmartOptionContentViewImageDownloadedAtIndex:(NSNumber *)index withHeight:(NSNumber *)height;

@optional
- (void)productInfoSmartOptionContentView:(CPProductInfoSmartOptionContentView *)cell didClickedOptionDetailButton:(ProductSmartOptionModel *)option;
- (void)productInfoSmartOptionContentView:(CPProductInfoSmartOptionContentView *)cell didClickedOptionSelectButton:(ProductSmartOptionModel *)option;

@end

@interface CPProductInfoSmartOptionContentView : UIView

+ (CGFloat)contentHeight;

@property (nonatomic, strong) ProductSmartOptionModel *item;
@property (nonatomic, strong) NSNumber *index;
@property (nonatomic, weak) id<CPProductInfoSmartOptionContentViewDelegate> delegate;

@end