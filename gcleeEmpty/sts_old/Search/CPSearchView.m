//
//  CPSearchView.m
//  11st
//
//  Created by spearhead on 2014. 9. 30..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPSearchView.h"
#import "CPCommonInfo.h"
#import "AccessLog.h"

@interface CPSearchView() <UITableViewDataSource,
                           UITableViewDelegate,
                           UIAlertViewDelegate,
                           UIScrollViewDelegate>
{
    UITableView *contentsTableView;
    
    NSArray *tabContents;
    
    CPSearchType currentSearchType;
    NSInteger currentPageIndex;
    NSString *currentDate;
}
@end

@implementation CPSearchView

- (id)initWithFrame:(CGRect)frame tabContentsItems:(NSArray *)tabContentsItems searchType:(CPSearchType)searchType searchDate:(NSString *)searchDate pageIndex:(NSInteger)pageIndex
{
    self = [super initWithFrame:frame];
    if (self) {
        
        tabContents = tabContentsItems;
        currentSearchType = searchType;
        currentPageIndex = pageIndex;
        currentDate = searchDate;
        
        [self setBackgroundColor:UIColorFromRGB(0xf0f0f2)];
        
        [self loadContentView];
    }
    return self;
}

- (void)loadContentView
{
    for (UIView *subView in [self subviews]) {
        [subView removeFromSuperview];
    }
    
    if (tabContents.count > 0) {
        contentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))
                                                         style:UITableViewStylePlain];
        [contentsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [contentsTableView setBackgroundColor:UIColorFromRGB(0xf0f0f2)];
        [contentsTableView setDataSource:self];
        [contentsTableView setDelegate:self];
        [contentsTableView setScrollsToTop:NO];
        [contentsTableView setShowsVerticalScrollIndicator:NO];
        [self addSubview:contentsTableView];
        
        [self setTableFooterView];
    }
    else {
        NSString *noDataString;
        switch (currentSearchType) {
            case CPSearchTypeRise:
                noDataString = @"급상승 검색내역이 없습니다.";
                break;
            case CPSearchTypeHot:
                noDataString = @"인기 검색내역이 없습니다.";
                break;
            case CPSearchTypeRecent:
            default:
                noDataString = @"최근 검색내역이 없습니다.";
                break;
        }
        
        UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, CGRectGetWidth(self.frame)-16, 165)];
        [noDataLabel setBackgroundColor:UIColorFromRGB(0xf4f5f6)];
        [noDataLabel setFont:[UIFont systemFontOfSize:14]];
        [noDataLabel setText:noDataString];
        [noDataLabel setTextColor:UIColorFromRGB(0xd3d6db)];
        [noDataLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:noDataLabel];
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tabContents.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 43;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (currentSearchType) {
        case CPSearchTypeRecent:
            return [self configureRecentCell:tableView atIndexPath:indexPath];
        case CPSearchTypeRise:
            return [self configureRiseCell:tableView atIndexPath:indexPath];
        case CPSearchTypeHot:
        default:
            return [self configureHotCell:tableView atIndexPath:indexPath];
            break;
    }
}

- (UITableViewCell *)configureRecentCell:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"recentCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        UIView *selectionView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, CGRectGetWidth(tableView.frame)-16, 43)];
        [selectionView setBackgroundColor:UIColorFromRGB(0xdcd9de)];
        [cell setSelectedBackgroundView:selectionView];
    }
    
    if ([cell.contentView subviews]) {
        for (UIView *subView in [cell.contentView subviews]) {
            [subView removeFromSuperview];
        }
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    // 최근순서로 보여줌
    NSInteger index = tabContents.count-(indexPath.row+1);
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, CGRectGetWidth(tableView.frame)-16, 43)];
    [backgroundView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [cell.contentView addSubview:backgroundView];
    
    UILabel *keywordLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(backgroundView.frame)-66, 43)];
    [keywordLabel setBackgroundColor:[UIColor clearColor]];
    [keywordLabel setText:tabContents[index]];
    [keywordLabel setTextColor:UIColorFromRGB(0x333333)];
    [keywordLabel setFont:[UIFont systemFontOfSize:14]];
    [backgroundView addSubview:keywordLabel];
    
    UIButton *removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [removeButton setFrame:CGRectMake(CGRectGetWidth(backgroundView.frame)-50, 1.5f, 40, 40)];
    [removeButton setBackgroundColor:[UIColor clearColor]];
    [removeButton setImage:[UIImage imageNamed:@"search_btn_delete_nor.png"] forState:UIControlStateNormal];
    [removeButton setImage:[UIImage imageNamed:@"search_btn_delete_press.png"] forState:UIControlStateHighlighted];
    [removeButton addTarget:self action:@selector(touchRemoveButton:) forControlEvents:UIControlEventTouchUpInside];
    [removeButton setAccessibilityLabel:@"삭제" Hint:@"최근검색어를 삭제합니다"];
    [removeButton setTag:index];
    [backgroundView addSubview:removeButton];

    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 42, CGRectGetWidth(backgroundView.frame), 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0xe9eaed)];
    [backgroundView addSubview:lineView];
    
    return cell;
}

