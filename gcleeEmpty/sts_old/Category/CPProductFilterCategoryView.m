//
//  CPProductFilterCategoryView.m
//  11st
//
//  Created by spearhead on 2015. 6. 4..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductFilterCategoryView.h"
#import "CPLoadingView.h"
#import "CPString+Formatter.h"
#import "AccessLog.h"

@interface CPProductFilterCategoryView() <UITableViewDataSource,
                                          UITableViewDelegate>
{
    NSMutableDictionary *categoryInfo;
    
    UITableView *categoryTableView;
    CPLoadingView *loadingView;
    
    NSInteger preExpandedIndex;
    
    BOOL isOpenChild;
    BOOL isNoData;
    BOOL existAllCategoryCell;
    
    NSInteger hierarchyCount;
    NSInteger itemCount;
    NSInteger headerLineCount;
    
    CGFloat rowCount;
    NSString *listingType;
}

@end

@implementation CPProductFilterCategoryView

- (id)initWithFrame:(CGRect)frame categoryInfo:(NSMutableDictionary *)aCategoryInfo listingType:(NSString *)aListingType
{
    self = [super initWithFrame:frame];
    if (self) {
        
        categoryInfo = aCategoryInfo;
        hierarchyCount = [categoryInfo[@"hierarchy"] count];
        itemCount = [categoryInfo[@"items"] count];
        isNoData = NO;
        listingType = aListingType;
        //검색으로 진입 시 '전체'가 없어야 함
        existAllCategoryCell = [[categoryInfo[@"hierarchy"][0] objectForKey:@"dispCtgrNm"] isEqualToString:@"전체"];
        
        rowCount = hierarchyCount + itemCount;
        
        //Layout
        [self initLayout];
    }
    return self;
}

- (void)initLayout
{
    //카테고리 테이블뷰
    categoryTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) style:UITableViewStyleGrouped];
    [categoryTableView setDelegate:self];
    [categoryTableView setDataSource:self];
    [categoryTableView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [categoryTableView setSeparatorColor:[UIColor clearColor]];
    [categoryTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self addSubview:categoryTableView];
    
    UIView* backgroundView = [[UIView alloc] init];
    [backgroundView setBackgroundColor:[UIColor whiteColor]];
    [categoryTableView setBackgroundView:backgroundView];
    
    //LoadingView
    loadingView = [[CPLoadingView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame)-50)/2-40,
                                                                  CGRectGetHeight(self.frame)/2-40,
                                                                  80,
                                                                  80)];
    [self addSubview:loadingView];
    [self stopLoadingAnimation];
}

#pragma mark - Selectors

- (void)refreshData:(NSMutableDictionary *)searchMetaInfo;
{
    categoryInfo = [searchMetaInfo[@"category"] mutableCopy];
    
    hierarchyCount = [categoryInfo[@"hierarchy"] count];
    itemCount = [categoryInfo[@"items"] count];
    
    rowCount = hierarchyCount + itemCount;
    isNoData = NO;
    
    [categoryTableView reloadData];
    [self stopLoadingAnimation];
}

