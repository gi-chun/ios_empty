//
//  CPHotProductView.m
//  11st
//
//  Created by hjcho86 on 2015. 6. 19..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPHotProductView.h"
#import "CPThumbnailView.h"
#import "CPCommonInfo.h"
#import "UIImageView+WebCache.h"
#import "TTTAttributedLabel.h"
#import "CPString+Formatter.h"
#import "CPTouchActionView.h"
#import "AccessLog.h"

typedef NS_ENUM(NSUInteger, CPHotProductButtonType){
    CPHotProductButtonTypeFirst = 0,
    CPHotProductButtonTypeSecond,
    CPHotProductButtonTypeThird
};

@interface CPHotProductView()
{
    NSMutableDictionary* hotProductInfo;
    UIView *hotProductView;
}

@end

@implementation CPHotProductView

@synthesize width = _width;
@synthesize height = _height;

- (id)initWithFrame:(CGRect)frame hotProductInfo:(NSMutableDictionary *)aHotProductInfo listingType:(NSString *)listingType
{
    self = [super initWithFrame:frame];
    if (self) {
        
        hotProductInfo = aHotProductInfo;
        [self initLayout:listingType];
    }
    return self;
}

#pragma mark - Init

- (void)initLayout:(NSString *)listingType;
{
    NSString *wiseLogCode = @"";
    if ([listingType isEqualToString:@"search"]) {
        wiseLogCode = @"NASRPE19";
    }
    else if ([listingType isEqualToString:@"category"]) {
        wiseLogCode = @"NACLPE19";
    }
    
    hotProductView = [[UIView alloc] initWithFrame:CGRectZero];
    [hotProductView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview: hotProductView];
    
    CPThumbnailView *firstImageView = [[CPThumbnailView alloc] init];
    [hotProductView addSubview:firstImageView];
    
    NSString *imgUrl = hotProductInfo[@"items"][0][@"img1"];
    NSString *imgBase = [[CPCommonInfo sharedInfo] urlInfo][@"imgUrlPrefix"];
    
    if ([hotProductInfo[@"items"][0][@"adultProduct"] isEqualToString:@"Y"]) {
        [firstImageView setFrame:CGRectMake((kScreenBoundsWidth-20)/30, (kScreenBoundsWidth-20)/30, (kScreenBoundsWidth-20)/1.621, (kScreenBoundsWidth-20)/1.621)];
        [firstImageView.imageView setImage:[UIImage imageNamed:@"ic_li_adult_03.png"]];
    }
    else {
        if ([imgUrl length] > 0) {
            NSRange strRange = [imgUrl rangeOfString:@"http"];
            if (strRange.location == NSNotFound) {
                imgUrl = [imgBase stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:imgUrl];
            }
            strRange = [imgUrl rangeOfString:@"{{img_width}}"];
            if (strRange.location != NSNotFound) {
                imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%d", (int)(kScreenBoundsWidth-20)]];
            }
            strRange = [imgUrl rangeOfString:@"{{img_height}}"];
            if (strRange.location != NSNotFound) {
                imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%d", (int)(kScreenBoundsWidth-20)]];
            }
            
            [firstImageView setFrame:CGRectMake((kScreenBoundsWidth-20)/30, (kScreenBoundsWidth-20)/30, (kScreenBoundsWidth-20)/1.621, (kScreenBoundsWidth-20)/1.621)];
            [firstImageView.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
        }
        else {
            [firstImageView setFrame:CGRectMake((kScreenBoundsWidth-20)/30, (kScreenBoundsWidth-20)/30, (kScreenBoundsWidth-20)/1.621, (kScreenBoundsWidth-20)/1.621)];
            [firstImageView.imageView setImage:[UIImage imageNamed:@"thum_default.png"]];
        }
    }
    
    UIImageView *gradationFirstImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(firstImageView.frame), CGRectGetHeight(firstImageView.frame))];
    [gradationFirstImageView setImage:[UIImage imageNamed:@"bg_li_hot_b.png"]];
    [firstImageView addSubview:gradationFirstImageView];
    
    UIView *firstIconView = [[UIView alloc] init];
    [firstImageView addSubview:firstIconView];
    
    //iconView
    if ([hotProductInfo[@"items"][0][@"icons"] count] > 0) {
        
        NSArray *array = hotProductInfo[@"items"][0][@"icons"];
        CGFloat viewWidth = 0;
        
        for (NSDictionary *dic in array) {
            
            if ([[dic objectForKey:@"type"] isEqualToString:@"freedlv"]) {
                
                UILabel *iconLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                [iconLabel setFont:[UIFont boldSystemFontOfSize:12]];
                [iconLabel setBackgroundColor:[UIColor whiteColor]];
                [iconLabel setTextAlignment:NSTextAlignmentCenter];
                [iconLabel.layer setBorderWidth:1];
                [iconLabel setText:@"무료배송"];
                [iconLabel setTextColor:UIColorFromRGB(0x6989ff)];
                [iconLabel.layer setBorderColor:UIColorFromRGB(0xb6c6ff).CGColor];
                [iconLabel setFrame:CGRectMake(viewWidth, 0, 50, 19)];
                [firstIconView addSubview:iconLabel];
                
                viewWidth = 50;
                break;
            }
        }
        
        [firstIconView setFrame:CGRectMake(10, CGRectGetHeight(firstImageView.frame)-56, viewWidth, 19)];
    }
    
    NSString *firstText = [NSString stringWithFormat:@"%@원", [hotProductInfo[@"items"][0][@"finalPrc"] formatThousandComma]];
    CGSize firstTextSize = [firstText sizeWithFont:[UIFont boldSystemFontOfSize:18]];
    
    TTTAttributedLabel *firstPriceLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(firstImageView.frame)-32, firstTextSize.width, 20)];
    [firstPriceLabel setBackgroundColor:[UIColor clearColor]];
    [firstPriceLabel setTextColor:UIColorFromRGB(0xffffff)];
    [firstPriceLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [firstPriceLabel setText:firstText afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
        NSRange colorRange = [firstText rangeOfString:@"원"];
        if (colorRange.location != NSNotFound)
        {
            [mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont systemFontOfSize:13] range:colorRange];
        }
        return mutableAttributedString;
    }];
    [firstImageView addSubview:firstPriceLabel];
    
    CPTouchActionView *firstActionView = [[CPTouchActionView alloc] init];
    firstActionView.frame = CGRectMake(0, 0, CGRectGetWidth(firstImageView.frame), CGRectGetHeight(firstImageView.frame));
    firstActionView.actionType = CPButtonActionTypeOpenSubview;
    firstActionView.actionItem = hotProductInfo[@"items"][0][@"prdDtlUrl"];
    firstActionView.wiseLogCode = wiseLogCode;
    firstActionView.adClickItems = hotProductInfo[@"items"][0][@"adClickTrcUrl"];
    [firstActionView setAccessibilityLabel:[NSString stringWithFormat:@"상품명:%@ 할인가:%@원", hotProductInfo[@"items"][0][@"prdNm"], hotProductInfo[@"items"][0][@"finalPrc"]] Hint:@""];
    [firstImageView addSubview:firstActionView];
    
    CPThumbnailView *secondImageView = [[CPThumbnailView alloc] init];
    [hotProductView addSubview:secondImageView];
    
    imgUrl = hotProductInfo[@"items"][1][@"img1"];
    imgBase = [[CPCommonInfo sharedInfo] urlInfo][@"imgUrlPrefix"];
    
    if ([hotProductInfo[@"items"][1][@"adultProduct"] isEqualToString:@"Y"]) {
        [secondImageView setFrame:CGRectMake(CGRectGetMaxX(firstImageView.frame)+(kScreenBoundsWidth-20)/60, (kScreenBoundsWidth-20)/30, (kScreenBoundsWidth-20)/3.33, (kScreenBoundsWidth-20)/3.33)];
        [secondImageView.imageView setImage:[UIImage imageNamed:@"ic_li_adult_01.png"]];
    }
    else {
        if ([imgUrl length] > 0) {
            NSRange strRange = [imgUrl rangeOfString:@"http"];
            if (strRange.location == NSNotFound) {
                imgUrl = [imgBase stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:imgUrl];
            }
            strRange = [imgUrl rangeOfString:@"{{img_width}}"];
            if (strRange.location != NSNotFound) {
                imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%d", (int)(kScreenBoundsWidth-20)/2]];
            }
            strRange = [imgUrl rangeOfString:@"{{img_height}}"];
            if (strRange.location != NSNotFound) {
                imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%d", (int)(kScreenBoundsWidth-20)/2]];
            }
            
            [secondImageView setFrame:CGRectMake(CGRectGetMaxX(firstImageView.frame)+(kScreenBoundsWidth-20)/60, (kScreenBoundsWidth-20)/30, (kScreenBoundsWidth-20)/3.33, (kScreenBoundsWidth-20)/3.33)];
            [secondImageView.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
        }
        else {
            [secondImageView setFrame:CGRectMake(CGRectGetMaxX(firstImageView.frame)+(kScreenBoundsWidth-20)/60, (kScreenBoundsWidth-20)/30, (kScreenBoundsWidth-20)/3.33, (kScreenBoundsWidth-20)/3.33)];
            [secondImageView.imageView setImage:[UIImage imageNamed:@"thum_default.png"]];
        }
    }
    
    UIImageView *gradationSecondImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(secondImageView.frame), CGRectGetHeight(secondImageView.frame))];
    [gradationSecondImageView setImage:[UIImage imageNamed:@"bg_li_hot_s.png"]];
    [secondImageView addSubview:gradationSecondImageView];
    
    
    NSString *secondText = [NSString stringWithFormat:@"%@원", [hotProductInfo[@"items"][1][@"finalPrc"] formatThousandComma]];
    CGSize secondTextSize = [secondText sizeWithFont:[UIFont boldSystemFontOfSize:15]];
    
    TTTAttributedLabel *secondPriceLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(secondImageView.frame)-24, secondTextSize.width, 20)];
    [secondPriceLabel setBackgroundColor:[UIColor clearColor]];
    [secondPriceLabel setTextColor:UIColorFromRGB(0xffffff)];
    [secondPriceLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [secondPriceLabel setText:secondText afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
        NSRange colorRange = [secondText rangeOfString:@"원"];
        if (colorRange.location != NSNotFound)
        {
            [mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont systemFontOfSize:11] range:colorRange];
        }
        return mutableAttributedString;
    }];
    [secondImageView addSubview:secondPriceLabel];
    
    CPTouchActionView *secondActionView = [[CPTouchActionView alloc] init];
    secondActionView.frame = CGRectMake(0, 0, CGRectGetWidth(secondImageView.frame), CGRectGetHeight(secondImageView.frame));
    secondActionView.actionType = CPButtonActionTypeOpenSubview;
    secondActionView.actionItem = hotProductInfo[@"items"][1][@"prdDtlUrl"];
    secondActionView.wiseLogCode = wiseLogCode;
    secondActionView.adClickItems = hotProductInfo[@"items"][1][@"adClickTrcUrl"];
    [secondActionView setAccessibilityLabel:[NSString stringWithFormat:@"상품명:%@ 할인가:%@원", hotProductInfo[@"items"][1][@"prdNm"], hotProductInfo[@"items"][1][@"finalPrc"]] Hint:@""];
    [secondImageView addSubview:secondActionView];
    
    
    CPThumbnailView *thirdImageView = [[CPThumbnailView alloc] init];
    [hotProductView addSubview:thirdImageView];
    
    imgUrl = hotProductInfo[@"items"][2][@"img1"];
    imgBase = [[CPCommonInfo sharedInfo] urlInfo][@"imgUrlPrefix"];
    
    if ([hotProductInfo[@"items"][2][@"adultProduct"] isEqualToString:@"Y"]) {
        [thirdImageView setFrame:CGRectMake(CGRectGetMaxX(firstImageView.frame)+(kScreenBoundsWidth-20)/60, CGRectGetMaxY(secondImageView.frame)+(kScreenBoundsWidth-20)/60, (kScreenBoundsWidth-20)/3.33, (kScreenBoundsWidth-20)/3.33)];
        [thirdImageView.imageView setImage:[UIImage imageNamed:@"ic_li_adult_01.png"]];
    }
    else {
        if ([imgUrl length] > 0) {
            NSRange strRange = [imgUrl rangeOfString:@"http"];
            if (strRange.location == NSNotFound) {
                imgUrl = [imgBase stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:imgUrl];
            }
            strRange = [imgUrl rangeOfString:@"{{img_width}}"];
            if (strRange.location != NSNotFound) {
                imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%d", (int)(kScreenBoundsWidth-20)/2]];
            }
            strRange = [imgUrl rangeOfString:@"{{img_height}}"];
            if (strRange.location != NSNotFound) {
                imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%d", (int)(kScreenBoundsWidth-20)/2]];
            }
            
            [thirdImageView setFrame:CGRectMake(CGRectGetMaxX(firstImageView.frame)+(kScreenBoundsWidth-20)/60, CGRectGetMaxY(secondImageView.frame)+(kScreenBoundsWidth-20)/60, (kScreenBoundsWidth-20)/3.33, (kScreenBoundsWidth-20)/3.33)];
            [thirdImageView.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
        }
        else {
            [thirdImageView setFrame:CGRectMake(CGRectGetMaxX(firstImageView.frame)+(kScreenBoundsWidth-20)/60, CGRectGetMaxY(secondImageView.frame)+(kScreenBoundsWidth-20)/60, (kScreenBoundsWidth-20)/3.33, (kScreenBoundsWidth-20)/3.33)];
            [thirdImageView.imageView setImage:[UIImage imageNamed:@"thum_default.png"]];
        }
    }
    
    UIImageView *gradationThirdImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(thirdImageView.frame), CGRectGetHeight(thirdImageView.frame))];
    [gradationThirdImageView setImage:[UIImage imageNamed:@"bg_li_hot_s.png"]];
    [thirdImageView addSubview:gradationThirdImageView];
    
    CPTouchActionView *thirdActionView = [[CPTouchActionView alloc] init];
    thirdActionView.frame = CGRectMake(0, 0, CGRectGetWidth(thirdImageView.frame), CGRectGetHeight(thirdImageView.frame));
    thirdActionView.actionType = CPButtonActionTypeOpenSubview;
    thirdActionView.actionItem = hotProductInfo[@"items"][2][@"prdDtlUrl"];
    thirdActionView.wiseLogCode = wiseLogCode;
    thirdActionView.adClickItems = hotProductInfo[@"items"][2][@"adClickTrcUrl"];
    [thirdActionView setAccessibilityLabel:[NSString stringWithFormat:@"상품명:%@ 할인가:%@원", hotProductInfo[@"items"][2][@"prdNm"], hotProductInfo[@"items"][2][@"finalPrc"]] Hint:@""];
    [thirdImageView addSubview:thirdActionView];

    
    
    NSString *thirdText = [NSString stringWithFormat:@"%@원", [hotProductInfo[@"items"][2][@"finalPrc"] formatThousandComma]];
    CGSize thirdTextSize = [thirdText sizeWithFont:[UIFont boldSystemFontOfSize:15]];
    
    TTTAttributedLabel *thirdPriceLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(thirdImageView.frame)-24, thirdTextSize.width, 20)];
    [thirdPriceLabel setBackgroundColor:[UIColor clearColor]];
    [thirdPriceLabel setTextColor:UIColorFromRGB(0xffffff)];
    [thirdPriceLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [thirdPriceLabel setText:thirdText afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
        NSRange colorRange = [thirdText rangeOfString:@"원"];
        if (colorRange.location != NSNotFound)
        {
            [mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont systemFontOfSize:11] range:colorRange];
        }
        return mutableAttributedString;
    }];
    [thirdImageView addSubview:thirdPriceLabel];
    
    self.width = kScreenBoundsWidth-20;
    self.height = CGRectGetMaxY(firstImageView.frame)+(kScreenBoundsWidth-20)/30;
    [hotProductView setFrame:CGRectMake(0, 0, self.width, self.height)];
}

@end
