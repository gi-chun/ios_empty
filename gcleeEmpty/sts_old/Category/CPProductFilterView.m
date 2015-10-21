//
//  CPProductFilterView.m
//  11st
//
//  Created by spearhead on 2015. 6. 4..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductFilterView.h"
#import "CPProductFilterCategoryView.h"
#import "CPProductFilterBrandView.h"
#import "CPProductFilterPartnerView.h"
#import "CPProductFilterSearchView.h"
#import "iCarousel.h"
#import "AccessLog.h"

@interface CPProductFilterView() <iCarouselDataSource,
                                  iCarouselDelegate,
                                  CPProductFilterCategoryViewDelegate,
                                  CPProductFilterBrandViewDelegate,
                                  CPProductFilterPartnerViewDelegate,
                                  CPProductFilterSearchViewDelegate>
{
    NSMutableArray *menuItems;
    NSInteger currentItemIndex;
    
    CGFloat filterWidth;
    
    UIView *containerView;
    UIView *tabMenuView;
    iCarousel *contentsView;
    CPProductFilterCategoryView *categoryView;
    CPProductFilterBrandView *brandView;;
    CPProductFilterPartnerView *partnerView;
    CPProductFilterSearchView *searchView;
    
    NSMutableDictionary *metaInfo;
    NSMutableDictionary *categoryInfo;
    NSMutableDictionary *brandInfo;
    NSMutableDictionary *partnerInfo;
    NSMutableDictionary *detailInfo;

    NSString *selectedKey;
    NSString *listingType;
}

@end

@implementation CPProductFilterView

- (id)initWithFrame:(CGRect)frame metaInfo:(NSMutableDictionary *)aMetaInfo selectedKey:(NSString *)aSelectedKey
{
    self = [super initWithFrame:frame];
    if (self) {
        
        metaInfo = aMetaInfo;
        selectedKey = aSelectedKey;
        filterWidth = kScreenBoundsWidth - 50;
        listingType = metaInfo[@"listingType"];
        
        containerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame), 0, filterWidth, CGRectGetHeight(frame))];
        [containerView setBackgroundColor:UIColorFromRGB(0xffffff)];
        [self addSubview:containerView];
        
        [UIView animateWithDuration:0.5f animations:^{
            [containerView setFrame:CGRectMake(50, 0, filterWidth, CGRectGetHeight(frame))];
            [self setBackgroundColor:UIColorFromRGBA(0x000000, 0.4f)];
        } completion:^(BOOL finished) {
            
        }];
        
        [self initData];
        
        [self initLayout];
        
    }
    return self;
}

- (void)initData
{
    categoryInfo = [NSMutableDictionary dictionary];
    brandInfo = [NSMutableDictionary dictionary];
    partnerInfo = [NSMutableDictionary dictionary];
    detailInfo = [NSMutableDictionary dictionary];
    menuItems = [NSMutableArray array];
    
    if (metaInfo[@"category"]) {
        categoryInfo = metaInfo[@"category"];
        [menuItems addObject:@{@"key": @"category",
                               @"title": (categoryInfo[@"title"] ? categoryInfo[@"title"] : @"카테고리"),
                               @"isSelected": ([selectedKey isEqualToString:@"category"] ? @"Y" : @"N")}];
    }
    
    if (metaInfo[@"brand"]) {
        brandInfo = metaInfo[@"brand"];
        [menuItems addObject:@{@"key": @"brand",
                               @"title": (brandInfo[@"title"] ? brandInfo[@"title"] : @"브랜드" ),
                               @"isSelected": ([selectedKey isEqualToString:@"brand"] ? @"Y" : @"N")}];
    }
    
    if (metaInfo[@"partner"]) {
        partnerInfo = metaInfo[@"partner"];
        [menuItems addObject:@{@"key": @"partner",
                               @"title": (partnerInfo[@"title"] ? partnerInfo[@"title"] : @"파트너스"),
                               @"isSelected": ([selectedKey isEqualToString:@"partner"] ? @"Y" : @"N")}];
    }
    
    if (metaInfo[@"detail"]) {
        detailInfo = [metaInfo[@"detail"] mutableCopy];
        
        //가격비교 여부
        BOOL isPriceCompare = metaInfo.count == 2;
        [detailInfo setObject:isPriceCompare?@"Y":@"N" forKey:@"isPriceCompare"];
    }
    
//    [menuItems addObject:@{@"key": @"category", @"title": @"카테고리"}];
//    [menuItems addObject:@{@"key": @"brand", @"title": @"브랜드"}];
//    [menuItems addObject:@{@"key": @"partner", @"title": @"파트너스"}];
    [menuItems addObject:@{@"key": @"detail", @"title": @"상세검색", @"isSelected": ([selectedKey isEqualToString:@"detail"] ? @"Y" : @"N")}];
}

#pragma makrk - Layout

