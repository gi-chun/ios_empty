//
//  CPMenuViewController.m
//  11st
//
//  Created by spearhead on 2014. 9. 16..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPMenuViewController.h"
#import "HttpRequest.h"
#import "SBJSON.h"
#import "RegexKitLite.h"
#import "AccessLog.h"
#import "UIImageView+WebCache.h"

//Native
#import "UIViewController+MMDrawerController.h"
#import "CPHomeViewController.h"
//#import "CPWebView.h"
#import "CPCommonInfo.h"
#import "CPThumbnailView.h"
#import "CPCategoryMainViewController.h"
#import "CPCategoryDetailViewController.h"
#import "CPProductListViewController.h"
#import "CPWebViewController.h"

#define DISCLOSURE_INDICATOR_TAG		900
#define CELL_CONTENTVIEW_TAG			901

@interface CPMenuViewController () <UITableViewDataSource,
                                    UITableViewDelegate,
                                    HttpRequestDelegate>
{
    UITableView *categoryTableView;
    
    NSMutableDictionary *categoryAreaDictionary;
    NSMutableDictionary *serviceAreaDictionary;
    
    NSInteger currentExpandedIndex;
	NSInteger preExpandedIndex;
	
	BOOL isOpenChild;
    
    CGFloat statusBarHeight;
	CGFloat screenHeight;
}

@end

@implementation CPMenuViewController

- (id)init
{
	if ((self = [super init])) {
		currentExpandedIndex = -1;
		
		categoryAreaDictionary = [NSMutableDictionary dictionary];
		serviceAreaDictionary = [NSMutableDictionary dictionary];
	}
    
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:UIColorFromRGB(0xffffff)];
    
    // iOS7 Layout
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        statusBarHeight = 20;
    }
	
	screenHeight = 0.f;
	if ([SYSTEM_VERSION intValue] > 6)	screenHeight = kScreenBoundsHeight;
	else								screenHeight = kScreenBoundsHeight - 20.f;

//    categoryTableView = [[UITableView alloc] initWithFrame:CGRectMake(27, statusBarHeight, kScreenBoundsWidth-(56+60), screenHeight-statusBarHeight) style:UITableViewStylePlain];
    categoryTableView = [[UITableView alloc] initWithFrame:CGRectMake(27, statusBarHeight, kSideMenuWidth-60, screenHeight-statusBarHeight) style:UITableViewStylePlain];
	[categoryTableView setDelegate:self];
	[categoryTableView setDataSource:self];
	[categoryTableView setScrollsToTop:YES];
	[categoryTableView setBackgroundColor:UIColorFromRGB(0xffffff)];
	[categoryTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [categoryTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [categoryTableView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    [categoryTableView setShowsVerticalScrollIndicator:NO];
	[self.view addSubview:categoryTableView];
	
    // 프리로드 데이터
    [self loadPreloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Public Methods

- (void)didTouchInMart
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self findMartIndex] inSection:0];
    
    if (indexPath.section == 0) {
        preExpandedIndex = currentExpandedIndex;
        
        [categoryTableView beginUpdates];
        
        
            BOOL shouldCollapse = currentExpandedIndex > -1;
            
            if (shouldCollapse) {
                [self collapseSubItemsAtIndex:currentExpandedIndex];
            }
            
            currentExpandedIndex =  indexPath.row;
            
            [self expandItemAtIndex:currentExpandedIndex];
            
            isOpenChild = YES;
        
        
        [categoryTableView endUpdates];
    }
}

- (NSInteger)findMartIndex
{
    NSInteger index = 0;
    NSArray *items = categoryAreaDictionary[@"items"];
    
    if (items && items.count > 0) {
        for (int i = 0; i < items.count; i++) {
            NSDictionary *item = items[i];
            
            if ([item[@"text"] isEqualToString:@"바로마트"] || [item[@"text"] isEqualToString:@"마트11번가"]) {
                index = i;
                break;
            }
        }
    }
    
    return index;
}

#pragma mark - Private Methods

- (void)loadPreloadData
{
    serviceAreaDictionary = [[CPCommonInfo sharedInfo] dpServiceArea];
    categoryAreaDictionary = [[CPCommonInfo sharedInfo] categoryArea];
    
	[categoryTableView reloadData];
}

- (void)requestDownloadImage:(NSString *)url targetObject:(id)object
{
    HttpRequest *request = [[HttpRequest alloc] initWithSynchronous:YES];
    
    [request setEncoding:NSUTF8StringEncoding];
    [request setTargetObject:object];
    [request setDelegate:self];
    [request setRequestParameterType:RequestActionDownloadImage];
    [request sendGet:[Modules retinaPath:url] data:nil];
}

- (void)selectedAllMenu:(id)sender
{
	NSUInteger index = [sender tag];
	NSString *link = @"";
	
	if (index == 0) {
        if ([[categoryAreaDictionary[@"menu"] allKeys] containsObject:@"link_v650"]) {
            link = categoryAreaDictionary[@"menu"][@"link_v650"];
        }
        else {
            link = categoryAreaDictionary[@"menu"][@"link"];
        }
        
        //AccessLog - 카테고리 전체보기
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGB0301"];
    }
	else if (index == 1) {
        link = serviceAreaDictionary[@"menu"][@"link"];
        
        //AccessLog - 주요서비스 전체보기
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGB0401"];
    }
    
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = app.homeViewController;
        
        if ([link hasPrefix:@"app://gocategory/"]) {
            
            NSString *url = URLDecode([link stringByReplacingOccurrencesOfString:@"app://gocategory/" withString:@""]);
            
            CPCategoryMainViewController *viewController = [[CPCategoryMainViewController alloc] initWithUrl:url];
            //        [homeViewController.navigationController popToRootViewControllerAnimated:NO];
            [homeViewController.navigationController pushViewController:viewController animated:NO];
        }
        else {
            [homeViewController openWebViewControllerWithUrl:link animated:NO];
        }
        
    }];
}

