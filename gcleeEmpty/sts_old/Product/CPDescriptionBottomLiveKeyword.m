#import "CPDescriptionBottomLiveKeyword.h"
#import "UIImageView+WebCache.h"
#import "AccessLog.h"

@interface CPDescriptionBottomLiveKeyword ()
{
	NSArray *_item;
    NSString *_updateTime;
    
    UIView *headerView;
    
    UILabel *headerRankCountLabel;
    UIView *headerRankStateView;
    UILabel *headerRankTitle;
    UIImageView *headerIconView;
    UILabel *headerCountLabel;
    
    
    UIView *expandView;
    UIButton *linkButton;
    UIButton *expandButton;
    
    CGFloat viewHeight;
    BOOL isExpand;
    
    NSInteger rankCount;
}

@end

@implementation CPDescriptionBottomLiveKeyword

- (id)initWithFrame:(CGRect)frame item:(NSArray *)item updateTime:(NSString *)aUpdateTime
{
	if (self = [super initWithFrame:frame])
	{
        if (item) {
            _item = item;
        }
        
        if (item) {
            _updateTime = aUpdateTime;
        }
		
        isExpand = NO;
        rankCount = 0;
        [self initLayout];
        [self startAutoScroll];
	}
	return self;
}

- (void)initLayout
{
	self.backgroundColor = [UIColor whiteColor];
    
    headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:headerView];
    
    expandView = [[UIView alloc] init];
    [expandView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:expandView];
    
    linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [linkButton setBackgroundImage:[UIImage imageNamed:@"bg_000000.png"] forState:UIControlStateHighlighted];
    [linkButton setAlpha:0.3];
    [linkButton addTarget:self action:@selector(touchLinkButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:linkButton];
    
    expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [expandButton setBackgroundImage:[UIImage imageNamed:@"bg_000000.png"] forState:UIControlStateHighlighted];
    [expandButton setAlpha:0.3];
    [expandButton addTarget:self action:@selector(touchExpandButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:expandButton];
}

- (void)layoutSubviews
{
    for (UIView *subView in [headerView subviews]) {
        [subView removeFromSuperview];
    }
    
    for (UIView *subView in [expandView subviews]) {
        [subView removeFromSuperview];
    }
    
    viewHeight = 0;
    
    if (isExpand) {
        [headerView setFrame:CGRectMake(0, 0, kScreenBoundsWidth, 44)];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenBoundsWidth-20, 44)];
        [titleLabel setBackgroundColor:[UIColor whiteColor]];
        [titleLabel setText:@"실시간 급상승 쇼핑키워드"];
        [titleLabel setTextColor:UIColorFromRGB(0x52bbff)];
        [titleLabel setTextAlignment:NSTextAlignmentLeft];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [headerView addSubview:titleLabel];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenBoundsWidth-28, 18, 15, 8)];
        [arrowImageView setImage:[UIImage imageNamed:@"ic_pd_arrow_up_01.png"]];
        [headerView addSubview:arrowImageView];
        
        UIView *headerUnderLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame)-1, kScreenBoundsWidth, 1)];
        [headerUnderLineView setBackgroundColor:UIColorFromRGB(0xebebeb)];
        [headerView addSubview:headerUnderLineView];
        
        CGFloat height = 0;
        
        for (NSDictionary *dic in _item) {
            
            UIView *rankView = [[UIView alloc] initWithFrame:CGRectMake(0, height, kScreenBoundsWidth, 44)];
            [expandView addSubview:rankView];
            
            UILabel *rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 20, 44)];
            [rankLabel setBackgroundColor:[UIColor clearColor]];
            [rankLabel setText:[NSString stringWithFormat:@"%ld", (long)[dic[@"rank"] integerValue]]];
            [rankLabel setTextAlignment:NSTextAlignmentCenter];
            [rankLabel setTextColor:[_item indexOfObject:dic] < 3?UIColorFromRGB(0xf62e3d):UIColorFromRGB(0x999999)];
            [rankLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [rankView addSubview:rankLabel];
            
            UIView *rankStateView = [self drawRankStateView:[_item indexOfObject:dic]];
            [rankStateView setFrame:CGRectMake(kScreenBoundsWidth-10-CGRectGetWidth(rankStateView.frame), 0, CGRectGetWidth(rankStateView.frame), 44)];
            [rankView addSubview:rankStateView];
            
            UILabel *keywordLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 0, rankStateView.frame.origin.x-44, 44)];
            [keywordLabel setBackgroundColor:[UIColor clearColor]];
            [keywordLabel setText:dic[@"keyword"]];
            [keywordLabel setTextColor:UIColorFromRGB(0x333333)];
            [keywordLabel setTextAlignment:NSTextAlignmentLeft];
            [keywordLabel setFont:[UIFont systemFontOfSize:14]];
            [rankView addSubview:keywordLabel];
            
            UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, kScreenBoundsWidth, 1)];
            [underLineView setBackgroundColor:UIColorFromRGB(0xebebeb)];
            [rankView addSubview:underLineView];
            
            UIButton *blankButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [blankButton setFrame:CGRectMake(0, 0, kScreenBoundsWidth, 44)];
            [blankButton setTag:[_item indexOfObject:dic]];
            [blankButton setBackgroundImage:[UIImage imageNamed:@"bg_000000.png"] forState:UIControlStateHighlighted];
            [blankButton setAlpha:0.3];
            [blankButton addTarget:self action:@selector(touchSearchKeyword:) forControlEvents:UIControlEventTouchUpInside];
            [rankView addSubview:blankButton];
            
            height += 44;
        }
        
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, height+CGRectGetMaxY(headerView.frame), kScreenBoundsWidth, 44)];
        [bottomView setBackgroundColor:UIColorFromRGB(0xf9f9f9)];
        [self addSubview:bottomView];
        
        NSString *bottomStr = _updateTime;
        CGSize bottomStrSize = [bottomStr sizeWithFont:[UIFont systemFontOfSize:14]];
        
        UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenBoundsWidth-10-bottomStrSize.width, 0, bottomStrSize.width, 44)];
        [bottomLabel setBackgroundColor:[UIColor clearColor]];
        [bottomLabel setText:bottomStr];
        [bottomLabel setTextColor:UIColorFromRGB(0xaf8459)];
        [bottomLabel setTextAlignment:NSTextAlignmentLeft];
        [bottomLabel setFont:[UIFont systemFontOfSize:14]];
        [bottomView addSubview:bottomLabel];
        
        UIView *bottomUnderLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bottomView.frame)-1, kScreenBoundsWidth, 1)];
        [bottomUnderLineView setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
        [bottomView addSubview:bottomUnderLineView];
        
        [linkButton setHidden:YES];
        [expandButton setFrame:CGRectMake(0, 0, CGRectGetWidth(headerView.frame), CGRectGetHeight(headerView.frame))];
        [expandView setFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), kScreenBoundsWidth, height)];
        viewHeight = CGRectGetMaxY(bottomView.frame);
    }
    else {
        
        [headerView setFrame:CGRectMake(0, 0, kScreenBoundsWidth, 44)];
        
        UIImageView *rankImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 56, 24)];
        [rankImageView setImage:[UIImage imageNamed:@"ic_pd_rank_bg.png"]];
        [headerView addSubview:rankImageView];
        
        UILabel *rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(rankImageView.frame), CGRectGetHeight(rankImageView.frame))];
        [rankLabel setBackgroundColor:[UIColor clearColor]];
        [rankLabel setText:@"실시간"];
        [rankLabel setTextColor:UIColorFromRGB(0xffffff)];
        [rankLabel setTextAlignment:NSTextAlignmentCenter];
        [rankLabel setFont:[UIFont systemFontOfSize:13]];
        [rankImageView addSubview:rankLabel];
        
        headerRankCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(rankImageView.frame)+14, 0, 20, 44)];
        [headerRankCountLabel setBackgroundColor:[UIColor clearColor]];
        [headerRankCountLabel setText:[NSString stringWithFormat:@"%d", (int)(rankCount+1)]];
        [headerRankCountLabel setTextColor:rankCount < 3?UIColorFromRGB(0xf62e3d):UIColorFromRGB(0x999999)];
        [headerRankCountLabel setTextColor:UIColorFromRGB(0xf62e3d)];
        [headerRankCountLabel setTextAlignment:NSTextAlignmentCenter];
        [headerRankCountLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:16]];
        [headerView addSubview:headerRankCountLabel];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenBoundsWidth-28, 18, 15, 8)];
        [arrowImageView setImage:[UIImage imageNamed:@"ic_pd_arrow_down.png"]];
        [headerView addSubview:arrowImageView];
        
        
        
        NSDictionary *dict = _item[rankCount];
        
        headerRankStateView = [[UIView alloc] init];
        headerIconView = [[UIImageView alloc] init];
        [headerRankStateView addSubview:headerIconView];
        
        if ([dict[@"rankState"] isEqualToString:@"up"] || [dict[@"rankState"] isEqualToString:@"down"]) {
            NSString *countStr = _item[rankCount][@"rankCnt"];
            CGSize countStrSize = [countStr sizeWithFont:[UIFont systemFontOfSize:15]];
            
            headerCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, countStrSize.width, 44)];
            [headerCountLabel setBackgroundColor:[UIColor clearColor]];
            [headerCountLabel setText:countStr];
            [headerCountLabel setTextColor:UIColorFromRGB(0x333333)];
            [headerCountLabel setFont:[UIFont systemFontOfSize:15]];
            [headerRankStateView addSubview:headerCountLabel];
            
            [headerIconView setFrame:CGRectMake(CGRectGetMaxX(headerCountLabel.frame)+4, 16, 10, 13)];
            [headerIconView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ic_s_rank_%@.png", [dict[@"rankState"] isEqualToString:@"up"]?@"up":@"down"]]];
            
            [headerRankStateView setFrame:CGRectMake(0, 0, CGRectGetMaxX(headerIconView.frame), 44)];
        }
        else if ([dict[@"rankState"] isEqualToString:@"same"]) {
            [headerIconView setFrame:CGRectMake(0, 15, 10, 13)];
            [headerIconView setImage:[UIImage imageNamed:@"ic_s_rank_nor.png"]];
            
            [headerRankStateView setFrame:CGRectMake(0, 0, 10, 44)];
        }
        else if ([dict[@"rankState"] isEqualToString:@"new"]) {
            [headerIconView setFrame:CGRectMake(0, 17, 25, 10)];
            [headerIconView setImage:[UIImage imageNamed:@"ic_pd_rank_new.png"]];
            
            [headerRankStateView setFrame:CGRectMake(0, 0, 25, 44)];
        }
        
        [headerRankStateView setFrame:CGRectMake(arrowImageView.frame.origin.x-17-CGRectGetWidth(headerRankStateView.frame), 0, CGRectGetWidth(headerRankStateView.frame), 44)];
        [headerView addSubview:headerRankStateView];
        
        headerRankTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(headerRankCountLabel.frame)+16, 0, headerRankStateView.frame.origin.x-(CGRectGetMaxX(headerRankCountLabel.frame)+16), 44)];
        [headerRankTitle setBackgroundColor:[UIColor clearColor]];
        [headerRankTitle setText:_item[rankCount][@"keyword"]];
        [headerRankTitle setTextColor:UIColorFromRGB(0x333333)];
        [headerRankTitle setTextAlignment:NSTextAlignmentLeft];
        [headerRankTitle setFont:[UIFont systemFontOfSize:15]];
        [headerView addSubview:headerRankTitle];
        
        UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, kScreenBoundsWidth, 1)];
        [underLineView setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
        [headerView addSubview:underLineView];
        
        [linkButton setHidden:NO];
        [linkButton setFrame:CGRectMake(0, 0, CGRectGetWidth(headerView.frame)-42, CGRectGetHeight(headerView.frame))];
        [expandButton setFrame:CGRectMake(kScreenBoundsWidth-42, 0, 42, CGRectGetHeight(headerView.frame))];
        viewHeight = 44;
    }
}

