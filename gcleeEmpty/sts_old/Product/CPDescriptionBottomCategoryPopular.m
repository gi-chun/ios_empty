#import "CPDescriptionBottomCategoryPopular.h"
#import "CPDescriptionBottomSellerPrdList.h"
#import "UIImageView+WebCache.h"
#import "AccessLog.h"

#define VIEW_HEIGHT   212

@interface CPDescriptionBottomCategoryPopular () <CPDescriptionBottomSellerPrdListDelegate>
{
	NSDictionary *_item;
    NSString *_morePrdUrl;
    UIView *headerView;
    
    CPDescriptionBottomSellerPrdList *sellerPrdListView;
    
    UIView *bottomLineView;
}

@end

@implementation CPDescriptionBottomCategoryPopular

- (id)initWithFrame:(CGRect)frame item:(NSDictionary *)item morePrdUrl:(NSString *)morePrdUrl
{
	if (self = [super initWithFrame:frame])
	{
        if (item) {
            _item = item;
        }
        
        if (morePrdUrl) {
            _morePrdUrl = morePrdUrl;
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
    
    //카테고리뷰
    [headerView addSubview:[self makeCategoryView]];
    
    sellerPrdListView = [[CPDescriptionBottomSellerPrdList alloc] initWithFrame:CGRectZero item:_item[@"categoryPopularPrd"][@"list"] moreUrl:_morePrdUrl type:CPSellerPrdListTypeCategoryPopular];
    [sellerPrdListView setDelegate:self];
    [self addSubview:sellerPrdListView];
    
    bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
    [bottomLineView setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
    [self addSubview:bottomLineView];
}

- (void)layoutSubviews
{
    [sellerPrdListView setFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame)+10, kScreenBoundsWidth, 155)];
    
    [bottomLineView setFrame:CGRectMake(0, VIEW_HEIGHT-1, kScreenBoundsWidth, 1)];
}

- (UIView *)makeCategoryView
{
    UIView *categoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 38)];
    [categoryView setBackgroundColor:[UIColor whiteColor]];
    
    NSArray *array = _item[@"categoryPopularPrd"][@"ctgrLocation"];
    NSInteger listCount = [array count];
    NSInteger viewSizeWidth = 8;
    
    for (int i = 0; i < listCount; i++) {
        
        NSDictionary *dic = array[i];
        
        CGFloat buttonWidth = 70;
        if (IS_IPAD || IS_IPHONE_6PLUS) {
            buttonWidth = 90;
        }
        
        //버튼
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(viewSizeWidth, 11, buttonWidth, 15)];
        [button setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xededf2)] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(touchCategoryArea:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:i];
        [categoryView addSubview:button];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, buttonWidth-4, 15)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setText:[dic objectForKey:@"name"]];
        [label setTextColor:UIColorFromRGB(0x333333)];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [button addSubview:label];
        
        viewSizeWidth += button.frame.size.width;
        
        //마지막
        if (i == listCount-1) {
            
            CGSize buttonLabelSize = [[dic objectForKey:@"name"] sizeWithFont:[UIFont boldSystemFontOfSize:14]];
            CGFloat buttonLastWidth = CGRectGetWidth(self.frame)-CGRectGetMinX(button.frame);
            
            [button setFrame:CGRectMake(CGRectGetMinX(button.frame)+2, 11, buttonLabelSize.width < buttonLastWidth ? buttonLabelSize.width+4 : buttonLastWidth, 15)];
            [label setFrame:CGRectMake(2, 0, buttonLastWidth-4, 15)];
            [label setTextAlignment:NSTextAlignmentLeft];
            [label setFont:[UIFont boldSystemFontOfSize:14]];
            
            break;
        }
        
        //arrow
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(viewSizeWidth, 13, 6, 11)];
        [arrowImageView setImage:[UIImage imageNamed:@"ic_pd_arrow_right_03.png"]];
        [categoryView addSubview:arrowImageView];
        
        viewSizeWidth += arrowImageView.frame.size.width;
    }
    
    UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 37, kScreenBoundsWidth, 1)];
    [underLineView setBackgroundColor:UIColorFromRGB(0xededed)];
    [categoryView addSubview:underLineView];
    
    return categoryView;
}

#pragma mark - Selectors

- (void)didTouchSellerPrd:(NSString *)prdNo
{
    if ([self.delegate respondsToSelector:@selector(didTouchSellerPrd:)]) {
        [self.delegate didTouchSellerPrd:prdNo];
    }
}

- (void)didTouchMoreButton:(NSString *)moreUrl type:(CPSellerPrdListType)type
{
    if ([self.delegate respondsToSelector:@selector(didTouchMoreButton:type:)]) {
        [self.delegate didTouchMoreButton:moreUrl type:type];
    }
    
    //AccessLog - 카테고리 인기상품 더보기
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPK08"];
}

- (void)touchCategoryArea:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSString *url= _item[@"categoryPopularPrd"][@"ctgrLocation"][button.tag][@"linkNM"];
    
    if ([url hasPrefix:@"app://gosearch/"]) {
        url = [url stringByReplacingOccurrencesOfString:@"app://gosearch/" withString:@""];
        url = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    if ([self.delegate respondsToSelector:@selector(didTouchCategoryArea:)]) {
        if (url && [[url trim] length] > 0) {
            [self.delegate didTouchCategoryArea:url];
        }
    }
    
    //AccessLog - 카테고리 인기상품 카테고리 클릭
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPK07"];
}

@end