- (void)selectedVerticalItem:(id)sender
{
	NSUInteger index = [sender tag];
    
	NSMutableDictionary *urlInfo =  [[CPCommonInfo sharedInfo] urlInfo];
	NSString *link = @"";
    
    switch (index) {
        case 0:
            link = [urlInfo objectForKey:@"soho11"];
            //AccessLog - soho11
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGB1301"];
            break;
        case 1:
            link = [urlInfo objectForKey:@"book"];
            //AccessLog -  도서
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGB1401"];
            break;
        case 2:
            link = [urlInfo objectForKey:@"mart"];
            //AccessLog - 바로마트
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGB1401"];
            break;
        case 3:
            //AccessLog - 기프티콘
            link = [urlInfo objectForKey:@"gift"];
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGB1501"];
            break;
        default:
            break;
    }
    
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = app.homeViewController;
//        [homeViewController openSubWebView:link];
        [homeViewController openWebViewControllerWithUrl:link animated:NO];
    }];
}

- (void)selectedServiceItem:(id)sender
{
	NSUInteger index = [sender tag];
	
    //Native
    NSString *link = serviceAreaDictionary[@"items"][index][@"link"];
    NSString *ac = serviceAreaDictionary[@"items"][index][@"ac"];
    
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = app.homeViewController;
        
        //모바일베스트일 경우 네이티브로 이동
        //텝 구분값을 ac로 하였으나 추후 바뀔 여지가 있음..
        if ([ac isEqualToString:@"AGB0901"]) {
            [homeViewController.navigationController popToRootViewControllerAnimated:NO];
            [homeViewController gotoNativeTab:ac];
        }
        else {
            [homeViewController openWebViewControllerWithUrl:link animated:NO];
        }
    }];
    
    //AccessLog - 주요서비스
    NSString *accessLogCode = [[[serviceAreaDictionary objectForKey:@"items"] objectAtIndex:index] objectForKey:@"ac"];
    if (accessLogCode && ![[accessLogCode trim] isEqualToString:@""]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:accessLogCode];
    }
}

