//
//  CPProductBadgeView.m
//  11st
//
//  Created by spearhead on 2015. 6. 24..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductBadgeView.h"
#import "HexColor.h"

@interface CPProductBadgeView()
{
    UIView *contentView;
}

@property (nonatomic, strong) NSArray *badgeImages;
@property (nonatomic, strong) NSArray *badgeLabels;

@end

@implementation CPProductBadgeView

- (void)releaseItem
{
    if (contentView)    contentView = nil;
}

- (void)removeFromSuperview
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    [super removeFromSuperview];
}

- (void)initSubviews
{
    [contentView removeFromSuperview];
    
    contentView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:contentView];
    
    NSMutableArray *newBadgeImages = [NSMutableArray new];
    NSMutableArray *newBadgeLabel = [NSMutableArray new];
    
    NSEnumerator *badgeEnumerator = (_badgeType == ProductBadgeTypeRound) ? [_badges reverseObjectEnumerator] : [_badges objectEnumerator];
    for (NSDictionary *badge in badgeEnumerator) {
        UIImageView *badgeView = [self badgeImageViewAtName:badge];
        if (badgeView)
        {
            [contentView addSubview:badgeView];
            [newBadgeImages addObject:badgeView];
        }
        
        if (_badgeType == ProductBadgeTypeRectangle) {
            UILabel *badgeLabel = [self badgeLabelWithInfo:badge];
            if (badgeLabel) {
                [contentView addSubview:badgeLabel];
                [newBadgeLabel addObject:badgeLabel];
            }
        }
    }
    
    _badgeImages = newBadgeImages;
    _badgeLabels = newBadgeLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rectClient = self.bounds;
    [contentView setFrame:rectClient];
    
    CGSize badgeSize = CGSizeZero;
    CGRect rectBadgeImage = CGRectZero;
    
    if (_badgeType == ProductBadgeTypeRound)
    {
        badgeSize = CGSizeMake(36.0f, 36.0f);
        rectBadgeImage = CGRectMake(rectClient.size.width - badgeSize.width,
                                    0.0f,
                                    badgeSize.width,
                                    badgeSize.height);
    }
    else
    {
        badgeSize = (self.isProductDetail ? CGSizeMake(48.f, 20.f) : CGSizeMake(40.0f, 16.0f));
        rectBadgeImage = CGRectMake(0.0f,
                                    0.0f,
                                    badgeSize.width,
                                    badgeSize.height);
    }
    
    CGFloat detailMargin = (self.isProductDetail ? 2.f : 0.f);
    CGFloat badgeMargin = (_badgeType == ProductBadgeTypeRound) ? (0.0f + detailMargin) : (1.0f + detailMargin);
    for (NSUInteger i = 0; i < _badgeImages.count; i++)
    {
        if (_badgeType == ProductBadgeTypeRound)
        {
            UIImageView *badgeView = _badgeImages[i];
            
            if (CGRectContainsRect(rectClient, rectBadgeImage))
            {
                badgeView.hidden = NO;
                
                [badgeView setFrame:rectBadgeImage];
                
                rectBadgeImage.origin.x -= rectBadgeImage.size.width;
            }
            else
            {
                badgeView.hidden = YES;
            }
        }
        else
        {
            UIImageView *badgeView = _badgeImages[i];
            UILabel *badgeLabel = _badgeLabels[i];
            
            CGSize stringSize = GET_STRING_SIZE(badgeLabel.text, (self.isProductDetail ? BOLDFONTSIZE(11) : BOLDFONTSIZE(9)), rectClient.size.width);
            rectBadgeImage.size.width = MAX(stringSize.width + 8.0f, badgeSize.width);
            
            if (CGRectContainsRect(rectClient, rectBadgeImage))
            {
                badgeView.hidden = NO;
                badgeLabel.hidden = NO;
                
                [badgeView setFrame:rectBadgeImage];
                [badgeLabel setFrame:CGRectInset(rectBadgeImage, 1.0f, 1.0f)];
                
                rectBadgeImage.origin.x += (rectBadgeImage.size.width + badgeMargin);
            }
            else
            {
                badgeView.hidden = YES;
                badgeLabel.hidden = YES;
            }
        }
    }
}

#pragma mark - Property

- (void)setBadgeType:(ProductBadgeType)badgeType
{
    _badgeType = badgeType;
}

- (void)setBadges:(NSArray *)badges
{
    if (_badges != badges)
    {
        _badges = badges;
        [self initSubviews];
    }
}

#pragma mark - Private Methods

