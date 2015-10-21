//
//  CPProductFilterPartnerView.m
//  11st
//
//  Created by spearhead on 2015. 6. 4..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductFilterPartnerView.h"
#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"
#import "AccessLog.h"

#define CELL_CHECKBOX_TAG           300

@interface CPProductFilterPartnerView() <UITableViewDelegate,
                                         UITableViewDataSource>
{
    NSMutableDictionary *partnerInfo;
    
    UITableView *partnerTableView;
    
    NSMutableArray *checkedItems;
    
    NSInteger itemCount;
    NSString *listingType;
}

@end

@implementation CPProductFilterPartnerView

- (id)initWithFrame:(CGRect)frame partnerInfo:(NSMutableDictionary *)aPartnerInfo listingType:(NSString *)aListingType
{
    self = [super initWithFrame:frame];
    if (self) {
        
        partnerInfo = aPartnerInfo;
        itemCount = [partnerInfo[@"items"] count];
        listingType = aListingType;
        
        checkedItems = [NSMutableArray array];
        
        if (itemCount > 0) {
            for (NSDictionary *partner in partnerInfo[@"items"]) {
                if ([[partner allKeys] containsObject:@"selectedYN"]) {
                    if ([partner[@"selectedYN"] isEqualToString:@"Y"]) {
                        [checkedItems addObject:[partner[@"sellerNo"] stringValue]];
                    }
                }
            }
        }
        
        //Layout
        [self initLayout];
        
    }
    return self;
}

- (void)initLayout
{
    //파트너스 테이블뷰
    partnerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) style:UITableViewStyleGrouped];
    [partnerTableView setDelegate:self];
    [partnerTableView setDataSource:self];
    [partnerTableView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [partnerTableView setSeparatorColor:[UIColor clearColor]];
    [partnerTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self addSubview:partnerTableView];
    
    UIView* backgroundView = [[UIView alloc] init];
    [backgroundView setBackgroundColor:[UIColor whiteColor]];
    [partnerTableView setBackgroundView:backgroundView];
}

#pragma mark - Selectors

