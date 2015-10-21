//
//  CPProductFilterBrandView.m
//  11st
//
//  Created by spearhead on 2015. 6. 4..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductFilterBrandView.h"
#import "AccessLog.h"

#define CELL_TITLELABEL_TAG			100
#define CELL_CHECKBOX_TAG           300

@interface CPProductFilterBrandView() <UITableViewDataSource,
                                       UITableViewDelegate>
{
    NSMutableDictionary *brandInfo;
    
    UITableView *brandTableView;
    
    NSMutableArray *checkedItems;
    
    NSInteger itemCount;
    NSString *listingType;
}

@end

@implementation CPProductFilterBrandView

- (id)initWithFrame:(CGRect)frame brandInfo:(NSMutableDictionary *)aBrandInfo listingType:(NSString *)aListingType
{
    self = [super initWithFrame:frame];
    if (self) {
        
        brandInfo = aBrandInfo;
        itemCount = [brandInfo[@"items"] count];
        listingType = aListingType;
        
        checkedItems = [NSMutableArray array];
        
        if (itemCount > 0) {
            for (NSDictionary *brand in brandInfo[@"items"]) {
                if ([[brand allKeys] containsObject:@"selectedYN"]) {
                    if ([brand[@"selectedYN"] isEqualToString:@"Y"]) {
                        [checkedItems addObject:brand[@"brandCd"]];
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
    //브랜드 테이블뷰
    brandTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) style:UITableViewStyleGrouped];
    [brandTableView setDelegate:self];
    [brandTableView setDataSource:self];
    [brandTableView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [brandTableView setSeparatorColor:[UIColor clearColor]];
    [brandTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self addSubview:brandTableView];
    
    UIView* backgroundView = [[UIView alloc] init];
    [backgroundView setBackgroundColor:[UIColor whiteColor]];
    [brandTableView setBackgroundView:backgroundView];
}

#pragma mark - Selectors

- (void)refreshData:(NSMutableDictionary *)searchMetaInfo;
{
    brandInfo = [searchMetaInfo[@"brand"] mutableCopy];
    itemCount = [brandInfo[@"items"] count];
    
    checkedItems = [NSMutableArray array];
    
    if (itemCount > 0) {
        for (NSDictionary *brand in brandInfo[@"items"]) {
            if ([[brand allKeys] containsObject:@"selectedYN"]) {
                if ([brand[@"selectedYN"] isEqualToString:@"Y"]) {
                    [checkedItems addObject:brand[@"brandCd"]];
                }
            }
        }
    }
    
    [brandTableView reloadData];
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
    [titleLabel setText:[NSString stringWithFormat:@"전체 (%lu개 브랜드)", (unsigned long)itemCount]];
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
        
        // title
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setText:[[[brandInfo objectForKey:@"items"] objectAtIndex:index] objectForKey:@"text"]];
        [textLabel setFrame:CGRectMake(CGRectGetMaxX(checkButton.frame)+10, 0, CGRectGetWidth(contentView.frame)-41, CGRectGetHeight(contentView.frame))];
        [textLabel setTag:CELL_TITLELABEL_TAG];
        [contentView addSubview:textLabel];
        
        NSString *brandCd = brandInfo[@"items"][index][@"brandCd"];
        
        if ([self isCheckedItem:brandCd]) {
            [checkButton setSelected:YES];
            
            [self setHighlightedLabelProperties:textLabel];
        }
        else {
            [checkButton setSelected:NO];
            
            [self setLabelProperties:textLabel];
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
        [noDataLabel setText:@"고객님이 입력하신 검색어에 대한 \n브랜드 결과값이 없습니다."];
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
        
        //AccessLog - 브랜드 리스트 터치 시
        if ([listingType isEqualToString:@"search"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB05"];
        }
        else if ([listingType isEqualToString:@"category"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB05"];
        }
        else if ([listingType isEqualToString:@"model"]) {
            
        }
    }
}

#pragma mark - Selectors

- (void)touchResetButton
{
    [checkedItems removeAllObjects];
    
    [brandTableView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(didTouchBrandCheckButton:)]) {
        NSString *searchParameter = @"";
        [self.delegate didTouchBrandCheckButton:searchParameter];
    }
    
    //AccessLog - 초기화버튼 터치 시
    if ([listingType isEqualToString:@"search"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB05"];
    }
    else if ([listingType isEqualToString:@"category"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB06"];
    }
    else if ([listingType isEqualToString:@"model"]) {
        
    }
}

- (void)touchCheckButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    UITableViewCell *cell = [brandTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag-CELL_CHECKBOX_TAG inSection:0]];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:CELL_TITLELABEL_TAG];
    
    NSString *brandCd = brandInfo[@"items"][button.tag-CELL_CHECKBOX_TAG][@"brandCd"];
    
    if ([self isCheckedItem:brandCd]) {
        [checkedItems removeObject:brandCd];
        [button setSelected:NO];
        
        [self setLabelProperties:titleLabel];
    }
    else {
        [checkedItems addObject:brandCd];
        [button setSelected:YES];
        
        [self setHighlightedLabelProperties:titleLabel];
    }
    
    NSString *searchParameter = @"";
    if (checkedItems.count > 0) {
        searchParameter = [NSString stringWithFormat:@"&brandCd=%@", URLEncode(URLEncode([checkedItems componentsJoinedByString:@","]))];
    }
    
    if ([self.delegate respondsToSelector:@selector(didTouchBrandCheckButton:)]) {
        [self.delegate didTouchBrandCheckButton:searchParameter];
    }
}

#pragma mark - Private Methods

- (BOOL)isCheckedItem:(NSString *)brandCd
{
    BOOL isChecked = NO;

    for (NSString *item in checkedItems) {
        if ([brandCd isEqualToString:item])
            return YES;
    }
    
    return isChecked;
}

- (void)setLabelProperties:(UILabel *)label
{
    [label setTextColor:UIColorFromRGB(0x333333)];
    [label setFont:[UIFont systemFontOfSize:15]];
}

- (void)setHighlightedLabelProperties:(UILabel *)label
{
    [label setTextColor:UIColorFromRGB(0x5e6dff)];
    [label setFont:[UIFont boldSystemFontOfSize:15]];
}
@end
