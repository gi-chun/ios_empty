//
//  CPPriceDetailReviewItemCell.m
//  11st
//
//  Created by 김응학 on 2015. 7. 9..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPPriceDetailReviewItemCell.h"
#import "UIImageView+WebCache.h"
#import "CPSchemeManager.h"
#import "AccessLog.h"

@interface CPPriceDetailReviewItemCell ()
{
    UIView *_contentView;
    UIView *_lineView;
    UIView *_touchView;
}

@end

@implementation CPPriceDetailReviewItemCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    self.backgroundColor = [UIColor clearColor];
    
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_contentView];
    
    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = UIColorFromRGB(0xededed);
    [self.contentView addSubview:_lineView];
    
    _touchView = [[UIView alloc] initWithFrame:CGRectZero];
    _touchView.backgroundColor = UIColorFromRGBA(0xe5e5e5, 0.3);
    [self.contentView addSubview:_touchView];
    
    [self setIsTouchView:NO];
}

- (void)layoutSubviews
{
    self.backgroundColor = [UIColor clearColor];
    self.contentView.frame = self.bounds;
    
    _contentView.frame = CGRectMake(10, 0, self.contentView.frame.size.width-20.f, self.contentView.frame.size.height-1);
    _touchView.frame = _contentView.frame;
    
    for (UIView *subview in _contentView.subviews) {
        [subview removeFromSuperview];
    }

    if (_isNoItem) {
        UIImage *noItemImg = [UIImage imageNamed:@"ic_pd_review.png"];
        
        UIImageView *noItemView = [[UIImageView alloc] initWithFrame:CGRectMake((_contentView.frame.size.width/2)-(noItemImg.size.width/2), 46,
                                                                                noItemImg.size.width, noItemImg.size.height)];
        noItemView.image = noItemImg;
        [_contentView addSubview:noItemView];
        
        NSString *noText = (_tabIdx == 0 ? @"작성된 포토리뷰가 없습니다." : @"작성된 일반리뷰가 없습니다.");
        UILabel *noTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        noTextLabel.backgroundColor = [UIColor clearColor];
        noTextLabel.font = [UIFont systemFontOfSize:14];
        noTextLabel.textColor = UIColorFromRGB(0xb8b8b8);
        noTextLabel.numberOfLines = 1;
        noTextLabel.textAlignment = NSTextAlignmentLeft;
        noTextLabel.text = noText;
        [noTextLabel sizeToFitWithVersion];
        [_contentView addSubview:noTextLabel];
        
        noTextLabel.frame = CGRectMake((_contentView.frame.size.width/2)-(noTextLabel.frame.size.width/2),
                                       CGRectGetMaxY(noItemView.frame)+12,
                                       noTextLabel.frame.size.width, noTextLabel.frame.size.height);

        _lineView.backgroundColor = UIColorFromRGB(0xd7d7d7);
    }
    else
    {
        if (_isMore) {
            UIImage *arrowImg = [UIImage imageNamed:@"ic_price_arrow_right.png"];
            
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            textLabel.backgroundColor = [UIColor clearColor];
            textLabel.textColor = UIColorFromRGB(0x283593);
            textLabel.font = [UIFont systemFontOfSize:14];
            textLabel.numberOfLines = 1;
            textLabel.textAlignment = NSTextAlignmentLeft;
            textLabel.text = @"더보기";
            [textLabel sizeToFitWithVersion];
            [_contentView addSubview:textLabel];
            
            textLabel.frame = CGRectMake((_contentView.frame.size.width/2)-((textLabel.frame.size.width+7+arrowImg.size.width)/2),
                                         (_contentView.frame.size.height/2)-(textLabel.frame.size.height/2),
                                         textLabel.frame.size.width, textLabel.frame.size.height);
            
            UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textLabel.frame)+7,
                                                                                   (_contentView.frame.size.height/2)-(arrowImg.size.height/2),
                                                                                   arrowImg.size.width, arrowImg.size.height)];
            arrowView.image = arrowImg;
            [_contentView addSubview:arrowView];
            
            _lineView.backgroundColor = UIColorFromRGB(0xd7d7d7);
        }
        else {
            CGFloat offsetX = 10;
            CGFloat maxWidth = _contentView.frame.size.width;
            
            //썸네일
            NSString *imageUrl = _item[@"imgUrl"];
            if (!nilCheck(imageUrl)) {
                UIImageView *reviewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_contentView.frame.size.width-10-84, 10, 84, 84)];
                [reviewImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
                [_contentView addSubview:reviewImageView];
                
                maxWidth = reviewImageView.frame.origin.x;
            }
            
            //추천여부
            NSString *recommendStr = [_item[@"prdEvlPnt"] trim];
            
            UIView *recommendStateView = [[UIView alloc] initWithFrame:CGRectZero];
            recommendStateView.backgroundColor = [UIColor whiteColor];
            recommendStateView.layer.borderWidth = 1;
            [_contentView addSubview:recommendStateView];
            
            UILabel *recommendLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            recommendLabel.backgroundColor = [UIColor clearColor];
            recommendLabel.font = [UIFont systemFontOfSize:12];
            recommendLabel.numberOfLines = 1;
            recommendLabel.textAlignment = NSTextAlignmentLeft;
            recommendLabel.text = recommendStr;
            [recommendLabel sizeToFitWithVersion];
            [recommendStateView addSubview:recommendLabel];
            
            recommendStateView.frame = CGRectMake(offsetX, 16, recommendLabel.frame.size.width+6, recommendLabel.frame.size.height+4);
            recommendLabel.frame = CGRectMake((recommendStateView.frame.size.width/2)-(recommendLabel.frame.size.width/2),
                                              (recommendStateView.frame.size.height/2)-(recommendLabel.frame.size.height/2),
                                              recommendLabel.frame.size.width, recommendLabel.frame.size.height);
            
            //컬러조정
            if ([recommendStr isEqualToString:@"적극추천"]) {
                recommendStateView.layer.borderColor = UIColorFromRGB(0xff2128).CGColor;
                recommendLabel.textColor = UIColorFromRGB(0xff2128);
            }
            else if ([recommendStr isEqualToString:@"추천"]) {
                recommendStateView.layer.borderColor = UIColorFromRGB(0xff5a00).CGColor;
                recommendLabel.textColor = UIColorFromRGB(0xff5a00);
            }
            else if ([recommendStr isEqualToString:@"보통"]) {
                recommendStateView.layer.borderColor = UIColorFromRGB(0x4c6ce2).CGColor;
                recommendLabel.textColor = UIColorFromRGB(0x4c6ce2);
            }
            else if ([recommendStr isEqualToString:@"추천안함"]) {
                recommendStateView.layer.borderColor = UIColorFromRGB(0x666666).CGColor;
                recommendLabel.textColor = UIColorFromRGB(0x666666);
            }
            
            //타이틀
            NSString *titleStr = [_item[@"title"] trim];
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(recommendStateView.frame)+6,
                                                                            recommendStateView.frame.origin.y,
                                                                            maxWidth-10-(CGRectGetMaxX(recommendStateView.frame)+6),
                                                                            recommendStateView.frame.size.height)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = [UIFont boldSystemFontOfSize:15];
            titleLabel.textColor = UIColorFromRGB(0x333333);
            titleLabel.numberOfLines = 1;
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.text = titleStr;
            [_contentView addSubview:titleLabel];
            
            //옵션
            NSString *optionStr = [_item[@"prdOptNm"] trim];
            UILabel *optionLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX,
                                                                             CGRectGetMaxY(recommendStateView.frame)+3,
                                                                             maxWidth-10-(offsetX),
                                                                             recommendStateView.frame.size.height)];
            optionLabel.backgroundColor = [UIColor clearColor];
            optionLabel.font = [UIFont systemFontOfSize:13];
            optionLabel.textColor = UIColorFromRGB(0x788392);
            optionLabel.numberOfLines = 1;
            optionLabel.textAlignment = NSTextAlignmentLeft;
            optionLabel.text = optionStr;
            [_contentView addSubview:optionLabel];
            
            //customerClass
            NSString *customerClassStr = [_item[@"customerClass"] trim];
            UILabel *customerClassLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX,
                                                                                    CGRectGetMaxY(optionLabel.frame)+1,
                                                                                    0,
                                                                                    recommendStateView.frame.size.height)];
            customerClassLabel.backgroundColor = [UIColor clearColor];
            customerClassLabel.font = [UIFont boldSystemFontOfSize:12];
            customerClassLabel.numberOfLines = 1;
            customerClassLabel.textAlignment = NSTextAlignmentLeft;
            customerClassLabel.text = customerClassStr;
            [customerClassLabel sizeToFitWithVersionHoldHeight];
            [_contentView addSubview:customerClassLabel];
            
            if ([customerClassStr isEqualToString:@"BEST"])         customerClassLabel.textColor = UIColorFromRGB(0x2b60c9);
            else if ([customerClassStr isEqualToString:@"VVIP"])    customerClassLabel.textColor = UIColorFromRGB(0xee0000);
            else if ([customerClassStr isEqualToString:@"VIP"])     customerClassLabel.textColor = UIColorFromRGB(0xf64a00);
            else if ([customerClassStr isEqualToString:@"TOP"])     customerClassLabel.textColor = UIColorFromRGB(0x17A511);
            else if ([customerClassStr isEqualToString:@"NEW"])     customerClassLabel.textColor = UIColorFromRGB(0x545655);
            
            
            //ETC
            NSString *etcStr = [NSString stringWithFormat:@"%@ / 조회 %@ / %@", [_item[@"writerId"] trim], [_item[@"hits"] trim], [_item[@"writtenDate"] trim]];
            UILabel *etcLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(customerClassLabel.frame)+4,
                                                                          customerClassLabel.frame.origin.y,
                                                                          maxWidth-10-(CGRectGetMaxX(customerClassLabel.frame)+4),
                                                                          recommendStateView.frame.size.height)];
            etcLabel.backgroundColor = [UIColor clearColor];
            etcLabel.textColor = UIColorFromRGB(0x999999);
            etcLabel.font = [UIFont systemFontOfSize:13];
            etcLabel.numberOfLines = 1;
            etcLabel.textAlignment = NSTextAlignmentLeft;
            etcLabel.text = etcStr;
            [_contentView addSubview:etcLabel];
            
            //셀러
            NSString *sellerStr = [_item[@"sellerNckNm"] trim];
            UILabel *sellerLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX,
                                                                             CGRectGetMaxY(etcLabel.frame),
                                                                             maxWidth-10-(offsetX),
                                                                             recommendStateView.frame.size.height)];
            sellerLabel.backgroundColor = [UIColor clearColor];
            sellerLabel.font = [UIFont systemFontOfSize:13];
            sellerLabel.textColor = UIColorFromRGB(0x999999);
            sellerLabel.numberOfLines = 1;
            sellerLabel.textAlignment = NSTextAlignmentLeft;
            sellerLabel.text = [NSString stringWithFormat:@"판매자 : %@", sellerStr];
            [_contentView addSubview:sellerLabel];
            
            if (self.isLastCell)    _lineView.backgroundColor = UIColorFromRGB(0xd7d7d7);
            else                    _lineView.backgroundColor = UIColorFromRGB(0xe5e5e5);
        }
    }
    
    _lineView.frame = CGRectMake(_contentView.frame.origin.x, self.frame.size.height-1, _contentView.frame.size.width, 1);
}


- (void)setIsTouchView:(BOOL)isTouch
{
    BOOL touchYn = !isTouch;
    
    _touchView.hidden = touchYn;
//    _contentView.backgroundColor = (!touchYn ? UIColorFromRGB(0xf0f1fb) : UIColorFromRGB(0xffffff));
}

- (void)onTouchView
{
    if (_isNoItem) return;

    if (_isMore) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(reviewItemCellShowMoreItem:)]) {
            [self.delegate reviewItemCellShowMoreItem:_tabIdx];
        }
    }
    else {
        NSString *url = [_item[@"linkUrl"] trim];
        
        if (url && [url length] > 0) {
            [[CPSchemeManager sharedManager] openUrlScheme:url sender:nil changeAnimated:NO];
        }
        
        NSString *imgUrl = [_item[@"imgUrl"] trim];
        if (!nilCheck(imgUrl))  [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDJ05"];
        else                    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDK05"];
    }
}

#pragma touch event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_isNoItem) {
        [self setIsTouchView:YES];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_isNoItem) {
        [self setIsTouchView:NO];
        [self onTouchView];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_isNoItem) {
        [self setIsTouchView:NO];
    }
}

@end