- (void)selectedCategorylItem:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSUInteger childIndex = button.tag - currentExpandedIndex - 1;
    
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = app.homeViewController;
        
        NSString *link;
        if ([[categoryAreaDictionary[@"items"][currentExpandedIndex][@"subItems"][childIndex] allKeys] containsObject:@"link_v650"]) {
            link = categoryAreaDictionary[@"items"][currentExpandedIndex][@"subItems"][childIndex][@"link_v650"];
            
            if ([link hasPrefix:@"app://gocategory/"]) {
                link = [link stringByReplacingOccurrencesOfString:@"app://gocategory/" withString:@""];
                link = URLDecode(link);
            }
            
            CPCategoryDetailViewController *viewController = [[CPCategoryDetailViewController alloc] initWithUrl:link];
//            [homeViewController.navigationController popToRootViewControllerAnimated:NO];
            [homeViewController.navigationController pushViewController:viewController animated:NO];
        }
        else {
            link = categoryAreaDictionary[@"items"][currentExpandedIndex][@"subItems"][childIndex][@"link"];
            
            [homeViewController openWebViewControllerWithUrl:link animated:NO];
        }
    }];
    
    //AccessLog - 대카테고리
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGB0201"];
}

- (void)expandItemAtIndex:(NSInteger)index
{
	NSInteger insertPos = index + 1;
	NSMutableArray *indexPaths = [NSMutableArray new];
	NSArray *currentSubItems = categoryAreaDictionary[@"items"][index][@"subItems"];
    
	for (NSInteger i = 0; i < [currentSubItems count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:insertPos++ inSection:0]];
    }
    
	[categoryTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
	[self performSelector:@selector(didFinishAnimationExpand:) withObject:[NSIndexPath indexPathForRow:index inSection:0] afterDelay:0.1f];
    
    //AccessLog - 대카테고리 클릭
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"UMA0302"];
}

