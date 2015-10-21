//
//  CPProductPrdPromotionView.m
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 14..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductPrdPromotionView.h"

#define kSeriesDefaultHeight  44

@interface CPProductPrdPromotionView()
{
    NSDictionary *product;
    NSDictionary *prdPromotionInfo;
}

@end

@implementation CPProductPrdPromotionView

- (void)releaseItem
{
    if (product)            product = nil;
    if (prdPromotionInfo)   prdPromotionInfo = nil;
}

- (void)removeFromSuperview
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    [super removeFromSuperview];
}

- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct
{
    if (self = [super initWithFrame:frame]) {
        
        product = [aProduct copy];
        
        CGFloat frameHeight = 0;
        
        if (product[@"prdPromotion"]) {
            prdPromotionInfo = [product[@"prdPromotion"] copy];
            
            [self initData];
            [self initLayout];
            
            frameHeight = 84;
        }
        else {
            frameHeight = 0;
        }
        
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                frameHeight);
    }
    return self;
}

- (void)initData
{
    self.selectedIndex = -1;
}

- (void)initLayout
{
    [self setBackgroundColor:UIColorFromRGB(0xe3e3e8)];;
    
    NSString *title = prdPromotionInfo[@"label"];
    CGSize labelSize = GET_STRING_SIZE(title, [UIFont boldSystemFontOfSize:15], kScreenBoundsWidth);
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), kSeriesDefaultHeight)];
    [titleView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self addSubview:titleView];
    
    //label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, labelSize.width, CGRectGetHeight(titleView.frame))];
    [titleLabel setTextColor:UIColorFromRGB(0x333333)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [titleLabel setText:title];
    [titleView addSubview:titleLabel];
    
    
    //상품목록
    UIImage *prdPromotionListImage = [[UIImage imageNamed:@"layer_pd_inputbox.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    NSString *prdPromotionStr = self.selectedIndex < 0 ? prdPromotionInfo[@"text"] : prdPromotionInfo[@"promotionLayer"][self.selectedIndex][@"martPrmtNm"];
    
    UIButton *prdPromotionListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [prdPromotionListButton setFrame:CGRectMake(10, CGRectGetMaxY(titleLabel.frame)+8, kScreenBoundsWidth-20, 32)];
    [prdPromotionListButton setTitle:prdPromotionStr forState:UIControlStateNormal];
    [prdPromotionListButton setTitleColor:UIColorFromRGB(0xb6b6b6) forState:UIControlStateNormal];
    [prdPromotionListButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [prdPromotionListButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [prdPromotionListButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 9, 0, 0)];
    [prdPromotionListButton setBackgroundImage:prdPromotionListImage forState:UIControlStateNormal];
    [prdPromotionListButton addTarget:self action:@selector(touchPrdPromotionList:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:prdPromotionListButton];
    
    UIImageView *inputDownIconView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(prdPromotionListButton.frame)-32, 0, 32, 32)];
    [inputDownIconView setImage:[UIImage imageNamed:@"layer_pd_input_down.png"]];
    [prdPromotionListButton addSubview:inputDownIconView];
    
    
}

//배송지정보 세팅
- (void)setPromotionView
{
    [self initLayout];
}

#pragma mark - Selectors

//덤상품 목록
- (void)touchPrdPromotionList:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(drawLayerPrdPromotionList:)]) {
        [self.delegate drawLayerPrdPromotionList:sender];
    }
}

@end