#pragma mark - Private Methods

- (UIView *)drawRankStateView:(NSInteger)index
{
    NSDictionary *dict = _item[index];

    headerRankStateView = [[UIView alloc] init];
    UIImageView *iconView = [[UIImageView alloc] init];
    [headerRankStateView addSubview:iconView];
    
    if ([dict[@"rankState"] isEqualToString:@"up"] || [dict[@"rankState"] isEqualToString:@"down"]) {
        NSString *countStr = _item[index][@"rankCnt"];
        CGSize countStrSize = [countStr sizeWithFont:[UIFont systemFontOfSize:15]];
        
        UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, countStrSize.width, 44)];
        [countLabel setBackgroundColor:[UIColor clearColor]];
        [countLabel setText:countStr];
        [countLabel setTextColor:UIColorFromRGB(0x333333)];
        [countLabel setFont:[UIFont systemFontOfSize:15]];
        [headerRankStateView addSubview:countLabel];
        
        [iconView setFrame:CGRectMake(CGRectGetMaxX(countLabel.frame)+4, 16, 10, 13)];
        [iconView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ic_s_rank_%@.png", [dict[@"rankState"] isEqualToString:@"up"]?@"up":@"down"]]];
        
        [headerRankStateView setFrame:CGRectMake(0, 0, CGRectGetMaxX(iconView.frame), 44)];
    }
    else if ([dict[@"rankState"] isEqualToString:@"same"]) {
        [iconView setFrame:CGRectMake(0, 15, 10, 13)];
        [iconView setImage:[UIImage imageNamed:@"ic_s_rank_nor.png"]];
        
        [headerRankStateView setFrame:CGRectMake(0, 0, 10, 44)];
    }
    else if ([dict[@"rankState"] isEqualToString:@"new"]) {
        [iconView setFrame:CGRectMake(0, 17, 25, 10)];
        [iconView setImage:[UIImage imageNamed:@"ic_pd_rank_new.png"]];
        
        [headerRankStateView setFrame:CGRectMake(0, 0, 25, 44)];
    }
    
    return headerRankStateView;
}