- (void)initLayout
{
    
    
    //메뉴
    tabMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, ([SYSTEM_VERSION intValue] < 7 ? 0 : kStatusBarHeight), CGRectGetWidth(containerView.frame), 51)];
    [tabMenuView setBackgroundColor:UIColorFromRGB(0xd3d7e5)];
    [containerView addSubview:tabMenuView];
    
    //컨텐츠
    contentsView = [[iCarousel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tabMenuView.frame), CGRectGetWidth(containerView.frame), CGRectGetHeight(containerView.frame)-(([SYSTEM_VERSION intValue] < 7 ? 0 : kStatusBarHeight)+CGRectGetHeight(tabMenuView.frame)))];
    [contentsView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [contentsView setType:iCarouselTypeLinear];
    [contentsView setDataSource:self];
    [contentsView setDelegate:self];
//    [contentsView setDecelerationRate:0.7f];
//    [contentsView setScrollSpeed:1.0f];
//    [contentsView setBounceDistance:0.5f];
//    [contentsView setPagingEnabled:YES];
    [contentsView setScrollEnabled:NO];
    [contentsView setClipsToBounds:YES];
    [containerView addSubview:contentsView];
    
    CGFloat topMenuButtonWidth = filterWidth/menuItems.count;
    
    for (int i = 0; i < menuItems.count; i++) {
        NSDictionary *menu = menuItems[i];
        
        UIButton *topMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [topMenuButton setFrame:CGRectMake(topMenuButtonWidth*i, 0, topMenuButtonWidth-1, CGRectGetHeight(tabMenuView.frame)-1)];
        [topMenuButton setBackgroundColor:UIColorFromRGB(0xf0f2f9)];
        [topMenuButton setTitleColor:UIColorFromRGB(0x73747e) forState:UIControlStateNormal];
        [topMenuButton setTitle:menu[@"title"] forState:UIControlStateNormal];
        [topMenuButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [topMenuButton setTag:i];
        [topMenuButton addTarget:self action:@selector(touchTabMenuButton:) forControlEvents:UIControlEventTouchUpInside];
        [tabMenuView addSubview:topMenuButton];
        [self setButtonProperties:topMenuButton];
        
        if ([menu[@"isSelected"] isEqualToString:@"Y"]) {
            [self setHighlightedButtonProperties:topMenuButton];
            [self touchTabMenuButton:topMenuButton];
        }
    }
}

#pragma mark - iCarouselDataSource

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return  menuItems.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(contentsView.frame), CGRectGetHeight(contentsView.frame))];
    [view setBackgroundColor:[UIColor clearColor]];
    
    NSDictionary *menu = menuItems[index];
    
    if ([menu[@"key"] isEqualToString:@"category"]) {
        categoryView = [[CPProductFilterCategoryView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)+([SYSTEM_VERSION intValue] < 7 ? kStatusBarHeight : 0)) categoryInfo:categoryInfo listingType:listingType];
        [categoryView setDelegate:self];
        [view addSubview:categoryView];
    }
    else if ([menu[@"key"] isEqualToString:@"brand"]) {
        brandView = [[CPProductFilterBrandView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)+([SYSTEM_VERSION intValue] < 7 ? kStatusBarHeight : 0)) brandInfo:brandInfo listingType:listingType];
        [brandView setDelegate:self];
        [view addSubview:brandView];
    }
    else if ([menu[@"key"] isEqualToString:@"partner"]) {
        partnerView = [[CPProductFilterPartnerView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)+([SYSTEM_VERSION intValue] < 7 ? kStatusBarHeight : 0)) partnerInfo:partnerInfo listingType:listingType];
        [partnerView setDelegate:self];
        [view addSubview:partnerView];
    }
    else {
        searchView = [[CPProductFilterSearchView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)+([SYSTEM_VERSION intValue] < 7 ? kStatusBarHeight : 0)) detailInfo:detailInfo listingType:listingType];
        [searchView setDelegate:self];
        [view addSubview:searchView];
    }
    
    return view;
}

#pragma mark - iCarouselDelegate

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    switch (option) {
        case iCarouselOptionWrap:
            return YES;
            break;
        case iCarouselOptionVisibleItems:
            value = menuItems.count;
//            value = 3;
            break;
        case iCarouselOptionSpacing:
            break;
        default:
            break;
    }
    
    return value;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    [self tabMenuCurrentItemIndexDidChange:carousel.currentItemIndex];
}

#pragma mark - Private Methods

- (void)tabMenuCurrentItemIndexDidChange:(NSInteger)index
{
    currentItemIndex = index;
    
    for (UIView *subView in [tabMenuView subviews]) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subView;
            
            NSDictionary *title = menuItems[button.tag];
            NSDictionary *content = menuItems[index];
            
            if ([title[@"key"] isEqualToString:content[@"key"]]) {
                [self setHighlightedButtonProperties:button];
            }
            else {
                [self setButtonProperties:button];
            }
        }
    }
}