- (UITableViewCell *)configureRiseCell:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"riseCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if ([cell.contentView subviews]) {
        for (UIView *subView in [cell.contentView subviews]) {
            [subView removeFromSuperview];
        }
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSDictionary *keywordInfo = tabContents[indexPath.row];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, CGRectGetWidth(tableView.frame)-16, 43)];
    [backgroundView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [cell.contentView addSubview:backgroundView];
    
    NSInteger ranking = (indexPath.row + 1) + (currentPageIndex * 10);
    
    UIButton *rankingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rankingButton setFrame:CGRectMake(10, 14.5f, 16, 14)];
    [rankingButton setTitle:[NSString stringWithFormat:@"%li", (long)ranking] forState:UIControlStateNormal];
    [rankingButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [rankingButton.titleLabel setFont:[UIFont boldSystemFontOfSize:10]];
    [backgroundView addSubview:rankingButton];
    
    UILabel *keywordLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(rankingButton.frame)+8, 0, CGRectGetWidth(backgroundView.frame)-86, 43)];
    [keywordLabel setBackgroundColor:[UIColor clearColor]];
    [keywordLabel setText:keywordInfo[@"keyword"]];
    [keywordLabel setFont:[UIFont systemFontOfSize:14]];
    [backgroundView addSubview:keywordLabel];
    
    if (ranking < 4) {
        [rankingButton setBackgroundImage:[UIImage imageNamed:@"search_box_ranking_high.png"] forState:UIControlStateNormal];
        [keywordLabel setTextColor:UIColorFromRGB(0xe91e3b)];
    }
    else {
        [rankingButton setBackgroundImage:[UIImage imageNamed:@"search_box_ranking_low.png"] forState:UIControlStateNormal];
        [keywordLabel setTextColor:UIColorFromRGB(0x333333)];
    }
    
    NSString *rankOrderString = keywordInfo[@"searchRankOrder"];
    
    if (rankOrderString) {
        rankOrderString = [rankOrderString lowercaseString];
        rankOrderString = [rankOrderString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    
    UIButton *updownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [updownButton setFrame:CGRectMake(CGRectGetWidth(backgroundView.frame)-58, 0, 50, 43)];
    [updownButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [backgroundView addSubview:updownButton];
    
    if ([rankOrderString isEqualToString:@"new"]) {
        [updownButton setImage:nil forState:UIControlStateNormal];
        [updownButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [updownButton setTitleColor:UIColorFromRGB(0xe91e3b) forState:UIControlStateNormal];
        [updownButton setTitle:rankOrderString forState:UIControlStateNormal];
    }
    else {
        NSInteger rankOrder = [rankOrderString integerValue];
        
        if (rankOrder == 0) {
            [updownButton setImage:[UIImage imageNamed:@"search_icon_ranking_nochange.png"] forState:UIControlStateNormal];
        }
        else if (rankOrder > 0) {
            [updownButton setImage:[UIImage imageNamed:@"search_icon_ranking_increase.png"] forState:UIControlStateNormal];
        }
        else if (rankOrder < 0) {
            [updownButton setImage:[UIImage imageNamed:@"search_icon_ranking_decrease.png"] forState:UIControlStateNormal];
        }
        
        [updownButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [updownButton setTitleColor:UIColorFromRGB(0xabb0b9) forState:UIControlStateNormal];
        [updownButton setTitle:rankOrderString forState:UIControlStateNormal];
        [updownButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 0)];
        
        CGSize size = [[updownButton titleForState:UIControlStateNormal] sizeWithFont:updownButton.titleLabel.font];
        [updownButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [updownButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -size.width)];
        [updownButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, updownButton.imageView.image.size.width + 5)];
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 42, CGRectGetWidth(backgroundView.frame), 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0xe9eaed)];
    [backgroundView addSubview:lineView];
    
    return cell;
}

- (UITableViewCell *)configureHotCell:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"hotCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if ([cell.contentView subviews]) {
        for (UIView *subView in [cell.contentView subviews]) {
            [subView removeFromSuperview];
        }
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSDictionary *keywordInfo = tabContents[indexPath.row];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, CGRectGetWidth(tableView.frame)-16, 43)];
    [backgroundView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [cell.contentView addSubview:backgroundView];
    
    UIButton *rankingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rankingButton setFrame:CGRectMake(10, 14.5f, 16, 14)];
    [rankingButton setTitle:[NSString stringWithFormat:@"%li", (indexPath.row+1)] forState:UIControlStateNormal];
    [rankingButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [rankingButton.titleLabel setFont:[UIFont boldSystemFontOfSize:10]];
    [backgroundView addSubview:rankingButton];
    
    UILabel *keywordLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(rankingButton.frame)+8, 0, CGRectGetWidth(backgroundView.frame)-86, 43)];
    [keywordLabel setBackgroundColor:[UIColor clearColor]];
    [keywordLabel setText:keywordInfo[@"keyword"]];
    [keywordLabel setFont:[UIFont systemFontOfSize:14]];
    [backgroundView addSubview:keywordLabel];
    
    if (indexPath.row < 3) {
        [rankingButton setBackgroundImage:[UIImage imageNamed:@"search_box_ranking_high.png"] forState:UIControlStateNormal];
        [keywordLabel setTextColor:UIColorFromRGB(0xe91e3b)];
    }
    else {
        [rankingButton setBackgroundImage:[UIImage imageNamed:@"search_box_ranking_low.png"] forState:UIControlStateNormal];
        [keywordLabel setTextColor:UIColorFromRGB(0x333333)];
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 42, CGRectGetWidth(backgroundView.frame), 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0xe9eaed)];
    [backgroundView addSubview:lineView];
    
    return cell;
}

