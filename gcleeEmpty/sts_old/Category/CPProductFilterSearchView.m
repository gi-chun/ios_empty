//
//  CPProductFilterSearchView.m
//  11st
//
//  Created by spearhead on 2015. 6. 4..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductFilterSearchView.h"
#import "AccessLog.h"

typedef NS_ENUM(NSUInteger, CPProductFilterBenefit){
    CPProductFilterBenefitMyWay = 0,
    CPProductFilterBenefitDiscount,
    CPProductFilterBenefitFreeship,
    CPProductFilterBenefitPoint
};

@interface CPProductFilterSearchView() <UITableViewDelegate,
                                        UITableViewDataSource,
                                        UITextFieldDelegate>
{
    NSMutableDictionary *detailInfo;
    
    UITableView *searchTableView;
    
    UITextField *minPriceTextField;
    UITextField *maxPriceTextField;
    UITextField *searchTextField;
    
    UIView *keywordContainerView;
    
    NSMutableArray *searchKeywordItems;
    NSString *listingType;
}
@end

@implementation CPProductFilterSearchView

- (id)initWithFrame:(CGRect)frame detailInfo:(NSMutableDictionary *)aDetailInfo listingType:(NSString *)aListingType
{
    self = [super initWithFrame:frame];
    if (self) {
        
        detailInfo = [aDetailInfo mutableCopy];
        listingType = aListingType;

        searchKeywordItems = [NSMutableArray array];
        
        if (detailInfo.count > 0) {
            searchKeywordItems = [detailInfo[@"previousKwd"] mutableCopy];
            NSMutableArray *array = [detailInfo[@"previousKwd"] mutableCopy];
            
            for (NSString *keyword in array) {
                if (nilCheck(keyword)) {
                    [searchKeywordItems removeObject:keyword];
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
    //검색 테이블뷰
    searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) style:UITableViewStyleGrouped];
    [searchTableView setDelegate:self];
    [searchTableView setDataSource:self];
    [searchTableView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [searchTableView setSeparatorColor:[UIColor clearColor]];
    [searchTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self addSubview:searchTableView];
    
    UIView* backgroundView = [[UIView alloc] init];
    [backgroundView setBackgroundColor:[UIColor whiteColor]];
    [searchTableView setBackgroundView:backgroundView];
}

#pragma mark - Selectors

- (void)refreshData:(NSMutableDictionary *)searchMetaInfo;
{
    detailInfo = [searchMetaInfo[@"detail"] mutableCopy];
    
    //가격비교 여부
    BOOL isPriceCompare = searchMetaInfo.count == 3;
    [detailInfo setObject:isPriceCompare?@"Y":@"N" forKey:@"isPriceCompare"];
    
    searchKeywordItems = [NSMutableArray array];
    
    if (detailInfo.count > 0) {
        searchKeywordItems = [detailInfo[@"previousKwd"] mutableCopy];
        NSMutableArray *array = [detailInfo[@"previousKwd"] mutableCopy];
        
        for (NSString *keyword in array) {
            if (nilCheck(keyword)) {
                [searchKeywordItems removeObject:keyword];
            }
        }
    }
    
    [searchTableView reloadData];
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
    //가격비교
    if ([detailInfo[@"isPriceCompare"] isEqualToString:@"Y"]) {
        return 3;
    }
    
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 95;
    
    BOOL isPriceCompare = [detailInfo[@"isPriceCompare"] isEqualToString:@"Y"];
    if (!isPriceCompare && indexPath.row == 1) {
        rowHeight = 130;
    }
    if (indexPath.row == (isPriceCompare?1:2)) {
        rowHeight = 120;
    }
    return rowHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 43)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    
    NSString *productCountStr = detailInfo && detailInfo.count > 0 ? detailInfo[@"productCount"] : @"0";
    
    NSString *titleString = @"상품";
    if ([detailInfo[@"isPriceCompare"] isEqualToString:@"Y"]) {
        titleString = @"모델";
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(headerView.frame)-15, CGRectGetHeight(headerView.frame))];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:[NSString stringWithFormat:@"전체 (%@개 %@)", productCountStr, titleString]];
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
    
    if ([detailInfo[@"isPriceCompare"] isEqualToString:@"Y"] && indexPath.row > 0) {
        index++;
    }
    
    // contentView
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake([SYSTEM_VERSION intValue] < 7 ? -10 : 0, 0, tableView.frame.size.width, rowHeight)];
    [contentView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [cell.contentView addSubview:contentView];
    
    UIImage *backgroundImage = [[UIImage imageNamed:@"box_s_filter.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    if (index == 0) {
        // title
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 50, 18)];
        [textLabel setTextColor:UIColorFromRGB(0x333333)];
        [textLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setText:@"가격"];
        [contentView addSubview:textLabel];
        
        CGFloat textFieldWidth = (CGRectGetWidth(contentView.frame)-30-53)/2;
        
        // 최소가격
        UIView *minPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 11, 34)];
        minPriceTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(textLabel.frame)+5, textFieldWidth, 34)];
        [minPriceTextField setBackground:backgroundImage];
        [minPriceTextField setReturnKeyType:UIReturnKeyDone];
        [minPriceTextField setKeyboardType:UIKeyboardTypeNumberPad];
        [minPriceTextField setFont:[UIFont systemFontOfSize:15]];
        [minPriceTextField setTextColor:UIColorFromRGB(0x444444)];
        [minPriceTextField setLeftView:minPaddingView];
        [minPriceTextField setLeftViewMode:UITextFieldViewModeAlways];
        [minPriceTextField setDelegate:self];
        [contentView addSubview:minPriceTextField];
        
        if (detailInfo[@"fromPrice"] && ([detailInfo[@"fromPrice"] integerValue] > 0)) {
            [minPriceTextField setText:[detailInfo[@"fromPrice"] stringValue]];
        }
        
        // 원~
        UILabel *unitLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(minPriceTextField.frame), CGRectGetMaxY(textLabel.frame)+5, 35, 34)];
        [unitLabel setTextColor:UIColorFromRGB(0x666666)];
        [unitLabel setFont:[UIFont systemFontOfSize:13]];
        [unitLabel setBackgroundColor:[UIColor clearColor]];
        [unitLabel setText:@"원 ~"];
        [unitLabel setTextAlignment:NSTextAlignmentCenter];
        [contentView addSubview:unitLabel];
        
        // 최대가격
        UIView *maxPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 11, 34)];
        maxPriceTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(unitLabel.frame), CGRectGetMaxY(textLabel.frame)+5, textFieldWidth, 34)];
        [maxPriceTextField setBackground:backgroundImage];
        [maxPriceTextField setReturnKeyType:UIReturnKeyDone];
        [maxPriceTextField setKeyboardType:UIKeyboardTypeNumberPad];
        [maxPriceTextField setFont:[UIFont systemFontOfSize:15]];
        [maxPriceTextField setTextColor:UIColorFromRGB(0x444444)];
        [maxPriceTextField setLeftView:maxPaddingView];
        [maxPriceTextField setLeftViewMode:UITextFieldViewModeAlways];
        [maxPriceTextField setDelegate:self];
        [contentView addSubview:maxPriceTextField];
        
        if (detailInfo[@"toPrice"] && ([detailInfo[@"toPrice"] integerValue] > 0)) {
            [maxPriceTextField setText:[detailInfo[@"toPrice"] stringValue]];
        }
        
        // 원
        unitLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(maxPriceTextField.frame), CGRectGetMaxY(textLabel.frame)+5, 18, 34)];
        [unitLabel setTextColor:UIColorFromRGB(0x666666)];
        [unitLabel setFont:[UIFont systemFontOfSize:13]];
        [unitLabel setBackgroundColor:[UIColor clearColor]];
        [unitLabel setText:@"원"];
        [unitLabel setTextAlignment:NSTextAlignmentRight];
        [contentView addSubview:unitLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(contentView.frame)-1, CGRectGetWidth(contentView.frame), 1)];
        [lineView setBackgroundColor:UIColorFromRGB(0xedeef2)];
        [contentView addSubview:lineView];
    }
    else if (index == 1) {
        // title
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 70, 18)];
        [textLabel setTextColor:UIColorFromRGB(0x333333)];
        [textLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setText:@"혜택 및 배송"];
        [contentView addSubview:textLabel];
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textLabel.frame), 15, 100, 18)];
        [textLabel setTextColor:UIColorFromRGB(0x666666)];
        [textLabel setFont:[UIFont systemFontOfSize:14]];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setText:@"(중복가능)"];
        [contentView addSubview:textLabel];
        
        CGFloat space = 6;
        CGFloat buttonWidth = (CGRectGetWidth(contentView.frame)-30-6)/2;
        
        UIButton *myWayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [myWayButton setFrame:CGRectMake(15, CGRectGetMaxY(textLabel.frame)+8, buttonWidth, 34)];
        [myWayButton setTitle:@"내맘대로 할인" forState:UIControlStateNormal];
        [myWayButton setTag:CPProductFilterBenefitMyWay];
        [self setButtonProperties:myWayButton];
        [contentView addSubview:myWayButton];
        
        UIButton *discountButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [discountButton setFrame:CGRectMake(CGRectGetMaxX(myWayButton.frame)+space, CGRectGetMaxY(textLabel.frame)+8, buttonWidth, 34)];
        [discountButton setTitle:@"할인" forState:UIControlStateNormal];
        [discountButton setTag:CPProductFilterBenefitDiscount];
        [self setButtonProperties:discountButton];
        [contentView addSubview:discountButton];
        
        UIButton *freeshipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [freeshipButton setFrame:CGRectMake(15, CGRectGetMaxY(myWayButton.frame)+5, buttonWidth, 34)];
        [freeshipButton setTitle:@"무료배송" forState:UIControlStateNormal];
        [freeshipButton setTag:CPProductFilterBenefitFreeship];
        [self setButtonProperties:freeshipButton];
        [contentView addSubview:freeshipButton];
        
        UIButton *pointButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [pointButton setFrame:CGRectMake(CGRectGetMaxX(freeshipButton.frame)+space, CGRectGetMaxY(myWayButton.frame)+5, buttonWidth, 34)];
        [pointButton setTitle:@"적립" forState:UIControlStateNormal];
        [pointButton setTag:CPProductFilterBenefitPoint];
        [self setButtonProperties:pointButton];
        [contentView addSubview:pointButton];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(contentView.frame)-1, CGRectGetWidth(contentView.frame), 1)];
        [lineView setBackgroundColor:UIColorFromRGB(0xedeef2)];
        [contentView addSubview:lineView];
    }
    else if (index == 2) {
        // title
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 70, 18)];
        [textLabel setTextColor:UIColorFromRGB(0x333333)];
        [textLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setText:@"결과 내 검색"];
        [contentView addSubview:textLabel];
        
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 11, 34)];
        searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(textLabel.frame)+5, CGRectGetWidth(contentView.frame)-30, 34)];
        [searchTextField setBackground:backgroundImage];
        [searchTextField setReturnKeyType:UIReturnKeyDone];
        [searchTextField setFont:[UIFont systemFontOfSize:14]];
        [searchTextField setTextColor:UIColorFromRGB(0x444444)];
        [searchTextField setLeftView:paddingView];
        [searchTextField setLeftViewMode:UITextFieldViewModeAlways];
        [searchTextField setDelegate:self];
        [contentView addSubview:searchTextField];
        
        keywordContainerView = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(searchTextField.frame)+10, CGRectGetWidth(contentView.frame)-30, 18)];
        [keywordContainerView setClipsToBounds:YES];
        [contentView addSubview:keywordContainerView];
        
        [self loadSearchKeywordView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(contentView.frame)-1, CGRectGetWidth(contentView.frame), 1)];
        [lineView setBackgroundColor:UIColorFromRGB(0xedeef2)];
        [contentView addSubview:lineView];
    }
    else {
        UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [searchButton setFrame:CGRectMake(CGRectGetWidth(contentView.frame)/2-60, 10, 120, 34)];
        [searchButton setTitle:@"상세검색" forState:UIControlStateNormal];
        [searchButton setTitleColor:UIColorFromRGB(0xf8f8f8) forState:UIControlStateNormal];
        [searchButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [searchButton setBackgroundImage:[UIImage imageNamed:@"bt_s_filter.png"] forState:UIControlStateNormal];
        [searchButton addTarget:self action:@selector(touchSearchButton) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:searchButton];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Private Methods

- (void)setButtonProperties:(UIButton *)button
{
    UIImage *myWayImageNormal = [[UIImage imageNamed:@"bt_s_na_filterbox_nor.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    UIImage *buttonBackgroundImageNormal = [[UIImage imageNamed:@"bt_s_filterbox_nor.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    UIImage *buttonBackgroundImageSelected = [[UIImage imageNamed:@"bt_s_filterbox_press.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    [button setTitleColor:UIColorFromRGB(0x444444) forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0x5e6dff) forState:UIControlStateSelected];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [button setImage:[UIImage imageNamed:@"ic_s_check_nor.png"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"ic_s_check_press.png"] forState:UIControlStateSelected];
    [button setBackgroundImage:buttonBackgroundImageNormal forState:UIControlStateNormal];
    [button setBackgroundImage:buttonBackgroundImageSelected forState:UIControlStateSelected];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    [button addTarget:self action:@selector(touchBenefitButton:) forControlEvents:UIControlEventTouchUpInside];
    
//    NSString *itemTag = [NSString stringWithFormat:@"%li", (long)button.tag];
    
    switch (button.tag) {
        case CPProductFilterBenefitMyWay:
            [button setImage:[UIImage imageNamed:@"ic_s_na_check_nor.png"] forState:UIControlStateNormal];
            [button setBackgroundImage:myWayImageNormal forState:UIControlStateNormal];
            [button setSelected:([detailInfo[@"myWayYN"] isEqualToString:@"Y"] ? YES : NO)];
            break;
        case CPProductFilterBenefitDiscount:
            [button setSelected:([detailInfo[@"discountYN"] isEqualToString:@"Y"] ? YES : NO)];
            break;
        case CPProductFilterBenefitFreeship:
            [button setSelected:([detailInfo[@"freeDlvYN"] isEqualToString:@"Y"] ? YES : NO)];
            break;
        case CPProductFilterBenefitPoint:
            [button setSelected:([detailInfo[@"pointYN"] isEqualToString:@"Y"] ? YES : NO)];
            break;
        default:
            break;
    }
    
//    if ([self isCheckedItem:itemTag]) {
//        [button setSelected:YES];
//    }
//    else {
//        [button setSelected:NO];
//    }
}

#pragma mark - Selectors

- (void)touchResetButton
{
    [minPriceTextField setText:@""];
    [maxPriceTextField setText:@""];
    [searchTextField setText:@""];
    
    [searchKeywordItems removeAllObjects];
    
    detailInfo[@"myWayYN"] = @"N";
    detailInfo[@"freeDlvYN"] = @"N";
    detailInfo[@"pointYN"] = @"N";
    detailInfo[@"discountYN"] = @"N";
    [detailInfo removeObjectForKey:@"fromPrice"];
    [detailInfo removeObjectForKey:@"toPrice"];
    
//    [searchTableView reloadData];
    [self touchSearchButton:NO];
    
    //AccessLog - 초기화 버튼 터치 시
    if ([listingType isEqualToString:@"search"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB12"];
    }
    else if ([listingType isEqualToString:@"category"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB12"];
    }
    else if ([listingType isEqualToString:@"model"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPB06"];
    }
}

- (void)touchBenefitButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    switch (button.tag) {
        case CPProductFilterBenefitMyWay:
            [button setSelected:!button.isSelected];
            detailInfo[@"myWayYN"] = button.isSelected ? @"Y" : @"N";
            break;
        case CPProductFilterBenefitDiscount:
            [button setSelected:!button.isSelected];
            detailInfo[@"discountYN"] = button.isSelected ? @"Y" : @"N";
            break;
        case CPProductFilterBenefitFreeship:
//            [button setSelected:([detailInfo[@"freeDlvYN"] isEqualToString:@"Y"] ? YES : NO)];
            [button setSelected:!button.isSelected];
            detailInfo[@"freeDlvYN"] = button.isSelected ? @"Y" : @"N";
            break;
        case CPProductFilterBenefitPoint:
//            [button setSelected:([detailInfo[@"pointYN"] isEqualToString:@"Y"] ? YES : NO)];
            [button setSelected:!button.isSelected];
            detailInfo[@"pointYN"] = button.isSelected ? @"Y" : @"N";
            break;
        default:
            break;
    }
    
    
    if ([listingType isEqualToString:@"search"]) {
        switch (button.tag) {
            case CPProductFilterBenefitMyWay:
                
                break;
            case CPProductFilterBenefitDiscount:
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB14"];
                break;
            case CPProductFilterBenefitFreeship:
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB15"];
                break;
            case CPProductFilterBenefitPoint:
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB16"];
                break;
            default:
                break;
        }
    }
    else if ([listingType isEqualToString:@"category"]) {
        switch (button.tag) {
            case CPProductFilterBenefitMyWay:
                
                break;
            case CPProductFilterBenefitDiscount:
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB14"];
                break;
            case CPProductFilterBenefitFreeship:
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB15"];
                break;
            case CPProductFilterBenefitPoint:
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB16"];
                break;
            default:
                break;
        }
    }
    else if ([listingType isEqualToString:@"model"]) {
        
    }
}

- (void)touchSearchButton
{
    [self touchSearchButton:YES];
}

- (void)touchSearchButton:(NSInteger)isReset
{
    [searchTextField resignFirstResponder];
    
    NSInteger fromPrice = 0;
    NSInteger toPrice = 0;
    
    if (minPriceTextField.text.length > 0) {
        detailInfo[@"fromPrice"] = minPriceTextField.text;
        fromPrice = [minPriceTextField.text integerValue];
    }
    else {
        [detailInfo removeObjectForKey:@"fromPrice"];
    }
    
    if (maxPriceTextField.text.length > 0) {
        detailInfo[@"toPrice"] = maxPriceTextField.text;
        toPrice = [maxPriceTextField.text integerValue];
    }
    else {
        [detailInfo removeObjectForKey:@"toPrice"];
    }
    
    if (fromPrice > toPrice && toPrice > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림"
                                                        message:@"가격을 정확히 입력해주세요."
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
                                              otherButtonTitles:nil];
        [alert setDelegate:self];
        [alert show];
        return;
    }
    
    if (!nilCheck(searchTextField.text)) {
//        [searchKeywordItems insertObject:searchTextField.text atIndex:0];
        
        NSString *encKeyword = [searchTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        encKeyword = [encKeyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        detailInfo[@"inKeyword"] = encKeyword;//[Modules encodeAddingPercentEscapeString:searchTextField.text];
        [searchTextField setText:@""];
        
        [self loadSearchKeywordView];
    }
    
    NSString *searchParameter = @"";

    if (searchKeywordItems.count > 0) {
        
        NSString *encKeyword = [[searchKeywordItems componentsJoinedByString:@","] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        encKeyword = [encKeyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        detailInfo[@"previousKwd"] = encKeyword;
//        detailInfo[@"previousKwd"] = [Modules encodeAddingPercentEscapeString:[searchKeywordItems componentsJoinedByString:@","]];
    }
    else {
        detailInfo[@"previousKwd"] = @"";
    }
    
    if ([detailInfo[@"myWayYN"] isEqualToString:@"Y"]) {
        detailInfo[@"myWay"] = @"Y";
    }
    
    if ([detailInfo[@"freeDlvYN"] isEqualToString:@"Y"]) {
        detailInfo[@"dlvType"] = @"01";
    }
    
    if ([detailInfo[@"pointYN"] isEqualToString:@"Y"]) {
        detailInfo[@"custBenefit"] = @"P";
    }
    
    if ([detailInfo[@"discountYN"] isEqualToString:@"Y"]) {
        if ([detailInfo[@"custBenefit"] length] > 0) {
            detailInfo[@"custBenefit"] = [NSString stringWithFormat:@"%@,", detailInfo[@"custBenefit"]];
        }
        detailInfo[@"custBenefit"] = [NSString stringWithFormat:@"%@S", detailInfo[@"custBenefit"] ? detailInfo[@"custBenefit"] : @""];
    }
    
    [detailInfo removeObjectForKey:@"myWayYN"];
    [detailInfo removeObjectForKey:@"freeDlvYN"];
    [detailInfo removeObjectForKey:@"pointYN"];
    [detailInfo removeObjectForKey:@"discountYN"];
    
    for (NSString *key in [detailInfo allKeys]) {
        if (!([key isEqualToString:@"productCount"] || [key isEqualToString:@"isPriceCompare"] || [key isEqualToString:@"selected"])) { //productCount는 제외
            NSString *value = [detailInfo valueForKey:key];
            
            if (value.length > 0) {
                searchParameter = [searchParameter stringByAppendingFormat:@"&%@=%@", key, value];
            }
        }
    }
//    if (checkedItems.count > 0) {
//        searchParameter = [NSString stringWithFormat:@"&sellerNo=%@", URLEncode(URLEncode([checkedItems componentsJoinedByString:@","]))];
//    }
    
    if ([self.delegate respondsToSelector:@selector(didTouchDetailSearchButton:)]) {
        [self.delegate didTouchDetailSearchButton:searchParameter];
    }
    
    if (isReset) {
        if ([self.delegate respondsToSelector:@selector(removeFilterView)]) {
            [self.delegate removeFilterView];
        }
    }
    
    [self touchKeyboardCloseButton];
    
    //AccessLog - 상세검색 버튼 터치 시
    if ([listingType isEqualToString:@"search"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB11"];
    }
    else if ([listingType isEqualToString:@"category"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB11"];
    }
    else if ([listingType isEqualToString:@"model"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPB05"];
    }
}

- (void)touchKeywordButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    [searchKeywordItems removeObjectAtIndex:button.tag];
    
    [self loadSearchKeywordView];
    
    //AccessLog - 상세검색 결과 내 검색 삭제 터치 시
    if ([listingType isEqualToString:@"search"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB18"];
    }
    else if ([listingType isEqualToString:@"category"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB18"];
    }
    else if ([listingType isEqualToString:@"model"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPB12 "];
    }
}

- (void)touchKeyboardCloseButton
{
    [self endEditing:YES];
}

#pragma mark - Private Methods

- (void)loadSearchKeywordView
{
    for (UIView *subView in keywordContainerView.subviews) {
        [subView removeFromSuperview];
    }
    
    CGFloat buttonX = 0;
    
    for (NSInteger i = 0; i < searchKeywordItems.count; i++) {
        NSString *keyword = searchKeywordItems[i];
        CGSize labelSize = [keyword sizeWithFont:[UIFont systemFontOfSize:13]];
        
        CGFloat buttonWidth = labelSize.width+33;
        
        UIButton *keywordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [keywordButton setBackgroundColor:[UIColor clearColor]];
        [keywordButton setFrame:CGRectMake(buttonX, 0, buttonWidth, CGRectGetHeight(keywordContainerView.frame))];
        [keywordButton setImage:[UIImage imageNamed:@"ic_s_delete.png"] forState:UIControlStateNormal];
        [keywordButton setTitle:keyword forState:UIControlStateNormal];
        [keywordButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
        [keywordButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [keywordButton addTarget:self action:@selector(touchKeywordButton:) forControlEvents:UIControlEventTouchUpInside];
        [keywordButton setTag:i];
        [keywordButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [keywordButton setImageEdgeInsets:UIEdgeInsetsMake(0, labelSize.width+13, 0, 0)];
        [keywordContainerView addSubview:keywordButton];
        
        buttonX += buttonWidth+20;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // 키보드 액세사리뷰
    UIView *cancelView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenBoundsHeight-36, kScreenBoundsWidth, 36)];
    [cancelView setBackgroundColor:[UIColor clearColor]];
    [textField setInputAccessoryView:cancelView];
    
    // 닫기 버튼
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setFrame:CGRectMake(CGRectGetWidth(cancelView.frame)-59, 0, 51, 27)];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"search_btn_close.png"] forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"search_btn_close_press.png"] forState:UIControlStateHighlighted];
    [cancelButton addTarget:self action:@selector(touchKeyboardCloseButton) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setAccessibilityLabel:@"닫기" Hint:@"검색창을 닫습니다"];
    [cancelView addSubview:cancelButton];
    
    if ([textField isEqual:searchTextField]) {
        //AccessLog - 상세검색 결과 내 검색 터치 시
        if ([listingType isEqualToString:@"search"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB17"];
        }
        else if ([listingType isEqualToString:@"category"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB17"];
        }
        else if ([listingType isEqualToString:@"model"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPB11"];
        }
    }
    else {
        //AccessLog - 상세검색 가격영역 터치 시
        if ([listingType isEqualToString:@"search"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB13"];
        }
        else if ([listingType isEqualToString:@"category"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB13"];
        }
        else if ([listingType isEqualToString:@"model"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPB07"];
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self touchKeyboardCloseButton];
    
    return YES;
}

@end