- (NSInteger)findTabMenu:(NSInteger)index
{
    NSInteger tabIndex = 0;
    NSString *menuTitleKey = menuItems[index][@"key"];
    
    for (int i = 0; i < menuItems.count; i++) {
        NSDictionary *menuContentInfo = menuItems[i];
        if ([menuTitleKey isEqualToString:menuContentInfo[@"key"]]) {
            
            tabIndex =  i;
            return tabIndex;
        }
    }
    
    return tabIndex;
}

- (void)setButtonProperties:(UIButton *)button
{
    [button setFrame:CGRectMake(button.frame.origin.x, button.frame.origin.y, button.frame.size.width, CGRectGetHeight(tabMenuView.frame)-1)];
    [button setBackgroundColor:UIColorFromRGB(0xf0f2f9)];
    [button setTitleColor:UIColorFromRGB(0x73747e) forState:UIControlStateNormal];
}

- (void)setHighlightedButtonProperties:(UIButton *)button
{
    [button setFrame:CGRectMake(button.frame.origin.x, button.frame.origin.y, button.frame.size.width, CGRectGetHeight(tabMenuView.frame))];
    [button setBackgroundColor:UIColorFromRGB(0xffffff)];
    [button setTitleColor:UIColorFromRGB(0x5e6dff) forState:UIControlStateNormal];
}

- (void)refreshData:(NSMutableDictionary *)searchMetaInfo
{
    metaInfo = [searchMetaInfo mutableCopy];
    listingType = metaInfo[@"listingType"];
    
    if (categoryView || searchView) {
        [categoryView refreshData:searchMetaInfo];
        [brandView refreshData:searchMetaInfo];
        [partnerView refreshData:searchMetaInfo];
        [searchView refreshData:searchMetaInfo];
    }
}

- (void)refreshTabData:(NSMutableDictionary *)searchMetaInfo
{
    //상세검색 전체 상품개수 리프레시
    [searchView refreshData:searchMetaInfo];
}

- (void)removeFilterView
{
    [UIView animateWithDuration:0.5f animations:^{
        [containerView setFrame:CGRectMake(CGRectGetWidth(self.frame), 0, filterWidth, CGRectGetHeight(self.frame))];
        [self setBackgroundColor:[UIColor clearColor]];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Selectors

//- (void)touchTopMenuButton:(id)sender
//{
//    UIButton *button = (UIButton *)sender;
//    
//    [self setHighlightedButtonProperties:button];
//}

- (void)touchTabMenuButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSInteger tabIndex = [self findTabMenu:button.tag];
    
    [contentsView scrollToItemAtIndex:tabIndex animated:NO];
    
    //detail정보 업데이트
    if (metaInfo[@"detail"]) {
        [searchView refreshData:metaInfo];
    }
    
    
    //AccessLog - 상단 탭 클릭 시
    if ([listingType isEqualToString:@"search"]) {
        if (button.tag == 0) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB01"];
        }
        else if (button.tag == 1) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB04"];
        }
        else if (button.tag == 2) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB07"];
        }
        else if (button.tag == 3) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB10"];
        }
    }
    else if ([listingType isEqualToString:@"category"]) {
        if (button.tag == 0) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB01"];
        }
        else if (button.tag == 1) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB04"];
        }
        else if (button.tag == 2) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB07"];
        }
        else if (button.tag == 3) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB10"];
        }
    }
    else if ([listingType isEqualToString:@"model"]) {
        if (button.tag == 0) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPB01"];
        }
        else if (button.tag == 1) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPB04"];
        }
    }
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    NSLog(@"touchesBegan outside");
    
    [self removeFilterView];
}

#pragma mark - CPProductFilterCategoryViewDelegate

- (void)didTouchCategoryButton:(NSString *)url
{
    if ([self.delegate respondsToSelector:@selector(didTouchCategoryButton:)]) {
        [self.delegate didTouchCategoryButton:url];
    }
}

#pragma mark - CPProductFilterBrandViewDelegate

- (void)didTouchBrandCheckButton:(NSString *)parameter
{
    if ([self.delegate respondsToSelector:@selector(didTouchBrandCheckButton:)]) {
        [self.delegate didTouchBrandCheckButton:parameter];
    }
}

#pragma mark - CPProductFilterPartnerViewDelegate

- (void)didTouchPartnerCheckButton:(NSString *)parameter
{
    if ([self.delegate respondsToSelector:@selector(didTouchPartnerCheckButton:)]) {
        [self.delegate didTouchPartnerCheckButton:parameter];
    }
}

#pragma mark - CPProductFilterSearchViewDelegate

- (void)didTouchDetailSearchButton:(NSString *)parameter
{
    if ([self.delegate respondsToSelector:@selector(didTouchDetailSearchButton:)]) {
        [self.delegate didTouchDetailSearchButton:parameter];
    }
    
//    [self removeFilterView];
}

@end