- (void)collapseSubItemsAtIndex:(NSInteger)index
{
    NSMutableArray *indexPaths = [NSMutableArray new];
	
    NSInteger subItemCount = [categoryAreaDictionary[@"items"][index][@"subItems"] count];
    for (NSInteger i = index + 1; i <= index + subItemCount; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
	
    [categoryTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
	[self performSelector:@selector(didFinishAnimationCollapse) withObject:nil afterDelay:0.1f];
}

- (void)didFinishAnimationCollapse
{
	for (UITableViewCell *cell in categoryTableView.visibleCells) {
		UIView *contentView = (UIView *)[cell.contentView viewWithTag:CELL_CONTENTVIEW_TAG];
		UIImageView *arrowImageView = (UIImageView *)[cell.contentView viewWithTag:DISCLOSURE_INDICATOR_TAG];
		
		[contentView setBackgroundColor:UIColorFromRGB(0xffffff)];
		[arrowImageView setImage:[UIImage imageNamed:@"btn_view_default_nor.png"]];
	}
}

- (void)didFinishAnimationExpand:(NSIndexPath *)indexPath
{
	[categoryTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
	
	UITableViewCell *cell = [categoryTableView cellForRowAtIndexPath:indexPath];
	UIView *contentView = (UIView *)[cell.contentView viewWithTag:CELL_CONTENTVIEW_TAG];
	UIImageView *arrowImageView = (UIImageView *)[cell.contentView viewWithTag:DISCLOSURE_INDICATOR_TAG];
	
	[contentView setBackgroundColor:UIColorFromRGB(0xffffff)];
	[arrowImageView setImage:[UIImage imageNamed:@"btn_view_on_nor.png"]];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [categoryAreaDictionary[@"items"] count] + ((currentExpandedIndex > -1) ? [categoryAreaDictionary[@"items"][currentExpandedIndex][@"subItems"] count] : 0);
            break;
        case 1:
            return [serviceAreaDictionary[@"items"] count] / 2 + [serviceAreaDictionary[@"items"] count] % 2;
            break;
        case 2:
        default:
            return 1;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            BOOL isChild = indexPath.section == 0 && currentExpandedIndex > -1 && indexPath.row > currentExpandedIndex && indexPath.row <= currentExpandedIndex + [categoryAreaDictionary[@"items"][currentExpandedIndex][@"subItems"] count];
            
            if (isChild) {
                return 40;
            }
            else {
                return 49;
            }
            break;
        }
        case 1:
            return 48;
            break;
        case 2:
        default:
            return 22+44+8+17+23;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        return 0;
    }
    else {
        return 60;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView *headerImageView;
    
    CGFloat rowHeight = [self tableView:tableView heightForHeaderInSection:section];
    
    if (section == 0 || section == 1) {
        headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(categoryTableView.frame), rowHeight)];
        [headerImageView setBackgroundColor:UIColorFromRGB(0xffffff)];
        [headerImageView setUserInteractionEnabled:YES];
        
        NSString *headerTitle = section == 0 ? [categoryAreaDictionary objectForKey:@"label"] : [serviceAreaDictionary objectForKey:@"label"];
        NSString *allServiceTitle = section == 0 ? [[categoryAreaDictionary objectForKey:@"menu"] objectForKey:@"text"] : [[serviceAreaDictionary objectForKey:@"menu"] objectForKey:@"text"];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [titleLabel setTextColor:UIColorFromRGB(0x6eb8ff)];
        [titleLabel setText:headerTitle];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel sizeToFit];
        [titleLabel setFrame:CGRectMake(6, 30, titleLabel.frame.size.width, titleLabel.frame.size.height)];
        [headerImageView addSubview:titleLabel];
        
        UIButton *allService = [UIButton buttonWithType:UIButtonTypeCustom];
        [allService setTag:section];
        [allService setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xd9d9d9)] forState:UIControlStateHighlighted];
        [allService.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [allService setTitle:allServiceTitle forState:UIControlStateNormal];
        [allService setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
        [allService sizeToFit];
        [allService setFrame:CGRectMake(CGRectGetWidth(headerImageView.frame) - (allService.frame.size.width-3+27), 28, allService.frame.size.width+25, allService.frame.size.height)];
        [allService addTarget:self action:@selector(selectedAllMenu:) forControlEvents:UIControlEventTouchUpInside];
        [allService setAccessibilityLabel:@"전체보기" Hint:@"전체보기로 이동합니다"];
        [headerImageView addSubview:allService];
        
        UIImage *arrow = [UIImage imageNamed:@"bar_btn_arrow.png"];
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:arrow];
        [arrowImageView setFrame:CGRectMake(CGRectGetWidth(allService.frame) - (arrow.size.width+6), CGRectGetHeight(allService.frame)/2-5, arrow.size.width, arrow.size.height)];
        [allService addSubview:arrowImageView];
        
        UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerImageView.frame)-4, CGRectGetWidth(headerImageView.frame), 4)];
        [lineImageView setImage:[UIImage imageNamed:@"sidemenu_titlebar_color.png"]];
        [headerImageView addSubview:lineImageView];
    }
	
	return headerImageView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *parentCellIdentifier = @"ParentCell";
	static NSString *childCellIdentifier = @"ChildCell";
	static NSString *restCellIdentifier = @"RestCell";
    
	CGFloat rowHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
	UITableViewCell *cell;
	
	if (indexPath.section == 0) {
		BOOL isChild = currentExpandedIndex > -1 && indexPath.row > currentExpandedIndex && indexPath.row <= currentExpandedIndex + [[[[categoryAreaDictionary objectForKey:@"items"] objectAtIndex:currentExpandedIndex] objectForKey:@"subItems"] count];
		
		if (isChild) {
            cell = [tableView dequeueReusableCellWithIdentifier:childCellIdentifier];
        }
		else {
            cell = [tableView dequeueReusableCellWithIdentifier:parentCellIdentifier];
        }
        
		if (!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:parentCellIdentifier];
		}
		
		for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
		
        // 서브카테고리
		if (isChild) {
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            // contetnView
			UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, rowHeight)];
			[contentView setBackgroundColor:UIColorFromRGB(0xfbfbfb)];
			[cell.contentView addSubview:contentView];
            
            
            // title
            NSString *title = [[[[[categoryAreaDictionary objectForKey:@"items"] objectAtIndex:currentExpandedIndex] objectForKey:@"subItems"] objectAtIndex:indexPath.row - currentExpandedIndex - 1] objectForKey:@"text"];
            
            //NSLog(@"sub title: %@, %i, %i, %i", title, indexPath.row, indexPath.row - currentExpandedIndex - 1, [[[[categoryAreaDictionary objectForKey:@"items"] objectAtIndex:currentExpandedIndex] objectForKey:@"subItems"] count]);
            
            CGFloat edgeLeft = 8;
            CGFloat fontSize = 12;
            if (kScreenBoundsWidth > 320) {
                edgeLeft = 12;
                fontSize = 14;
            }
            
            CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:fontSize]];
            
            UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [titleButton setFrame:CGRectMake(0, 0, tableView.frame.size.width, rowHeight)];
            [titleButton setImage:[UIImage imageNamed:@"categori_m01_nor.png"] forState:UIControlStateNormal];
            [titleButton setImage:[UIImage imageNamed:@"categori_m01_press.png"] forState:UIControlStateHighlighted];
            [titleButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xfbfbfb)] forState:UIControlStateHighlighted];
            [titleButton setTitle:title forState:UIControlStateNormal];
            [titleButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
            [titleButton setTitleColor:UIColorFromRGB(0x70a1ff) forState:UIControlStateHighlighted];
            [titleButton.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
            [titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, edgeLeft+7, 0, 0)];
            [titleButton setImageEdgeInsets:UIEdgeInsetsMake(0, edgeLeft, 0, 0)];
            [titleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [titleButton addTarget:self action:@selector(selectedCategorylItem:) forControlEvents:UIControlEventTouchUpInside];
            [titleButton setAccessibilityLabel:@"카테고리" Hint:@"해당 카테고리로 이동합니다"];
            [titleButton setTag:indexPath.row];
            [contentView addSubview:titleButton];
			
            // discount
            NSString *discountText = [[[[[categoryAreaDictionary objectForKey:@"items"] objectAtIndex:currentExpandedIndex] objectForKey:@"subItems"] objectAtIndex:indexPath.row - currentExpandedIndex - 1] objectForKey:@"disCountText"];
			if (discountText && ![[discountText trim] isEqualToString:@""]) {
                UIImage *tImage = [UIImage imageNamed:@"meta_ic_t_sale.png"];
                UIImageView *tImageView = [[UIImageView alloc] initWithImage:tImage];
                [tImageView setFrame:CGRectMake(edgeLeft + titleSize.width + 30, (rowHeight - tImage.size.height) / 2, tImage.size.width, tImage.size.height)];
                [contentView addSubview:tImageView];
                
				UILabel *discountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
				[discountLabel setTextColor:UIColorFromRGB(0xea0000)];
				[discountLabel setFont:[UIFont systemFontOfSize:11]];
				[discountLabel setBackgroundColor:[UIColor clearColor]];
				[discountLabel setText:discountText];
				[discountLabel sizeToFit];
				[discountLabel setFrame:CGRectMake(CGRectGetMaxX(tImageView.frame) + 3, 0, discountLabel.frame.size.width, discountLabel.frame.size.height)];
				[discountLabel setCenter:CGPointMake(discountLabel.center.x, tImageView.center.y)];
                [contentView addSubview:discountLabel];
			}
            
            // last object
            if (indexPath.row - currentExpandedIndex  == [[[[categoryAreaDictionary objectForKey:@"items"] objectAtIndex:currentExpandedIndex] objectForKey:@"subItems"] count]) {
                UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, rowHeight-1, contentView.frame.size.width, 1.0f)];
                [bottomLineView setBackgroundColor:UIColorFromRGB(0xe3e4ea)];
                [contentView addSubview:bottomLineView];
            }
		}
		else // 대카테고리
		{
            UIView *selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, rowHeight)];
            [selectionView setBackgroundColor:UIColorFromRGB(0xf2f3f8)];
			[cell setSelectedBackgroundView:selectionView];
            
			NSInteger topIndex = (currentExpandedIndex > -1 && indexPath.row > currentExpandedIndex) ? indexPath.row - [[[[categoryAreaDictionary objectForKey:@"items"] objectAtIndex:currentExpandedIndex] objectForKey:@"subItems"] count] : indexPath.row;
			
            // contentView
			UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, rowHeight)];
			[contentView setTag:CELL_CONTENTVIEW_TAG];
			[contentView setBackgroundColor:UIColorFromRGB(0xffffff)];
			[cell.contentView addSubview:contentView];
			
            NSString *iconUrl = categoryAreaDictionary[@"items"][topIndex] [@"iconUrl_v640"];
            iconUrl = [iconUrl stringByReplacingOccurrencesOfString:@".png" withString:@"@2x.png"];

            // icon
            CPThumbnailView *iconImageView = [[CPThumbnailView alloc] initWithFrame:CGRectMake(0, (rowHeight - 38) / 2, 38, 38)];
            [iconImageView setBackgroundColor:[UIColor clearColor]];
            [contentView addSubview:iconImageView];
            
            if ([iconUrl length] > 0) {
                [iconImageView.imageView sd_setImageWithURL:[NSURL URLWithString:iconUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
            }
            else {
                UIImage *iconImageNormal = [UIImage imageNamed:[NSString stringWithFormat:@"meta_ic_0%li_nor.png", topIndex+1]];
                [iconImageView.imageView setImage:iconImageNormal];
            }
            
            // arrow
            UIImage *arrowImage = currentExpandedIndex == indexPath.row ? [UIImage imageNamed:@"btn_view_on_nor.png"] : [UIImage imageNamed:@"btn_view_default_nor.png"];
            UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(contentView.frame) - arrowImage.size.width, (rowHeight - arrowImage.size.height) / 2, arrowImage.size.width, arrowImage.size.height)];
			[arrowImageView setImage:arrowImage];
			[arrowImageView setTag:DISCLOSURE_INDICATOR_TAG];
            [contentView addSubview:arrowImageView];
            
            // title
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
			[textLabel setTextColor:UIColorFromRGB(0x3d4050)];
			[textLabel setFont:[UIFont systemFontOfSize:15]];
			[textLabel setBackgroundColor:[UIColor clearColor]];
			[textLabel setText:[[[categoryAreaDictionary objectForKey:@"items"] objectAtIndex:topIndex] objectForKey:@"text"]];
			[textLabel sizeToFit];
			[textLabel setFrame:CGRectMake(CGRectGetMaxX(iconImageView.frame), 0, textLabel.frame.size.width, textLabel.frame.size.height)];
			[textLabel setCenter:CGPointMake(textLabel.center.x, iconImageView.center.y)];
            [contentView addSubview:textLabel];
            
            // discount
            NSString *discountText = [[[categoryAreaDictionary objectForKey:@"items"] objectAtIndex:topIndex] objectForKey:@"disCountText"];
            if (discountText && ![[discountText trim] isEqualToString:@""]) {
                UIImage *tImage = [UIImage imageNamed:@"icon_t.png"];
                UIImageView *tImageView = [[UIImageView alloc] initWithImage:tImage];
				[tImageView setFrame:CGRectMake(textLabel.frame.origin.x + textLabel.frame.size.width + 8, 0, tImage.size.width, tImage.size.height)];
				[tImageView setCenter:CGPointMake(tImageView.center.x, textLabel.center.y)];
                [contentView addSubview:tImageView];
				
                UILabel *discountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
				[discountLabel setTextColor:UIColorFromRGB(0xea0000)];
				[discountLabel setFont:[UIFont systemFontOfSize:11]];
				[discountLabel setBackgroundColor:[UIColor clearColor]];
				[discountLabel setText:discountText];
				[discountLabel sizeToFit];
				[discountLabel setFrame:CGRectMake(tImageView.frame.origin.x + tImageView.frame.size.width + 3.0f, 0, discountLabel.frame.size.width, discountLabel.frame.size.height)];
				[discountLabel setCenter:CGPointMake(discountLabel.center.x, tImageView.center.y)];
                [contentView addSubview:discountLabel];
			}
            
            UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, rowHeight-1, contentView.frame.size.width, 1.0f)];
			[bottomLineView setBackgroundColor:UIColorFromRGB(0xe3e4ea)];
            [contentView addSubview:bottomLineView];
		}
	}
	else
	{
		cell = [tableView dequeueReusableCellWithIdentifier:restCellIdentifier];
		
		if (!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:restCellIdentifier];
			
			UIView *selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, rowHeight)];
			[selectionView setBackgroundColor:UIColorFromRGB(0xf2f3f8)];
			[cell setSelectedBackgroundView:selectionView];
		}
		
		for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
		
        UIView *contentView;
        
        //푸터 메뉴
		if (indexPath.section == 2)
		{
            contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, rowHeight)];
            
            for (int i = 0; i < 4; i++) {
                UIImage *iconImageNormal = [UIImage imageNamed:[NSString stringWithFormat:@"blue_ic_0%i_nor.png", i+1]];
                UIImage *iconImageHighlighted = [UIImage imageNamed:[NSString stringWithFormat:@"blue_ic_0%i_press.png", i+1]];
                
                NSString *title;
                switch (i) {
                    case 0:
                        title = @"SOHO11";
                        break;
                    case 1:
                        title = @"도서";
                        break;
                    case 2:
                        title = @"마트11번가";
                        break;
                    case 3:
                    default:
                        title = @"기프티콘";
                        break;
                }
                
                CGFloat fontSize = 11;
//                if (kScreenBoundsWidth > 320) {
//                    fontSize = 13;
//                }
                
                UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [menuButton setFrame:CGRectMake((tableView.frame.size.width / 4 ) * i, 0, tableView.frame.size.width / 4, rowHeight)];
                [menuButton setBackgroundColor:UIColorFromRGB(0xffffff)];
                [menuButton setImage:iconImageNormal forState:UIControlStateNormal];
                [menuButton setImage:iconImageHighlighted forState:UIControlStateHighlighted];
                [menuButton setTitle:title forState:UIControlStateNormal];
				[menuButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
                [menuButton.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
				[menuButton addTarget:self action:@selector(selectedVerticalItem:) forControlEvents:UIControlEventTouchUpInside];
                [menuButton setTag:i];
                [menuButton setAccessibilityLabel:@"메뉴" Hint:@"메뉴로 이동합니다"];
                [contentView addSubview:menuButton];
                
                CGSize imageSize = iconImageNormal.size;
                CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:12]];
                CGFloat totalHeight = (imageSize.height + titleSize.height + 6);
                [menuButton setImageEdgeInsets:UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0, 0, - titleSize.width)];
                [menuButton setTitleEdgeInsets:UIEdgeInsetsMake(0, - imageSize.width, - (totalHeight - titleSize.height),0)];
            }
		}
		else //주요서비스
		{
            contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, rowHeight)];
            
            UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[leftButton setTag:indexPath.row * 2];
			[leftButton setBackgroundColor:UIColorFromRGB(0xffffff)];
			[leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 16, 0, 0)];
			[leftButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
			[leftButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xf2f3f8)] forState:UIControlStateHighlighted];
			[leftButton setTitleColor:UIColorFromRGB(0x3d4050) forState:UIControlStateNormal];
			[leftButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
			[leftButton addTarget:self action:@selector(selectedServiceItem:) forControlEvents:UIControlEventTouchUpInside];
			[leftButton setTitle:[[[serviceAreaDictionary objectForKey:@"items"] objectAtIndex:indexPath.row * 2] objectForKey:@"text"] forState:UIControlStateNormal];
			[leftButton setFrame:CGRectMake(0, 0, tableView.frame.size.width / 2 - 1.0f, rowHeight - 1.0f)];
            [leftButton setAccessibilityLabel:@"주요서비스" Hint:@"주요서비스로 이동합니다"];
            [contentView addSubview:leftButton];
			
            UIView *separateMiddleLine = [[UIView alloc] initWithFrame:CGRectZero];
			[separateMiddleLine setBackgroundColor:UIColorFromRGB(0xe3e4ea)];
			[separateMiddleLine setFrame:CGRectMake(leftButton.frame.size.width, (rowHeight-14)/2, 1, 14)];
            [contentView addSubview:separateMiddleLine];
			
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[rightButton setTag:indexPath.row * 2 + 1];
			[rightButton setBackgroundColor:UIColorFromRGB(0xffffff)];
			[rightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 16, 0, 0)];
			[rightButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
			[rightButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xf2f3f8)] forState:UIControlStateHighlighted];
			[rightButton setTitleColor:UIColorFromRGB(0x3d4050) forState:UIControlStateNormal];
			[rightButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
			[rightButton addTarget:self action:@selector(selectedServiceItem:) forControlEvents:UIControlEventTouchUpInside];
			[rightButton setTitle:[[[serviceAreaDictionary objectForKey:@"items"] objectAtIndex:indexPath.row * 2 + 1] objectForKey:@"text"] forState:UIControlStateNormal];
			[rightButton setFrame:CGRectMake(leftButton.frame.size.width + separateMiddleLine.frame.size.width, 0, tableView.frame.size.width / 2, rowHeight - 1.0f)];
            [rightButton setAccessibilityLabel:@"주요서비스" Hint:@"주요서비스로 이동합니다"];
            [contentView addSubview:rightButton];
			
            UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectZero];
            [bottomLine setFrame:CGRectMake(0, rowHeight - 1.0f, tableView.frame.size.width, 1.0f)];
			[bottomLine setBackgroundColor:UIColorFromRGB(0xe3e4ea)];
			[contentView addSubview:bottomLine];
		}
		
		[cell.contentView addSubview:contentView];
	}
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	if (indexPath.section == 0) {
		preExpandedIndex = currentExpandedIndex;
		
		[categoryTableView beginUpdates];
        
		if (currentExpandedIndex == indexPath.row) {
			[self collapseSubItemsAtIndex:currentExpandedIndex];
			
			isOpenChild = NO;
			currentExpandedIndex = -1;
		}
		else {
			BOOL shouldCollapse = currentExpandedIndex > -1;
			
			if (shouldCollapse) {
                [self collapseSubItemsAtIndex:currentExpandedIndex];
            }
			
			currentExpandedIndex = (shouldCollapse && indexPath.row > currentExpandedIndex) ? indexPath.row - [[[[categoryAreaDictionary objectForKey:@"items"] objectAtIndex:currentExpandedIndex] objectForKey:@"subItems"] count] : indexPath.row;
			
			[self expandItemAtIndex:currentExpandedIndex];
			
			isOpenChild = YES;
		}
        
		[categoryTableView endUpdates];
	}
}

#pragma mark - HttpRequest Delegate

- (void)request:(HttpRequest *)request didSuccessWithReceiveData:(NSString *)data
{
	if (request.targetObject) {
		@synchronized (request.targetObject) {
			if (!request.receivedData || ![request.response.MIMEType hasPrefix:@"image"]) {
				if ([request.response.URL.absoluteString isMatchedByRegex:RETINA_MATCH_REGEX]) {
					[request sendGet:[request.response.URL.absoluteString stringByReplacingOccurrencesOfRegex:RETINA_URL_REGEX withString:RETINA_REGEX_RESULT] data:nil];
				}
				
				return;
			}
			
			NSString *url = [request.response.URL.absoluteString stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
			NSData *imageData = [request.response.MIMEType hasPrefix:@"image"] ? request.receivedData : NULL;
			
			if (imageData) {
				UIImage *image = [UIImage imageWithCGImage:[[UIImage imageWithData:imageData] CGImage] scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
				[imageData writeToFile:[Modules storePath:url] atomically:YES];
				[(UIImageView *)request.targetObject setImage:image];
			}
		}
	}
}

- (void)request:(HttpRequest *)request didFailWithError:(NSError *)error
{
	//
}

@end