- (void)setScrollInfo
{
    if (!isExpand) {
        [headerRankCountLabel setText:[NSString stringWithFormat:@"%d", (int)(rankCount+1)]];
        [headerRankCountLabel setTextColor:rankCount < 3?UIColorFromRGB(0xf62e3d):UIColorFromRGB(0x999999)];
        [headerCountLabel setText:_item[rankCount][@"rankCnt"]];
        [headerRankTitle setText:_item[rankCount][@"keyword"]];
        
        if ([_item[rankCount][@"rankState"] isEqualToString:@"up"] || [_item[rankCount][@"rankState"] isEqualToString:@"down"]) {
            [headerIconView setFrame:CGRectMake(CGRectGetMaxX(headerCountLabel.frame)+4, 16, 10, 13)];
            [headerIconView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ic_s_rank_%@.png", [_item[rankCount][@"rankState"] isEqualToString:@"up"]?@"up":@"down"]]];
            [headerRankStateView setFrame:CGRectMake(0, 0, CGRectGetMaxX(headerIconView.frame), 44)];
        }
        else if ([_item[rankCount][@"rankState"] isEqualToString:@"same"]) {
            [headerIconView setFrame:CGRectMake(0, 15, 10, 13)];
            [headerIconView setImage:[UIImage imageNamed:@"ic_s_rank_nor.png"]];
            [headerRankStateView setFrame:CGRectMake(0, 0, 10, 44)];
        }
        else if ([_item[rankCount][@"rankState"] isEqualToString:@"new"]) {
            [headerIconView setFrame:CGRectMake(0, 17, 25, 10)];
            [headerIconView setImage:[UIImage imageNamed:@"ic_pd_rank_new.png"]];
            [headerRankStateView setFrame:CGRectMake(0, 0, 25, 44)];
        }
        [headerRankStateView setFrame:CGRectMake(kScreenBoundsWidth-28-17-CGRectGetWidth(headerRankStateView.frame), 0, CGRectGetWidth(headerRankStateView.frame), 44)];
    }
}

- (void)removeFromSuperview {
    
    @try {
        [self stopAutoScroll];
    }
    @catch (NSException *exception) {
        
    }
    
    [super removeFromSuperview];
}

- (void)dealloc {
    @try {
        [self stopAutoScroll];
    }
    @catch (NSException *exception) {
        
    }
}

#pragma mark - timer
- (void)startAutoScroll
{
    if (_item.count > 1 && self.timer == nil)
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopAutoScroll
{
    if (self.timer && self.timer.isValid)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)autoScroll
{
    if (rankCount < 9) {
        rankCount++;
    }
    else {
        rankCount = 0;
    }
    
    [self setScrollInfo];
}

#pragma mark - Selectors

- (void)touchLinkButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [button setTag:rankCount];
    
    [self touchSearchKeyword:sender];
    
    //AccessLog - 실시간 급상승 클릭
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPJ17"];
}

- (void)touchExpandButton:(id)sender
{
    isExpand = !isExpand;
    [self layoutSubviews];
    
    if ([self.delegate respondsToSelector:@selector(didTouchExpandButton:height:)]) {
        [self.delegate didTouchExpandButton:CPDescriptionBottomViewTypeLiveKeyword height:viewHeight];
    }
    
    //AccessLog - 실시간 급상승 열기
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPJ18"];
}

- (void)touchSearchKeyword:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSString *linkUrl = _item[button.tag][@"linkUrl"];
    
    if ([self.delegate respondsToSelector:@selector(didTouchSearchKeyword:)]) {
        [self.delegate didTouchSearchKeyword:linkUrl];
    }
    
    //AccessLog - 실시간 급상승 클릭
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPJ17"];
}

@end