- (void)setTableFooterView
{
    UIView *footrView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 63)];
    [footrView setBackgroundColor:[UIColor clearColor]];
    
    switch (currentSearchType) {
        case CPSearchTypeRecent:
        {
            UIButton *removeAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [removeAllButton setFrame:CGRectMake(5, 10, 80, 14)];
            [removeAllButton setBackgroundColor:[UIColor clearColor]];
            [removeAllButton setImage:[UIImage imageNamed:@"search_icon_trash.png"] forState:UIControlStateNormal];
            [removeAllButton setTitle:@"전체삭제" forState:UIControlStateNormal];
            [removeAllButton setTitleColor:UIColorFromRGB(0x808793) forState:UIControlStateNormal];
            [removeAllButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [removeAllButton addTarget:self action:@selector(touchRemoveAllButton) forControlEvents:UIControlEventTouchUpInside];
            [removeAllButton setAccessibilityLabel:@"전체삭제" Hint:@"최근검색어를 전체 삭제합니다"];
            [footrView addSubview:removeAllButton];
            
            CGSize size = [[removeAllButton titleForState:UIControlStateNormal] sizeWithFont:removeAllButton.titleLabel.font];
            [removeAllButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            [removeAllButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -size.width)];
            [removeAllButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, removeAllButton.imageView.image.size.width + 5)];
            
            break;
        }
        case CPSearchTypeRise:
        case CPSearchTypeHot:
        default:
        {
            UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 10, 200, 12)];
            [dateLabel setBackgroundColor:[UIColor clearColor]];
            [dateLabel setText:currentDate];
            [dateLabel setFont:[UIFont systemFontOfSize:12]];
            [dateLabel setTextColor:UIColorFromRGB(0x979da6)];
            [footrView addSubview:dateLabel];
            
            break;
        }
    }
    
    [contentsTableView setTableFooterView:footrView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *keyword;
    
    switch (currentSearchType) {
        case CPSearchTypeRecent:
        {
            NSInteger index = tabContents.count-(indexPath.row+1);
            keyword = tabContents[index];
            
            //AccessLog - 최근검색어 선택
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRB03"];
            
            break;
        }
        case CPSearchTypeRise:
        {
            NSDictionary *keywordInfo = tabContents[indexPath.row];
            keyword= keywordInfo[@"keyword"];
            
            //AccessLog - 급상승 검색어 선택
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRB11"];
            
            break;
        }
        case CPSearchTypeHot:
        default:
        {
            NSDictionary *keywordInfo = tabContents[indexPath.row];
            keyword= keywordInfo[@"keyword"];
            
            //AccessLog - 인기 검색어 선택
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRB05"];
            
            break;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(didTouchKeyword:)]) {
        [self.delegate didTouchKeyword:keyword];
    }
}

#pragma mark - Selectos

- (void)touchRemoveButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (currentSearchType == CPSearchTypeRecent) {
        [CPCommonInfo removeRecentSearchItems:button.tag];
        
        tabContents = [[CPCommonInfo sharedInfo] recentSearchItems];
        
        [self loadContentView];
        
        //AccessLog - 최근검색어 개별 삭제 버튼 클릭
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRB12"];
    }
}

- (void)touchRemoveAllButton
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"최근 검색어를 모두 삭제하시겠습니까?"
                                                   delegate:self
                                          cancelButtonTitle:@"취소"
                                          otherButtonTitles:@"승인", nil];
    [alert setDelegate:self];
    [alert show];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [CPCommonInfo removeAllRecentSearchItems];
        
        tabContents = [[CPCommonInfo sharedInfo] recentSearchItems];
        
        [self loadContentView];
        
        //AccessLog - 최근검색어 전체 삭제 버튼 클릭
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRB13"];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(didScrollViewWillBeginDragging)]) {
        [self.delegate didScrollViewWillBeginDragging];
    }
}

@end
