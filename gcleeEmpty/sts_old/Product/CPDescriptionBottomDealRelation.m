#import "CPDescriptionBottomDealRelation.h"
#import "CPDescriptionBottomSellerPrdList.h"
#import "UIImageView+WebCache.h"

#define VIEW_HEIGHT   212

@interface CPDescriptionBottomDealRelation () <CPDescriptionBottomSellerPrdListDelegate>
{
	NSDictionary *_item;
    NSString *_iconImageUrl;
    NSString *_title;
    
    UIView *headerView;
    UIImageView *iconView;
    UILabel *titleLabel;
    
    CPDescriptionBottomSellerPrdList *sellerPrdListView;
    
    UIView *topLineView;
    UIView *bottomLineView;
}

@end

@implementation CPDescriptionBottomDealRelation

- (id)initWithFrame:(CGRect)frame item:(NSDictionary *)item iconImageUrl:(NSString *)aIconImageUrl title:(NSString *)aTitle
{
	if (self = [super initWithFrame:frame])
	{
        if (item) {
            _item = item;
        }
        
        if (item) {
            _iconImageUrl = aIconImageUrl;
        }
        
        if (item) {
            _title = aTitle;
        }
		
		[self initLayout];
	}
	return self;
}

- (void)initLayout
{
	self.backgroundColor = [UIColor whiteColor];
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 38)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:headerView];
    
    iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [headerView addSubview:iconView];
    
    titleLabel = [[UILabel alloc] init];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:UIColorFromRGB(0x333333)];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [headerView addSubview:titleLabel];
    
    sellerPrdListView = [[CPDescriptionBottomSellerPrdList alloc] initWithFrame:CGRectZero item:_item[@"dealPopularPrd"][@"list"] moreUrl:@"" type:CPSellerPrdListTypeDealRelation];
    [sellerPrdListView setDelegate:self];
    [self addSubview:sellerPrdListView];
    
    topLineView = [[UIView alloc] initWithFrame:CGRectZero];
    [topLineView setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
    [self addSubview:topLineView];
    
    bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
    [bottomLineView setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
    [self addSubview:bottomLineView];
}

- (void)layoutSubviews
{
    NSString *imageUrl = _iconImageUrl;
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
        
        [iconView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
        iconView.frame = CGRectMake(10, 12, 39, 17);
    }
    else {
        iconView.frame = CGRectZero;
    }
    
    CGFloat titleLabelX = hasImgUrl?CGRectGetMaxX(iconView.frame)+6:10;
    
    [titleLabel setFrame:CGRectMake(titleLabelX, 12, kScreenBoundsWidth-titleLabelX, 15)];
    [titleLabel setText:_title];
    
    [sellerPrdListView setFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), kScreenBoundsWidth, 155)];
    
    [topLineView setFrame:CGRectMake(0, 0, kScreenBoundsWidth, 1)];
    [bottomLineView setFrame:CGRectMake(0, VIEW_HEIGHT-1, kScreenBoundsWidth, 1)];
}

- (void)didTouchSellerPrd:(NSString *)prdNo
{
    if ([self.delegate respondsToSelector:@selector(didTouchSellerPrd:)]) {
        [self.delegate didTouchSellerPrd:prdNo];
    }
}

@end