- (void)touchMainCategoryDepthArea:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSString *url = [[[categoryInfo objectForKey:@"hierarchy"] objectAtIndex:button.tag] objectForKey:@"url"];
    
    [self startLoadingAnimation];
    if ([self.delegate respondsToSelector:@selector(didTouchCategoryButton:)]) {
        [self.delegate didTouchCategoryButton:url];
    }
    
    //AccessLog - 상단 depth 터치 시
    if ([listingType isEqualToString:@"search"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB02"];
    }
    else if ([listingType isEqualToString:@"category"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB02"];
    }
    else if ([listingType isEqualToString:@"model"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPB02"];
    }
}

- (void)touchMainCategoryCell:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSString *url = [[[categoryInfo objectForKey:@"hierarchy"] objectAtIndex:button.tag] objectForKey:@"url"];
    
    [self startLoadingAnimation];
    if ([self.delegate respondsToSelector:@selector(didTouchCategoryButton:)]) {
        [self.delegate didTouchCategoryButton:url];
    }
    
    //AccessLog - 카테고리리스트 터치 시
    if ([listingType isEqualToString:@"search"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB03"];
    }
    else if ([listingType isEqualToString:@"category"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB03"];
    }
    else if ([listingType isEqualToString:@"model"]) {
        
    }
}

- (void)touchSubCategoryCell:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSString *url = [[[categoryInfo objectForKey:@"items"] objectAtIndex:button.tag] objectForKey:@"url"];
    
    [self startLoadingAnimation];
    if ([self.delegate respondsToSelector:@selector(didTouchCategoryButton:)]) {
        [self.delegate didTouchCategoryButton:url];
    }
    
    //AccessLog - 카테고리리스트 터치 시
    if ([listingType isEqualToString:@"search"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB03"];
    }
    else if ([listingType isEqualToString:@"category"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB03"];
    }
    else if ([listingType isEqualToString:@"model"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPB03"];
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    CGFloat arrowWidth = 26;
//    CGFloat cellWidtgh = CGRectGetWidth(self.frame)-20;
//    CGFloat size = 0;
//    headerLineCount = 1;
//    
//    for (int i = 0; i < hierarchyCount; i++) {
//        NSDictionary *dic = [categoryInfo objectForKey:@"hierarchy"][i];
//        
//        CGSize labelSize = [[dic objectForKey:@"dispCtgrNm"] sizeWithFont:[UIFont systemFontOfSize:14]];
//        size += labelSize.width;
//        
//        if (size >= cellWidtgh) {
//            size = 0;
//            headerLineCount++;
//            size += labelSize.width;
//        }
//        
//        //arrow
//        size += arrowWidth;
//        
//        if (size >= cellWidtgh) {
//            size = 0;
//            headerLineCount++;
//            size += arrowWidth;
//        }
//    }
//    
//    return 43+(headerLineCount-1)*30;
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    rowCount = hierarchyCount + itemCount;
    
    if (rowCount > 0) {
        //leafCtgrY 일 경우 hierarchy의 마지막 셀 삭제
        if ([[categoryInfo objectForKey:@"leafCtgrYN"] isEqualToString:@"Y"]) {
            rowCount--;
        }
        if (existAllCategoryCell) {
            rowCount--;
        }
    }
    else {
        rowCount = 1;
        isNoData= YES;
    }
    
    return rowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight;
    if (rowCount > 0) {
        rowHeight = 48;
    }
    else {
        rowHeight = 150;
    }
    
    return rowHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame)-10, 43+(headerLineCount-1)*30)];
//    [headerView setBackgroundColor:[UIColor whiteColor]];
//    
//    CGFloat cellWidtgh = CGRectGetWidth(self.frame)-10;
//    NSInteger viewSizeWidth = 5;
//    NSInteger lineCount = 1;
//    
//    if (hierarchyCount == 1 && [[categoryInfo[@"hierarchy"][0] objectForKey:@"dispCtgrNm"] isEqualToString:@"전체"]) {
//        NSInteger ctgrCount = [[[categoryInfo objectForKey:@"hierarchy"][0] objectForKey:@"ctgrCount"] integerValue];
//        NSString *labelTitle = [NSString stringWithFormat:@"전체 (%ld개 카테고리)", (long)ctgrCount];
//        CGSize buttonLabelSize = [labelTitle sizeWithFont:[UIFont systemFontOfSize:14]];
//        
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 9, buttonLabelSize.width, 23)];
//        [label setBackgroundColor:[UIColor clearColor]];
//        [label setText:labelTitle];
//        [label setTextColor:UIColorFromRGB(0x222222)];
//        [label setFont:[UIFont systemFontOfSize:14]];
//        [headerView addSubview:label];
//    }
//    else {
//        for (int i = 0; i < hierarchyCount; i++) {
//            
//            NSDictionary *dic = [categoryInfo objectForKey:@"hierarchy"][i];
//            CGSize buttonLabelSize = [[dic objectForKey:@"dispCtgrNm"] sizeWithFont:[UIFont systemFontOfSize:14]];
//            
//            //버튼
//            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//            [button setFrame:CGRectMake(viewSizeWidth, 10+(lineCount-1)*31, buttonLabelSize.width+20, 23)];
//            [button setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xededf2)] forState:UIControlStateHighlighted];
//            [button setTitle:[dic objectForKey:@"dispCtgrNm"] forState:UIControlStateNormal];
//            [button setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
//            [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
//            [button addTarget:self action:@selector(touchMainCategoryCell:) forControlEvents:UIControlEventTouchUpInside];
//            [button setTag:[[categoryInfo objectForKey:@"hierarchy"] indexOfObject:dic]];
//            [headerView addSubview:button];
//            
//            viewSizeWidth += button.frame.size.width;
//            if (viewSizeWidth >= cellWidtgh) {
//                viewSizeWidth = 5;
//                lineCount++;
//                
//                [button setFrame:CGRectMake(viewSizeWidth, 10+(lineCount-1)*31, buttonLabelSize.width+20, 23)];
//                viewSizeWidth += button.frame.size.width;
//            }
//            
//            //마지막
//            if ([dic isEqualToDictionary:[[categoryInfo objectForKey:@"hierarchy"] lastObject]]) {
//                [button.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
//                break;
//            }
//            
//            //arrow
//            UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(viewSizeWidth, 16+(lineCount-1)*31, 6, 10)];
//            [arrowImageView setImage:[UIImage imageNamed:@"ic_s_arrow_right.png"]];
//            [headerView addSubview:arrowImageView];
//            
//            viewSizeWidth += arrowImageView.frame.size.width;
//            if (viewSizeWidth >= cellWidtgh) {
//                viewSizeWidth = 15;
//                lineCount++;
//                
//                [arrowImageView setFrame:CGRectMake(viewSizeWidth, 16+(lineCount-1)*31, 6, 10)];
//                viewSizeWidth += arrowImageView.frame.size.width;
//            }
//        }
//    }
//    
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerView.frame)-1, CGRectGetWidth(self.frame), 1)];
//    [lineView setBackgroundColor:UIColorFromRGB(0xc2c5e4)];
//    [headerView addSubview:lineView];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame)-10, 44)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    NSInteger viewSizeWidth = 8;
    
    if ((hierarchyCount-1) == 0 && [[[categoryInfo objectForKey:@"hierarchy"][0] objectForKey:@"dispCtgrLevel"] integerValue] == 0) {
        NSInteger ctgrCount = [[[categoryInfo objectForKey:@"hierarchy"][0] objectForKey:@"ctgrCount"] integerValue];
        NSString *labelTitle = [NSString stringWithFormat:@"전체 (%ld개 카테고리)", (long)ctgrCount];
        CGSize buttonLabelSize = [labelTitle sizeWithFont:[UIFont systemFontOfSize:14]];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 9, buttonLabelSize.width, 23)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setText:labelTitle];
        [label setTextColor:UIColorFromRGB(0x222222)];
        [label setFont:[UIFont systemFontOfSize:14]];
        [headerView addSubview:label];
    }
    else {
        
        for (int i = 0; i < hierarchyCount; i++) {
            
            NSDictionary *dic = [categoryInfo objectForKey:@"hierarchy"][i];
            
            //버튼
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(viewSizeWidth, 13, 40, 18)];
            [button setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xededf2)] forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(touchMainCategoryDepthArea:) forControlEvents:UIControlEventTouchUpInside];
            [button setTag:[[categoryInfo objectForKey:@"hierarchy"] indexOfObject:dic]];
            [headerView addSubview:button];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 36, 18)];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setText:[dic objectForKey:@"dispCtgrNm"]];
            [label setTextColor:UIColorFromRGB(0x333333)];
            [label setFont:[UIFont systemFontOfSize:12]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [button addSubview:label];
            
            viewSizeWidth += button.frame.size.width;
            
            //마지막
            if ([dic isEqualToDictionary:[[categoryInfo objectForKey:@"hierarchy"] lastObject]]) {
                
                CGFloat buttonLastWidth = CGRectGetWidth(self.frame)-CGRectGetMinX(button.frame);
                
                [button setFrame:CGRectMake(CGRectGetMinX(button.frame), 13, buttonLastWidth, 18)];
                [label setFrame:CGRectMake(2, 0, buttonLastWidth-4, 18)];
                [label setTextAlignment:NSTextAlignmentLeft];
                [label setFont:[UIFont boldSystemFontOfSize:12]];
                
                break;
            }
            
            //arrow
            UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(viewSizeWidth, 17, 6, 10)];
            [arrowImageView setImage:[UIImage imageNamed:@"ic_s_arrow_right.png"]];
            [headerView addSubview:arrowImageView];
            
            viewSizeWidth += arrowImageView.frame.size.width;
        }
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, CGRectGetWidth(self.frame), 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0xc2c5e4)];
    [headerView addSubview:lineView];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *parentCellIdentifier = @"ParentCell";
    static NSString *childCellIdentifier = @"ChildCell";
    
    CGFloat rowHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    UITableViewCell *cell;
    
    BOOL isChild = (hierarchyCount-1) <= indexPath.row;
    NSInteger isLeafCategoryValue = [[categoryInfo objectForKey:@"leafCtgrYN"] isEqualToString:@"Y"];
    
    if (isChild) {
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:childCellIdentifier];
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:childCellIdentifier];
        }
    }
    else {
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:parentCellIdentifier];
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:parentCellIdentifier];
        }
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    [cell setBackgroundColor:UIColorFromRGB(0xffffff)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (!isNoData) {
        // 서브카테고리
        if (hierarchyCount-isLeafCategoryValue-existAllCategoryCell <= indexPath.row) {
            // contetnView
            UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake([SYSTEM_VERSION intValue] < 7 ? -10 : 0, 0, tableView.frame.size.width, rowHeight)];
            [contentView setBackgroundColor:UIColorFromRGB(0xffffff)];
            [cell.contentView addSubview:contentView];
            
            NSInteger cellIndex = indexPath.row-(hierarchyCount-isLeafCategoryValue-existAllCategoryCell);
            
            // title
            NSString *title = [[[categoryInfo objectForKey:@"items"] objectAtIndex:cellIndex] objectForKey:@"dispCtgrNm"];
            
            CGFloat edgeLeft = 10*(hierarchyCount+1-isLeafCategoryValue-existAllCategoryCell);
            
            if ((hierarchyCount-isLeafCategoryValue-existAllCategoryCell) == 0) {
                edgeLeft = 15;
            }
            
            UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [titleButton setFrame:CGRectMake(0, 0, tableView.frame.size.width, rowHeight)];
            [titleButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xededf2)] forState:UIControlStateHighlighted];
            [titleButton setTitle:title forState:UIControlStateNormal];
            [titleButton setTitleColor:UIColorFromRGB(0x1e1e1e) forState:UIControlStateNormal];
            [titleButton setTitleColor:UIColorFromRGB(0x5161ff) forState:UIControlStateHighlighted];
            [titleButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, edgeLeft, 0, 0)];
            [titleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [titleButton addTarget:self action:@selector(touchSubCategoryCell:) forControlEvents:UIControlEventTouchUpInside];
            [titleButton setAccessibilityLabel:@"카테고리" Hint:@"해당 카테고리로 이동합니다"];
            [titleButton setTag:indexPath.row-(hierarchyCount-isLeafCategoryValue-existAllCategoryCell)];
            [contentView addSubview:titleButton];
            
            if ([[[[categoryInfo objectForKey:@"items"] objectAtIndex:cellIndex] objectForKey:@"selectedYN"] isEqualToString:@"Y"]) {
                [titleButton setTitleColor:UIColorFromRGB(0x5e6dff) forState:UIControlStateNormal];
            }
            
            if ((hierarchyCount-isLeafCategoryValue-existAllCategoryCell) != 0) {
                [titleButton setImage:[UIImage imageNamed:@"ic_c_lowlist_nor.png"] forState:UIControlStateNormal];
                [titleButton setImage:[UIImage imageNamed:@"ic_c_lowlist_press.png"] forState:UIControlStateHighlighted];
                [titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, edgeLeft+8, 0, 0)];
                [titleButton setImageEdgeInsets:UIEdgeInsetsMake(0, edgeLeft, 0, 0)];
            }
            
            
            // arrow
            if ([[categoryInfo objectForKey:@"hierarchy"] count] < 4 && ![[[[categoryInfo objectForKey:@"items"] objectAtIndex:cellIndex] objectForKey:@"ctgrLeafYN"] isEqualToString:@"Y"]) {
                UIImage *arrowImage = [[[[categoryInfo objectForKey:@"items"] objectAtIndex:cellIndex] objectForKey:@"selectedYN"] isEqualToString:@"Y"] ? [UIImage imageNamed:@"bt_s_arrow_down_press.png"] : [UIImage imageNamed:@"bt_s_arrow_down_nor.png"];
                UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(contentView.frame)-arrowImage.size.width-15, (rowHeight - arrowImage.size.height) / 2, arrowImage.size.width, arrowImage.size.height)];
                [arrowImageView setImage:arrowImage];
                [contentView addSubview:arrowImageView];
            }
            
            
            // discount
            NSString *countText = [[[categoryInfo objectForKey:@"items"] objectAtIndex:cellIndex] objectForKey:@"prdCount"];
            if (![countText isEqual:@"0"]) {
                CGFloat labelX = 10+10*(hierarchyCount-isLeafCategoryValue-existAllCategoryCell)+[title sizeWithFont:[UIFont systemFontOfSize:14]].width;
                
                if ((hierarchyCount-isLeafCategoryValue-existAllCategoryCell) != 0) {
                    labelX += 15;
                }
                
                UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                [countLabel setTextColor:UIColorFromRGB(0x999999)];
                [countLabel setFont:[UIFont systemFontOfSize:11]];
                [countLabel setBackgroundColor:[UIColor clearColor]];
                [countLabel setText:[countText formatThousandComma]];
                [countLabel sizeToFit];
                [countLabel setFrame:CGRectMake(labelX+8, 0, countLabel.frame.size.width, CGRectGetHeight(contentView.frame))];
                [contentView addSubview:countLabel];
            }
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(titleButton.frame)-1, kScreenBoundsWidth-20, 1)];
            [lineView setBackgroundColor:UIColorFromRGB(0xdddde1)];
            [contentView addSubview:lineView];
        }
        else // 대카테고리
        {
            // contetnView
            UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, rowHeight)];
            [contentView setBackgroundColor:UIColorFromRGB(0xf7f7f7)];
            [cell.contentView addSubview:contentView];
            
            // title
            NSString *title = [[[categoryInfo objectForKey:@"hierarchy"] objectAtIndex:indexPath.row+existAllCategoryCell] objectForKey:@"dispCtgrNm"];
            
            CGFloat edgeLeft = 15+10*indexPath.row;
            
            UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [titleButton setFrame:CGRectMake(0, 0, tableView.frame.size.width, rowHeight)];
            [titleButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xededf2)] forState:UIControlStateHighlighted];
            [titleButton setTitle:title forState:UIControlStateNormal];
            [titleButton setTitleColor:UIColorFromRGB(0x1e1e1e) forState:UIControlStateNormal];
            [titleButton setTitleColor:UIColorFromRGB(0x5161ff) forState:UIControlStateHighlighted];
            [titleButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, edgeLeft, 0, 0)];
            [titleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [titleButton addTarget:self action:@selector(touchMainCategoryCell:) forControlEvents:UIControlEventTouchUpInside];
            [titleButton setAccessibilityLabel:@"카테고리" Hint:@"해당 카테고리로 이동합니다"];
            [titleButton setTag:indexPath.row+existAllCategoryCell];
            [contentView addSubview:titleButton];
            
            BOOL isLastCellSelected = ([[categoryInfo objectForKey:@"hierarchy"] count]-1-existAllCategoryCell == indexPath.row) && ![[categoryInfo objectForKey:@"leafCtgrYN"] isEqualToString:@"Y"];
            
            if (isLastCellSelected) {
                [titleButton setTitleColor:UIColorFromRGB(0x5e6dff) forState:UIControlStateNormal];
                [contentView setBackgroundColor:UIColorFromRGB(0xdfe3ff)];
            }
            
            // arrow
            UIImage *arrowImage = isLastCellSelected ? [UIImage imageNamed:@"bt_s_arrow_down_press.png"] : [UIImage imageNamed:@"bt_s_arrow_down_nor.png"];
            UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(contentView.frame)-arrowImage.size.width-15, (rowHeight - arrowImage.size.height) / 2, arrowImage.size.width, arrowImage.size.height)];
            [arrowImageView setImage:arrowImage];
            [contentView addSubview:arrowImageView];
            
            