- (void)refreshData:(NSMutableDictionary *)searchMetaInfo;
{
    partnerInfo = [searchMetaInfo[@"partner"] mutableCopy];
    itemCount = [partnerInfo[@"items"] count];
    
    checkedItems = [NSMutableArray array];
    
    if (itemCount > 0) {
        for (NSDictionary *partner in partnerInfo[@"items"]) {
            if ([[partner allKeys] containsObject:@"selectedYN"]) {
                if ([partner[@"selectedYN"] isEqualToString:@"Y"]) {
                    [checkedItems addObject:[partner[@"sellerNo"] stringValue]];
                }
            }
        }
    }
    
    [partnerTableView reloadData];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 43;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CGFloat rowCount;
    if (itemCount > 0) {
        rowCount = itemCount;
    }
    else {
        rowCount = 1;
    }
    
    return rowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight;
    if (itemCount > 0) {
        rowHeight = 48;
    }
    else {
        rowHeight = 150;
    }
    
    return rowHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 43)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(headerView.frame)-15, CGRectGetHeight(headerView.frame))];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:[NSString stringWithFormat:@"전체 (%lu개 파트너스)", (unsigned long)itemCount]];
    [titleLabel setFont:[UIFont systemFontOfSize:14]];
    [titleLabel setTextColor:UIColorFromRGB(0x222222)];
    [headerView addSubview:titleLabel];
    
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [resetButton setFrame:CGRectMake(CGRectGetWidth(headerView.frame)-78, 7.5f, 63, 28)];
    [resetButton setImage:[UIImage imageNamed:@"bt_s_again.png"] forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(touchResetButton) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:resetButton];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerView.frame)-1, CGRectGetWidth(headerView.frame), 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0xc2c5e4)];
    [headerView addSubview:lineView];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    CGFloat rowHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    [cell setBackgroundColor:UIColorFromRGB(0xffffff)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSInteger index = indexPath.row;
    
    // contentView
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake([SYSTEM_VERSION intValue] < 7 ? -10 : 0, 0, tableView.frame.size.width, rowHeight)];
    [contentView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [cell.contentView addSubview:contentView];
    
    if (itemCount > 0) {
        
        // check box
        UIButton *checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [checkButton setFrame:CGRectMake(20, 11, 26, 26)];
        [checkButton setImage:[UIImage imageNamed:@"ic_s_check_press.png"] forState:UIControlStateSelected];
        [checkButton setBackgroundImage:[UIImage imageNamed:@"ic_s_checkbox_nor.png"] forState:UIControlStateNormal];
        [checkButton setBackgroundImage:[UIImage imageNamed:@"ic_s_checkbox_press.png"] forState:UIControlStateSelected];
        [checkButton setTag:index+CELL_CHECKBOX_TAG];
        [checkButton addTarget:self action:@selector(touchCheckButton:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:checkButton];
        
        // seller image
        NSString *imageUrl = [[[partnerInfo objectForKey:@"items"] objectAtIndex:index] objectForKey:@"sellerImg2"];
        CPThumbnailView *partnerImageView = [[CPThumbnailView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(checkButton.frame)+10, 8.5f, 105, 31)];
        [partnerImageView.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
        [contentView addSubview:partnerImageView];
        
        // title
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [textLabel setTextColor:UIColorFromRGB(0x333333)];
        [textLabel setFont:[UIFont systemFontOfSize:15]];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setText:[[[partnerInfo objectForKey:@"items"] objectAtIndex:index] objectForKey:@"dispObjNm"]];
        [textLabel sizeToFit];
        [textLabel setFrame:CGRectMake(15, 0, textLabel.frame.size.width, CGRectGetHeight(contentView.frame))];
//        [contentView addSubview:textLabel];
        
        NSString *sellerNo = [partnerInfo[@"items"][index][@"sellerNo"] stringValue];
        
        if ([self isCheckedItem:sellerNo]) {
            [checkButton setSelected:YES];
        }
        else {
            [checkButton setSelected:NO];
        }
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(contentView.frame)-1, CGRectGetWidth(contentView.frame), 1)];
        [lineView setBackgroundColor:UIColorFromRGB(0xedeef2)];
        [contentView addSubview:lineView];

    }
    else {
        UIImageView *noDataImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(contentView.frame)/2-25, 50, 50, 50)];
        [noDataImageView setImage:[UIImage imageNamed:@"ic_s_notice.png"]];
        [contentView addSubview:noDataImageView];
        
        UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(noDataImageView.frame)+15, CGRectGetWidth(contentView.frame), 40)];
        [noDataLabel setText:@"고객님이 입력하신 검색어에 대한 \n파트너스 결과값이 없습니다."];
        [noDataLabel setTextColor:UIColorFromRGB(0x666666)];
        [noDataLabel setTextAlignment:NSTextAlignmentCenter];
        [noDataLabel setFont:[UIFont systemFontOfSize:15]];
        [noDataLabel setNumberOfLines:0];
        [contentView addSubview:noDataLabel];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (itemCount > 0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIButton *buttonView = (UIButton *)[cell.contentView viewWithTag:indexPath.row+CELL_CHECKBOX_TAG];
        [self touchCheckButton:buttonView];
        
        //AccessLog - 파트너스 리스트 터치 시
        if ([listingType isEqualToString:@"search"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB08"];
        }
        else if ([listingType isEqualToString:@"category"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB08"];
        }
        else if ([listingType isEqualToString:@"model"]) {
            
        }
    }
}

#pragma mark - Selectors

- (void)touchResetButton
{
    [checkedItems removeAllObjects];
    
    [partnerTableView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(didTouchPartnerCheckButton:)]) {
        NSString *searchParameter = @"";
        [self.delegate didTouchPartnerCheckButton:searchParameter];
    }
    
    //AccessLog - 초기화버튼 터치 시
    if ([listingType isEqualToString:@"search"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB09"];
    }
    else if ([listingType isEqualToString:@"category"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB09"];
    }
    else if ([listingType isEqualToString:@"model"]) {
        
    }
}

- (void)touchCheckButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSString *sellerNo = [partnerInfo[@"items"][button.tag-CELL_CHECKBOX_TAG][@"sellerNo"] stringValue];
    
    if ([self isCheckedItem:sellerNo]) {
        [checkedItems removeObject:sellerNo];
        [button setSelected:NO];
    }
    else {
        [checkedItems addObject:sellerNo];
        [button setSelected:YES];
    }
    
    NSString *searchParameter = @"";
    if (checkedItems.count > 0) {
        searchParameter = [NSString stringWithFormat:@"&sellerNos=%@", URLEncode(URLEncode([checkedItems componentsJoinedByString:@","]))];
    }
    
    if ([self.delegate respondsToSelector:@selector(didTouchPartnerCheckButton:)]) {
        [self.delegate didTouchPartnerCheckButton:searchParameter];
    }
}

#pragma mark - Private Methods

- (BOOL)isCheckedItem:(NSString *)sellerNo
{
    BOOL isChecked = NO;
    
    for (NSString *item in checkedItems) {
        if ([sellerNo isEqualToString:item])
            return YES;
    }
    
    return isChecked;
}

@end
