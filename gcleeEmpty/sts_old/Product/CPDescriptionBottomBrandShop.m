#import "CPDescriptionBottomBrandShop.h"
#import "UIImageView+WebCache.h"
#import "AccessLog.h"

#define VIEW_HEIGHT 60

@interface CPDescriptionBottomBrandShop ()
{
	NSDictionary *_item;
    
    UIImageView *_iconView;
    UILabel *_titleLabel;
    UILabel *_brandShopLabel;
    UIImageView *_arrowView;
    
    UIView *_topLineView;
    UIView *_bottomLineView;
    
    UIButton *_blankButton;
}

@end

@implementation CPDescriptionBottomBrandShop

- (id)initWithFrame:(CGRect)frame item:(NSDictionary *)item
{
	if (self = [super initWithFrame:frame])
	{
        if (item) {
            _item = item;
        }
		
		[self initLayout];
	}
	return self;
}

- (void)initLayout
{
	self.backgroundColor = [UIColor whiteColor];
    
    _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:_iconView];
    
    UIImage *imgArrow = [UIImage imageNamed:@"ic_pd_arrow_right_02.png"];
    _arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-10.f-imgArrow.size.width,
                                                               (self.frame.size.height/2)-(imgArrow.size.height/2),
                                                               imgArrow.size.width,
                                                               imgArrow.size.height)];
    _arrowView.image = imgArrow;
    [self addSubview:_arrowView];
    
    _brandShopLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _brandShopLabel.backgroundColor = [UIColor clearColor];
    _brandShopLabel.font = [UIFont systemFontOfSize:13.f];
    _brandShopLabel.textColor = UIColorFromRGB(0x283593);
    _brandShopLabel.textAlignment = NSTextAlignmentLeft;
    _brandShopLabel.text = @"브랜드샵";
    [self addSubview:_brandShopLabel];
    
    [_brandShopLabel sizeToFitWithFloor];
    _brandShopLabel.frame = CGRectMake(_arrowView.frame.origin.x-5.f-_brandShopLabel.frame.size.width,
                                  (self.frame.size.height/2)-(_brandShopLabel.frame.size.height/2),
                                  _brandShopLabel.frame.size.width,
                                  _brandShopLabel.frame.size.height);
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont boldSystemFontOfSize:16];
    _titleLabel.textColor = UIColorFromRGB(0x333333);
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.numberOfLines = 1;
    [self addSubview:_titleLabel];
    
    _topLineView = [[UIView alloc] initWithFrame:CGRectZero];
    [_topLineView setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
    [self addSubview:_topLineView];
    
    _bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
    [_bottomLineView setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
    [self addSubview:_bottomLineView];
    
    _blankButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_blankButton setFrame:CGRectZero];
    [_blankButton setBackgroundImage:[UIImage imageNamed:@"bg_000000.png"] forState:UIControlStateHighlighted];
    [_blankButton setAlpha:0.3];
    [_blankButton addTarget:self action:@selector(touchBrandShop:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_blankButton];
}

- (void)layoutSubviews
{
    NSString *imageUrl = _item[@"imgUrl"];
    BOOL hasImgUrl = [imageUrl length] > 0;
    
    if (hasImgUrl) {
        NSRange strRange = [imageUrl rangeOfString:@"http"];
        if (strRange.location == NSNotFound) {
            imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:imageUrl];
        }
        strRange = [imageUrl rangeOfString:@"{{img_width}}"];
        if (strRange.location != NSNotFound) {
            imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%d", 160]];
        }
        strRange = [imageUrl rangeOfString:@"{{img_height}}"];
        if (strRange.location != NSNotFound) {
            imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%d", 160]];
        }
        
        [_iconView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
        _iconView.frame = CGRectMake(10, (VIEW_HEIGHT-32)/2, 81, 32);
    }
    else {
        _iconView.frame = CGRectZero;
    }
    
    UIImage *imgArrow = [UIImage imageNamed:@"ic_pd_arrow_right_02.png"];
    NSString *titleStr = _item[@"label"];
    CGFloat titleLabelX = hasImgUrl?CGRectGetMaxX(_iconView.frame)+10:10;
    
    _titleLabel.text = titleStr;
    [_titleLabel setFrame:CGRectMake(titleLabelX, 0, kScreenBoundsWidth-titleLabelX-imgArrow.size.width, VIEW_HEIGHT)];   //브랜드샾 width빼기
    
    [_topLineView setFrame:CGRectMake(0, 0, kScreenBoundsWidth, 1)];
    [_bottomLineView setFrame:CGRectMake(0, VIEW_HEIGHT-1, kScreenBoundsWidth, 1)];
    
    [_blankButton setFrame:CGRectMake(0, 0, kScreenBoundsWidth, VIEW_HEIGHT)];
}

#pragma mark - Selectors

- (void)touchBrandShop:(id)sender
{
    NSString *linkUrl = _item[@"brandShopLinkUrl"];
    if ([self.delegate respondsToSelector:@selector(didTouchBrandShop:)]) {
        if (linkUrl && [[linkUrl trim] length] > 0) {
            [self.delegate didTouchBrandShop:linkUrl];
        }
    }
    
    //AccessLog - 브랜드몰 클릭
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPJ16"];
}

@end
