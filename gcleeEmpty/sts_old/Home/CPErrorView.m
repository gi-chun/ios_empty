//
//  CPErrorView.m
//  11st
//
//  Created by spearhead on 2014. 10. 29..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPErrorView.h"

@implementation CPErrorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        UIImageView *nodataImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)/2-30, CGRectGetHeight(frame)/2-95, 60, 60)];
        [nodataImageView setImage:[UIImage imageNamed:@"ic_nodata.png"]];
        [self addSubview:nodataImageView];
        
        UILabel *nodataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(nodataImageView.frame)+10, CGRectGetWidth(frame), 60)];
        [nodataLabel setText:@"일시적인 오류로 인해\n서비스 연결이 되지 않습니다.\n다시 한번 시도해 주세요."];
        [nodataLabel setFont:[UIFont systemFontOfSize:14]];
        [nodataLabel setTextColor:UIColorFromRGB(0x666666)];
        [nodataLabel setTextAlignment:NSTextAlignmentCenter];
        [nodataLabel setBackgroundColor:[UIColor clearColor]];
        [nodataLabel setNumberOfLines:0];
        [self addSubview:nodataLabel];
        
        UIButton *retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [retryButton setFrame:CGRectMake(CGRectGetWidth(frame)/2-50, CGRectGetMaxY(nodataLabel.frame)+20, 100, 40)];
        [retryButton setBackgroundImage:[UIImage imageNamed:@"btn_gray_nor.png"] forState:UIControlStateNormal];
        [retryButton setBackgroundImage:[UIImage imageNamed:@"btn_gray_press.png"] forState:UIControlStateHighlighted];
        [retryButton setTitle:@"다시 시도" forState:UIControlStateNormal];
        [retryButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [retryButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [retryButton addTarget:self action:@selector(touchRetryButton) forControlEvents:UIControlEventTouchUpInside];
        [retryButton setAccessibilityLabel:@"다시시도" Hint:@"서비스 연결을 다시 시도합니다"];
        [self addSubview:retryButton];
    }
    return self;
}

#pragma mark - Selectors

- (void)touchRetryButton
{
    if ([self.delegate respondsToSelector:@selector(didTouchRetryButton)]) {
        [self.delegate didTouchRetryButton];
    }
}

@end
