#import "CPDescriptionBottomSellerPrdList.h"
#import "TTTAttributedLabel.h"
#import "UIImageView+WebCache.h"
#import "CPString+Formatter.h"
#import "AccessLog.h"

#define VIEW_WIDTH      102
#define VIEW_HEIGHT     155

@interface CPDescriptionBottomSellerPrdList () <UIScrollViewDelegate>
{
	NSArray *_item;
    NSString *_moreUrl;
    CPSellerPrdListType _type;
    
    UIScrollView *scrollView;
}

@end

@implementation CPDescriptionBottomSellerPrdList

- (id)initWithFrame:(CGRect)frame item:(NSArray *)item moreUrl:(NSString *)aMoreUrl type:(CPSellerPrdListType)type
{
	if (self = [super initWithFrame:frame])
	{
        if (item) {
            _item = item;
        }
        
        if (aMoreUrl) {
            _moreUrl = aMoreUrl;
        }
        
        if (type) {
            _type = type;
        }
		
		[self initLayout];
	}
	return self;
}

- (void)initLayout
{
	self.backgroundColor = [UIColor whiteColor];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, VIEW_HEIGHT)];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    [scrollView setBounces:NO];
    [scrollView setDelegate:self];
    [self addSubview:scrollView];
}

- (void)layoutSubviews
{
    [scrollView setContentSize:CGSizeMake(10+_item.count*(VIEW_WIDTH+10), VIEW_HEIGHT)];
    
    CGFloat itemX = 10;
    
    for (NSDictionary *dic in _item) {
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(itemX, 0, VIEW_WIDTH, VIEW_HEIGHT)];
        [scrollView addSubview:contentView];
        
        UIImageView *imgView = [[UIImageView alloc] init];
        [contentView addSubview:imgView];
        
        NSString *imageUrl = dic[@"imgUrl"];
        BOOL hasImgUrl = [imageUrl length] > 0;
        
        if (hasImgUrl) {
            NSRange strRange = [imageUrl rangeOfString:@"http"];
            if (strRange.location == NSNotFound) {
                imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:imageUrl];
            }
            strRange = [imageUrl rangeOfString:@"{{img_width}}"];
            if (strRange.location != NSNotFound) {
                imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%d", VIEW_WIDTH]];
            }
            strRange = [imageUrl rangeOfString:@"{{img_height}}"];
            if (strRange.location != NSNotFound) {
                imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%d", VIEW_WIDTH]];
            }
            
            [imgView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
            imgView.frame = CGRectMake(0, 0, VIEW_WIDTH, VIEW_WIDTH);
        }
        else {
            imgView.frame = CGRectZero;
        }
        
        UILabel *prdNmLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, VIEW_WIDTH+14, VIEW_WIDTH-10, 15)];
        [prdNmLabel setBackgroundColor:[UIColor clearColor]];
        [prdNmLabel setTextColor:UIColorFromRGB(0x333333)];
        [prdNmLabel setFont:[UIFont systemFontOfSize:14]];
        [prdNmLabel setTextAlignment:NSTextAlignmentCenter];
        [contentView addSubview:prdNmLabel];
        
        if (dic[@"prdNm"]) {
            
            NSString *str = dic[@"prdNm"];
            NSInteger index = 0;
            
            for (int i = 0; i < [str length]; i++) {
                CGSize size = [[str substringWithRange:NSMakeRange(0, i)] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(10000, CGRectGetHeight(prdNmLabel.frame)) lineBreakMode:prdNmLabel.lineBreakMode];
                
                if (size.width > CGRectGetWidth(prdNmLabel.frame)) {
                    break;
                }
                index = i;
            }
            
            [prdNmLabel setText:[str substringWithRange:NSMakeRange(0, index)]];
        }
        
        TTTAttributedLabel *priceLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(prdNmLabel.frame)+1, VIEW_WIDTH, 15)];
        [priceLabel setBackgroundColor:[UIColor clearColor]];
        [priceLabel setTextColor:UIColorFromRGB(0x333333)];
        [priceLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [priceLabel setTextAlignment:NSTextAlignmentCenter];
        [contentView addSubview:priceLabel];
        
        NSString *text = [NSString stringWithFormat:@"%@원", [dic[@"finalDscPrc"] formatThousandComma]];
        [priceLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
            NSRange colorRange = [text rangeOfString:@"원"];
            if (colorRange.location != NSNotFound)
            {
                [mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont boldSystemFontOfSize:14] range:colorRange];
            }
            return mutableAttributedString;
        }];
        
        UIButton *blankButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [blankButton setFrame:CGRectMake(0, 0, CGRectGetWidth(contentView.frame), CGRectGetHeight(contentView.frame))];
        [blankButton setTag:[_item indexOfObject:dic]];
        [blankButton setBackgroundImage:[UIImage imageNamed:@"bg_000000.png"] forState:UIControlStateHighlighted];
        [blankButton setAlpha:0.3];
        [blankButton addTarget:self action:@selector(touchSellerPrd:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:blankButton];
        
        itemX += 10+VIEW_WIDTH;
    }
    
    
    //더보기
    if (_type == CPSellerPrdListTypeMiniMall || _type == CPSellerPrdListTypeCategoryPopular) {
        
        NSString *title = @"";
        if (_type == CPSellerPrdListTypeMiniMall) {
            title = @"판매자상품\n더보기";
        }
        else if (_type == CPSellerPrdListTypeCategoryPopular) {
            title = @"카테고리상품\n더보기";
        }
        
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreButton setFrame:CGRectMake(itemX, 0, VIEW_WIDTH, VIEW_HEIGHT)];
        [moreButton.layer setBorderColor:UIColorFromRGB(0xededed).CGColor];
        [moreButton.layer setBorderWidth:1];
        [moreButton setImage:[UIImage imageNamed:@"bt_detail_more.png"] forState:UIControlStateNormal];
        [moreButton setImage:[UIImage imageNamed:@"bt_detail_more_press.png"] forState:UIControlStateHighlighted];
        [moreButton setImageEdgeInsets:UIEdgeInsetsMake(-30, 0, 0, 0)];
        [moreButton addTarget:self action:@selector(touchMoreButton:) forControlEvents:UIControlEventTouchUpInside];
        [moreButton setAccessibilityLabel:title Hint:@"상품 더보기"];
        [moreButton setTag:_item.count];
        [scrollView addSubview:moreButton];
        
        UILabel *moreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 82, VIEW_WIDTH, 36)];
        [moreLabel setBackgroundColor:[UIColor clearColor]];
        [moreLabel setText:title];
        [moreLabel setTextColor:UIColorFromRGB(0x2b3794)];
        [moreLabel setFont:[UIFont systemFontOfSize:13]];
        [moreLabel setTextAlignment:NSTextAlignmentCenter];
        [moreLabel setNumberOfLines:2];
        [moreButton addSubview:moreLabel];
        
        [scrollView setContentSize:CGSizeMake(scrollView.contentSize.width+10+VIEW_WIDTH, VIEW_HEIGHT)];
    }
}