//            // discount
//            NSInteger countText = [[[[categoryInfo objectForKey:@"hierarchy"] objectAtIndex:indexPath.row+1] objectForKey:@"ctgrCount"] integerValue];
//            CGFloat labelX = 10*(indexPath.row+1)+[title sizeWithFont:[UIFont systemFontOfSize:14]].width;
//            
//            UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//            [countLabel setTextColor:UIColorFromRGB(0x999999)];
//            [countLabel setFont:[UIFont systemFontOfSize:11]];
//            [countLabel setBackgroundColor:[UIColor clearColor]];
//            [countLabel setText:[[NSString stringWithFormat:@"%ld", (long)countText] formatThousandComma]];
//            [countLabel sizeToFit];
//            [countLabel setFrame:CGRectMake(labelX+8, 0, countLabel.frame.size.width, CGRectGetHeight(contentView.frame))];
//            [contentView addSubview:countLabel];
            
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(titleButton.frame)-1, kScreenBoundsWidth-20, 1)];
            [lineView setBackgroundColor:UIColorFromRGB(0xd4d8ef)];
            [contentView addSubview:lineView];
        }
    }
    else {
        
        // contentView
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, rowHeight)];
        [contentView setBackgroundColor:UIColorFromRGB(0xffffff)];
        [cell.contentView addSubview:contentView];
        
        UIImageView *noDataImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(contentView.frame)/2-25, 50, 50, 50)];
        [noDataImageView setImage:[UIImage imageNamed:@"ic_s_notice.png"]];
        [contentView addSubview:noDataImageView];
        
        UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(noDataImageView.frame)+15, CGRectGetWidth(contentView.frame), 40)];
        [noDataLabel setText:@"고객님이 입력하신 검색어에 대한 \n카테고리 결과값이 없습니다."];
        [noDataLabel setTextColor:UIColorFromRGB(0x666666)];
        [noDataLabel setTextAlignment:NSTextAlignmentCenter];
        [noDataLabel setFont:[UIFont systemFontOfSize:15]];
        [noDataLabel setNumberOfLines:0];
        [contentView addSubview:noDataLabel];
    }
    
    return cell;
}

#pragma mark - CPLoadingView

- (void)startLoadingAnimation
{
    [self insertSubview:loadingView aboveSubview:self];
    [loadingView startAnimation];
}

- (void)stopLoadingAnimation
{
    [loadingView stopAnimation];
    [loadingView removeFromSuperview];
}

@end
