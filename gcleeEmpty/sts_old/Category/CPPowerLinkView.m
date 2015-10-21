//
//  CPPowerLinkView.m
//  11st
//
//  Created by hjcho86 on 2015. 6. 16..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPPowerLinkView.h"
#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"
#import "TTTAttributedLabel.h"
#import "CPTouchActionView.h"
#import "CPRESTClient.h"

@interface CPPowerLinkView() <TTTAttributedLabelDelegate>
{
    NSMutableDictionary* powerLinkInfo;
    UIView *powerLinkView;
    NSString *currentUrl;
    NSString *referrer;
}

@end

@implementation CPPowerLinkView

@synthesize width = _width;
@synthesize height = _height;

- (id)initWithFrame:(CGRect)frame powerLinkInfo:(NSDictionary *)powerLinkData listingType:(NSString *)listingType
{
    self = [super initWithFrame:frame];
    if (self) {
        
        powerLinkInfo = [powerLinkData mutableCopy];
        [self initLayout:powerLinkData listingType:listingType];
    }
    return self;
}

#pragma mark - Init

- (void)initLayout:(NSDictionary *)responseDic listingType:(NSString *)listingType
{
    NSArray *powerLinkArray = responseDic[@"CONTENTS"][@"ads"];
    
    if ([powerLinkArray count] == 0) {
        self.width = 0;
        self.height = 0;
        [powerLinkView setFrame:CGRectMake(0, 0, self.width, self.height)];
        
        return;
    }
    
    powerLinkView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview: powerLinkView];
    
    //title
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 34)];
    [titleView setBackgroundColor:[UIColor whiteColor]];
    [powerLinkView addSubview:titleView];
    
    UILabel *powerLinkTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 34)];
    [powerLinkTitleLabel setBackgroundColor:[UIColor clearColor]];
    [powerLinkTitleLabel setText:@"파워링크"];
    [powerLinkTitleLabel setTextColor:UIColorFromRGB(0x333333)];
    [powerLinkTitleLabel setFont:[UIFont systemFontOfSize:15]];
    [powerLinkView addSubview:powerLinkTitleLabel];
    
    NSString *adStr = @"AD";
    CGSize adStrSize = [adStr sizeWithFont:[UIFont systemFontOfSize:11]];
    
    UILabel *adLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleView.frame)-25, 0, adStrSize.width, 34)];
    [adLabel setBackgroundColor:[UIColor clearColor]];
    [adLabel setText:adStr];
    [adLabel setTextColor:UIColorFromRGB(0x757b9c)];
    [adLabel setFont:[UIFont systemFontOfSize:11]];
    [powerLinkView addSubview:adLabel];
    
    UIView *titleUnderLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 33, kScreenBoundsWidth-20, 1)];
    [titleUnderLineView setBackgroundColor:UIColorFromRGB(0xf0f0f3)];
    [powerLinkView addSubview:titleUnderLineView];
    
    
    NSArray *urlArray = [powerLinkInfo[@"url"] componentsSeparatedByString:@"?"];
    NSArray *queryStrings = [urlArray.lastObject componentsSeparatedByString:@"&"];
    
    NSString *key = @"";
    for (NSString *keyValue in queryStrings) {
        NSArray *keyValueArray = [keyValue componentsSeparatedByString:@"="];
        
        if ([keyValueArray.firstObject isEqualToString:@"searchKeyword"]) {
            key = [[keyValueArray lastObject] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            key = [key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            break;
        }
    }
    CGFloat viewHeight = CGRectGetMaxY(titleView.frame);
    
    //powerLink
    for (NSDictionary *dic in powerLinkArray) {
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight, kScreenBoundsWidth-20, 91)];
        [contentView setBackgroundColor:[UIColor whiteColor]];
        [powerLinkView addSubview:contentView];
        
        UIImageView *rankImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 20, 20)];
        [rankImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ic_s_rank_0%lu.png", (unsigned long)[powerLinkArray indexOfObject:dic]+1]]];
        [contentView addSubview:rankImageView];
        
        
        NSString *titleStr = [dic objectForKey:@"title"];
        CGSize titleSize = [titleStr sizeWithFont:[UIFont systemFontOfSize:15]];
        
        TTTAttributedLabel *titleLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        [titleLabel setDelegate:self];
        [titleLabel setFrame:CGRectMake(CGRectGetMaxX(rankImageView.frame)+10, 16, titleSize.width, titleSize.height)];
        [titleLabel setFont:[UIFont systemFontOfSize:15]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTextColor:UIColorFromRGB(0x1122cc)];
        [titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [titleLabel setText:titleStr afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
            NSRange colorRange = [titleStr rangeOfString:key options: NSCaseInsensitiveSearch];
            if (colorRange.location != NSNotFound)
            {
                [mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont boldSystemFontOfSize:15] range:colorRange];
            }
            return mutableAttributedString;
        }];
        
        [titleLabel addLinkToURL:[NSURL URLWithString:titleStr] withRange:[titleLabel.text rangeOfString:titleStr]];
        [titleLabel sizeToFit];
        [contentView addSubview:titleLabel];
        