//TODO: v3 모두 적용되면 v2 관련 코드 삭제 필요
- (UIImageView *)badgeImageViewAtName:(NSDictionary *)badgeInfo
{
//    UIImage *badgeImage = nil;
    
//    if (_badgeType == ProductBadgeTypeRound)
//    {
//        if ([badgeName isEqualToString:kBadgeTypeFreeDelivery])
//        {
//            badgeImage = [UIImage imageNamed:@"ic_free.png"];
//        }
//        else if ([badgeName isEqualToString:kBadgeTypeTMembership])
//        {
//            badgeImage = [UIImage imageNamed:@"ic_t.png"];
//        }
//        else if ([badgeName isEqualToString:kBadgeTypeMileage])
//        {
//            badgeImage = [UIImage imageNamed:@"ic_m.png"];
//        }
//        else if ([badgeName isEqualToString:kBadgeTypeMySelect])
//        {
//            badgeImage = [UIImage imageNamed:@"ic_me.png"];
//        }
//        else if ([badgeName isEqualToString:kBadgeTypeCardDiscount])
//        {
//            badgeImage = [UIImage imageNamed:@"ic_card.png"];
//        }
//        
//        return badgeImage ? [[UIImageView alloc] initWithImage:badgeImage] : nil;
//    }
    
    UIColor *layerColor = nil;
//    UIColor *backgroundColor = nil;
    
    if (badgeInfo[@"textColor"]) {
        layerColor = [UIColor colorWithHexString:badgeInfo[@"textColor"]];
    }
    
//    if (badgeInfo[@"bgColor"]) {
//        backgroundColor = [UIColor colorWithHexString:badgeInfo[@"bgColor"]];
//    }
    
//    if ([badgeName isEqualToString:kBadgeTypeFreeDelivery] ||
//        [badgeName isEqualToString:kBadgeTypeFreeDeliveryV2])
//    {
//        layerColor = [UIColor colorWithHexString:@"b6c6ff"];
//    }
//    else if ([badgeName isEqualToString:kBadgeTypeTMembership])
//    {
//        layerColor = [UIColor colorWithHexString:@"ffaa9e"];
//    }
//    else if ([badgeName isEqualToString:kBadgeTypeMileage] ||
//             [badgeName isEqualToString:kBadgeTypeCardDiscount])
//    {
//        layerColor = [UIColor colorWithHexString:@"ffb483"];
//    }
//    else if ([badgeName isEqualToString:kBadgeTypeMySelect])
//    {
//        layerColor = [UIColor colorWithHexString:@"ff3b0e"];
//        backgroundColor = [UIColor colorWithHexString:@"ff3b0e"];
//    }

    UIImageView *tempImage = [[UIImageView alloc] init];
//    UIImageView *tempImage = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:backgroundColor size:CGSizeMake(40.0f, 12.0f)]];
//    tempImage.layer.borderColor = layerColor.CGColor;
//    tempImage.layer.borderWidth = 1.0f;
    
    return layerColor ? tempImage : nil;
}

//TODO: v3 모두 적용되면 v2 관련 코드 삭제 필요
- (UILabel *)badgeLabelWithInfo:(NSDictionary *)badgeInfo
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    NSString *title = badgeInfo[@"label"];
    
    UIColor *titleColor = nil;
    UIColor *borderColor = nil;
    UIColor *backgroundColor = nil;
    
    if (badgeInfo[@"textColor"]) {
        titleColor = [UIColor colorWithHexString:badgeInfo[@"textColor"]];
    }
    
    if (badgeInfo[@"borderColor"]) {
        borderColor = [UIColor colorWithHexString:badgeInfo[@"borderColor"]];
    }
    
    if (badgeInfo[@"bgColor"]) {
        backgroundColor = [UIColor colorWithHexString:badgeInfo[@"bgColor"]];
    }
    
//    UIColor *titleColor = badgeInfo[@"textColor"];
    
//    if ([badgeName isEqualToString:kBadgeTypeFreeDelivery] ||
//        [badgeName isEqualToString:kBadgeTypeFreeDeliveryV2])
//    {
//        title = @"무료배송";
//        titleColor = [UIColor colorWithHexString:@"6989ff"];
//    }
//    else if ([badgeName isEqualToString:kBadgeTypeTMembership])
//    {
//        title = @"T멤버십";
//        titleColor = [UIColor colorWithHexString:@"ff411c"];
//    }
//    else if ([badgeName isEqualToString:kBadgeTypeMileage])
//    {
//        title = @"마일리지";
//        titleColor = [UIColor colorWithHexString:@"ff822f"];
//    }
//    else if ([badgeName isEqualToString:kBadgeTypeCardDiscount])
//    {
//        title = @"카드할인";
//        titleColor = [UIColor colorWithHexString:@"ff822f"];
//    }
//    else if ([badgeName isEqualToString:kBadgeTypeMySelect])
//    {
//        NSString *myDiscountRateString = [NSString stringWithFormat:@"%@", _myDiscountRate ? [NSString stringWithFormat:@" %@", _myDiscountRate] : @""];
//        
//        title = [NSString stringWithFormat:@"내맘대로%@", myDiscountRateString];
//        titleColor = [UIColor colorWithHexString:@"ffffff"];
//    }
    
    label.font = (self.isProductDetail ? BOLDFONTSIZE(11) : BOLDFONTSIZE(9));
    label.text = title;
    label.textColor = titleColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = backgroundColor;
    label.layer.borderColor = borderColor.CGColor;
    label.layer.borderWidth = 1.0f;
    
    return title ? label : nil;
}

@end
