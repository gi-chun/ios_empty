#import "CPDescriptionBottomPrdRecommend.h"
#import "CPDescriptionBottomSellerPrdList.h"
#import "UIImageView+WebCache.h"

#define VIEW_HEIGHT   212

@interface CPDescriptionBottomPrdRecommend () <CPDescriptionBottomSellerPrdListDelegate>
{
	NSDictionary *_item;
    NSString *_title;
    
    UIView *headerView;
    UILabel *titleLabel;
    
    CPDescriptionBottomSellerPrdList *sellerPrdListView;
    
    UIView *topLineView;
    UIView *bottomLineView;
}

@end

@implementation CPDescriptionBottomPrdRecommend

- (id)initWithFrame:(CGRect)frame item:(NSDictionary *)item title:(NSString *)aTitle
{
	if (self = [super initWithFrame:frame])
	{
        if (item) {
            _item = item;
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
    
    titleLabel = [[UILabel alloc] init];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:UIColorFromRGB(0x333333)];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [headerView addSubview:titleLabel];
    
    sellerPrdListView = [[CPDescriptionBottomSellerPrdList alloc] initWithFrame:CGRectZero item:_item[@"response"][@"resultList"] moreUrl:@"" type:CPSellerPrdListTypePrdRecommend];
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
    [titleLabel setFrame:CGRectMake(10, 12, kScreenBoundsWidth-10, 15)];
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