//        if ([[dic objectForKey:@"isMobile"] isEqualToString:@"true"]) {
            //폰 이미지
            UIImageView *phoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_s_phone.png"]];
            [phoneImageView setFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame)+3, CGRectGetMinY(titleLabel.frame), 11, 16)];
            [contentView addSubview:phoneImageView];
//        }
        
        NSString *descStr = [dic objectForKey:@"desc"];
        NSInteger index = 0;
        
        for (int i = 0; i < [descStr length]; i++) {
            CGSize size = [[descStr substringWithRange:NSMakeRange(0, i)] sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(10000, kScreenBoundsWidth-50) lineBreakMode:NSLineBreakByWordWrapping];
            
            if (size.width > kScreenBoundsWidth-50) {
                break;
            }
            index = i;
        }
        
        TTTAttributedLabel *descLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        [descLabel setDelegate:self];
        [descLabel setFrame:CGRectMake(15, CGRectGetMaxY(rankImageView.frame)+10, kScreenBoundsWidth-50, 14)];
        [descLabel setFont:[UIFont systemFontOfSize:13]];
        [descLabel setBackgroundColor:[UIColor clearColor]];
        [descLabel setTextColor:UIColorFromRGB(0x333333)];
        [descLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [descLabel setText:[descStr substringWithRange:NSMakeRange(0, index)] afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
            NSRange colorRange = [[descStr substringWithRange:NSMakeRange(0, index)] rangeOfString:key options: NSCaseInsensitiveSearch];
            if (colorRange.location != NSNotFound)
            {
                [mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont boldSystemFontOfSize:13] range:colorRange];
            }
            return mutableAttributedString;
        }];
        [descLabel sizeToFit];
        [contentView addSubview:descLabel];
        
        
        
        UILabel *vUrlLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(descLabel.frame)+7, kScreenBoundsWidth-50, 14)];
        [vUrlLabel setBackgroundColor:[UIColor clearColor]];
        [vUrlLabel setFont:[UIFont boldSystemFontOfSize:13]];
        [vUrlLabel setText:[dic objectForKey:@"vUrl"]];
        [vUrlLabel setTextColor:UIColorFromRGB(0x6c4d29)];
        [contentView addSubview:vUrlLabel];
        
        UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 90, kScreenBoundsWidth-20, 1)];
        [underLineView setBackgroundColor:UIColorFromRGB(0xeaeaea)];
        [contentView addSubview:underLineView];
        
        
        NSString *wiseLogCode = @"";
        if ([listingType isEqualToString:@"search"]) {
            wiseLogCode = @"NASRPG02";
        }
        else if ([listingType isEqualToString:@"category"]) {
            wiseLogCode = @"NACLPG02";
        }
      
        CPTouchActionView *actionView = [[CPTouchActionView alloc] init];
        actionView.frame = CGRectMake(0, 0, CGRectGetWidth(contentView.frame), CGRectGetHeight(contentView.frame));
        actionView.actionType = CPButtonActionTypeOpenSubview;
        actionView.actionItem = [dic objectForKey:@"cUrl"];
        actionView.wiseLogCode = wiseLogCode;
        [actionView setAccessibilityLabel:titleStr Hint:@""];
        [contentView addSubview:actionView];
        
        viewHeight += contentView.frame.size.height;
    }
    
    self.width = CGRectGetWidth(titleView.frame);
    self.height = viewHeight;
    [powerLinkView setFrame:CGRectMake(0, 0, self.width, self.height)];
}

@end