#pragma mark - Selectors

- (void)touchSellerPrd:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSString *prdNo;
    
    if ([_item[button.tag][@"prdNo"] isKindOfClass:[NSNumber class]]) {
        prdNo = [_item[button.tag][@"prdNo"] stringValue];
    }
    else {
        prdNo = _item[button.tag][@"prdNo"];
    }
    
    if ([self.delegate respondsToSelector:@selector(didTouchSellerPrd:)]) {
        [self.delegate didTouchSellerPrd:prdNo];
    }
    
    //AccessLog
    if (_type == CPSellerPrdListTypeMiniMall) {
        //AccessLog - 판매자 상품 클릭
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPK02"];
    }
    else if (_type == CPSellerPrdListTypeCategoryPopular) {
        //AccessLog - 카테고리 인기상품 클릭
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPK06"];
    }
    else if (_type == CPSellerPrdListTypeDealRelation) {
        //AccessLog - 쇼킹딜 상품 클릭
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPK10"];
    }
    else if (_type == CPSellerPrdListTypePrdRecommend) {
        //AccessLog - 함께 본 상품 클릭
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPK12"];
    }
}

- (void)touchMoreButton:(id)sender
{
    if ([_moreUrl hasPrefix:@"app://gosearch/"]) {
        _moreUrl = [_moreUrl stringByReplacingOccurrencesOfString:@"app://gosearch/" withString:@""];
        _moreUrl = [_moreUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    if ([self.delegate respondsToSelector:@selector(didTouchMoreButton:type:)]) {
        if (_moreUrl && [[_moreUrl trim] length] > 0) {
            [self.delegate didTouchMoreButton:_moreUrl type:_type];
        }
    }
}

@end
