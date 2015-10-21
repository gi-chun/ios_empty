//
//  OptionItemView.m
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 2..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "OptionItemView.h"
#import "CPProductOptionLoadingView.h"
#import "NZLabel.h"
#import "OptionExpndCell.h"
#import "AccessLog.h"
#import "NSString+URLEncodedString.h"

typedef NS_ENUM(NSUInteger, ProductOptionTags) {
    ProductOptionTagsNameLabel = 1300,
    ProductOptionTagsSelectedLabel,
    ProductOptionTagsRadioImageView,
    ProductOptionTagsColorLabel,
    ProductOptionTagsSearch
};

@interface OptionItemView() <UITextFieldDelegate>
{
    NSMutableArray *searchOptionsArray;
    
    BOOL isKeyboardShowing;
    
    UIView *drawerBar;
    
    BOOL isSearching;
    BOOL isEditing;
    BOOL isKeyboardShown;
    BOOL isAdditional;
    
    NSInteger selectedRow;
    NSInteger selectedIndex;
    NSInteger searchingIndex;
    
    CGRect beforeRectKeyboardShowSelfView;
    CGRect beforeRectKeyboardShowOptionTableView;
    CGRect beforeRectKeyboardShowOptionBottomView;
    
    UITextField *activeTextField;
    
    CPProductOptionLoadingView *loadingView;
    
    UITextField *searchTextField;
    
    NSInteger inputOptionCount;
    
    BOOL isResetSelected;
    
    UIImageView *containerImageView;
}

@property (nonatomic, strong) UIButton *optionArrowButton;
@property (nonatomic, strong) UIView *optionBottomView, *keyboardToolView;
@property (nonatomic, readonly) BOOL isDrawerOpen;

@end


@implementation OptionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:UIColorFromRGB(0xeaeaea)];
        
        [self initLayout];
    }
    
    return self;
}

- (id)initWithProductOption:(NSArray *)options
             selectedOption:(NSArray *)selected
             itemDetailInfo:(NSDictionary *)itemDetailInfo
                      title:(NSString *)title
                 selectName:(NSString *)selectName
               isAdditional:(BOOL)additional
                      frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:UIColorFromRGB(0xeaeaea)];
        [self setOptions:[NSMutableArray arrayWithArray:options]];
        [self setSelectedItemArray:selected];
        [self setItemDetailInfo:itemDetailInfo];
        [self setTitle:title];
        [self setSelectName:selectName];
        [self setOpenOffset:0];
        [self setOpenMinimumHeight:150.f];
        
        isAdditional = additional;
        
        [self initLayout];
        
        searchingIndex = -1;
        
        [self setSelectedIndex:self.options];
        
        [self setInputOptionCount];
        
        searchOptionsArray = [NSMutableArray array];
    }
    
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc optionItemView");
    self.optionDelegate = nil;
}

- (void)initLayout
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    UIImage *upNorImage = [UIImage imageNamed:@"bt_optionbar_down.png"];
    UIImage *upHilImage = [UIImage imageNamed:@"bt_optionbar_down.png"];
    
    _optionArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    drawerBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 24.f)];
    [drawerBar setBackgroundColor:[UIColor clearColor]];
    
    _keyboardToolView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 43.f)];
    
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.frame.size.width, 1.f)];
    [barView setBackgroundColor:UIColorFromRGBA(0x000000, 0.12f)];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                              barView.frame.origin.y,
                                                              self.frame.size.width,
                                                              self.frame.size.height-barView.frame.origin.y+barView.frame.size.height)];
    [bgView setBackgroundColor:UIColorFromRGB(0xeaeaea)];
    [bgView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    UIView *keyboardToolLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _keyboardToolView.frame.size.width, 1.f)];
    
    UIButton *btnKeyboardDown = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self setAutoresizesSubviews:YES];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    [self.optionArrowButton setAdjustsImageWhenHighlighted:NO];
    [self.optionArrowButton setImage:upNorImage forState:UIControlStateNormal];
    [self.optionArrowButton setImage:upHilImage forState:UIControlStateHighlighted];
    [self.optionArrowButton setFrame:CGRectMake((drawerBar.frame.size.width-upNorImage.size.width)/2,
                                                0,
                                                upNorImage.size.width,
                                                upNorImage.size.height)];
    
    if ([self respondsToSelector:@selector(touchCloseDrawerButton)]) {
        [self.optionArrowButton addTarget:self action:@selector(touchCloseDrawerButton) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [keyboardToolLine setBackgroundColor:UIColorFromRGBA(0x000000, 0.33f)];
    
    [btnKeyboardDown setBackgroundColor:[UIColor clearColor]];
    [btnKeyboardDown.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
    [btnKeyboardDown setTitle:@"닫기" forState:UIControlStateNormal];
    [btnKeyboardDown setTitleColor:UIColorFromRGB(0x636566) forState:UIControlStateNormal];
    [btnKeyboardDown addTarget:self action:@selector(onClickKeyboardDown:) forControlEvents:UIControlEventTouchUpInside];
    [btnKeyboardDown setBackgroundImage:[UIImage imageNamed:@"search_keypad_btn_nor.png"] forState:UIControlStateNormal];
    [btnKeyboardDown setBackgroundImage:[UIImage imageNamed:@"search_keypad_btn_select.png"] forState:UIControlStateHighlighted];
    [btnKeyboardDown setFrame:CGRectMake(_keyboardToolView.frame.size.width - 70.f, (_keyboardToolView.frame.size.height - 36.f) / 2, 60.f, 36.f)];
    
    [self.keyboardToolView setBackgroundColor:UIColorFromRGBA(0xb7b7b7, 0.9f)];
    [self.keyboardToolView addSubview:keyboardToolLine];
    [self.keyboardToolView addSubview:btnKeyboardDown];
    
    [drawerBar addSubview:barView];
    [drawerBar addSubview:self.optionArrowButton];
    
    [self addSubview:bgView];
    [self addSubview:drawerBar];
    [self addSubview:self.keyboardToolView];
    
    //LoadingView
    loadingView = [[CPProductOptionLoadingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2-20,
                                                                               CGRectGetHeight(self.frame)/2-20,
                                                                               40,
                                                                               40)];
    [self startLoadingAnimation];
    
    [self initContentsView];
}

- (void)initContentsView
{
    //타이틀
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(drawerBar.frame)+7, CGRectGetWidth(self.frame)-20, 27)];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    [headerLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [headerLabel setTextColor:UIColorFromRGB(0x5d5d5d)];
    [headerLabel setTextAlignment:NSTextAlignmentLeft];
    [headerLabel setText:self.selectName];
    [self addSubview:headerLabel];
    
    //백그라운드 이미지
    UIImage *bgImage = [UIImage imageNamed:@"layer_optionbar_selectedbox_press.png"];
    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    containerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10,
                                                                       CGRectGetMaxY(headerLabel.frame)+1,
                                                                       CGRectGetWidth(self.frame)-20,
                                                                       CGRectGetHeight(self.frame)-(CGRectGetHeight(drawerBar.frame)+40))];
    [containerImageView setImage:bgImage];
    [containerImageView setUserInteractionEnabled:YES];
//    [self addSubview:containerImageView];
    [self insertSubview:containerImageView belowSubview:loadingView];
    
    //옵션 테이블뷰
    _optionTableView = [[UITableView alloc] initWithFrame:CGRectMake(1, 1, CGRectGetWidth(containerImageView.frame)-2, CGRectGetHeight(containerImageView.frame)-2) style:UITableViewStylePlain];
    [_optionTableView setBounces:NO];
    [_optionTableView setDelegate:self];
    [_optionTableView setDataSource:self];
    [_optionTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_optionTableView setBackgroundColor:[UIColor clearColor]];
    [containerImageView addSubview:_optionTableView];
}

#pragma mark - Public Methods

- (void)reloadOptionItemView
{
    NSLog(@"reloadOptionItemView");
    
    [self.optionTableView reloadData];
    
    [self stopLoadingAnimation];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.options.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat headerViewHeight = 81;
    
    //날짜형 상품은(dateOptYn = "Y") 검색 노출 안함
    NSString *dateOptYn = self.itemDetailInfo[@"dateOptYn"];
    if ([@"Y" isEqualToString:dateOptYn] || isAdditional) {
        headerViewHeight = 32;
    }
    
    return headerViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat headerViewHeight = 81;
    
    //날짜형 상품은(dateOptYn = "Y") 검색 노출 안함
    NSString *dateOptYn = self.itemDetailInfo[@"dateOptYn"];
    if ([@"Y" isEqualToString:dateOptYn] || isAdditional) {
        headerViewHeight = 32;
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_optionTableView.frame), headerViewHeight)];
    [headerView setBackgroundColor:UIColorFromRGB(0xffffff)];
    
    UIView *selectView = [[UIView alloc] initWithFrame:CGRectMake(-1, -1, CGRectGetWidth(_optionTableView.frame)-28.5f, 32)];
    [headerView addSubview:selectView];
    
    //추가구성상품일 경우 addPrdGrpNm값
    UILabel *selectLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(_optionTableView.frame)-42, 32)];
    [selectLabel setText:(isAdditional ? self.title : @"옵션을 선택해 주세요")];
    [selectLabel setTextColor:UIColorFromRGB(0xb6b6b6)];
    [selectLabel setFont:[UIFont systemFontOfSize:14]];
    [selectView addSubview:selectLabel];
    
    UIButton *arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [arrowButton setFrame:CGRectMake(CGRectGetWidth(_optionTableView.frame)-30, -1, 32, 32)];
    [arrowButton setBackgroundColor:[UIColor clearColor]];
    [arrowButton setImage:[UIImage imageNamed:@"ic_optionbar_arrow_up_01.png"] forState:UIControlStateNormal];
    [arrowButton addTarget:self action:@selector(closeOptionItemView:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:arrowButton];
    
    UIView *verticaLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 32)];
    [verticaLineView setBackgroundColor:UIColorFromRGB(0xc6c6ce)];
    [arrowButton addSubview:verticaLineView];
    
    UIView *horizontalLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 31, 32, 1)];
    [horizontalLineView setBackgroundColor:UIColorFromRGB(0xc6c6ce)];
    [arrowButton addSubview:horizontalLineView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(selectView.frame)-1, CGRectGetWidth(selectView.frame), 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0xc6c6ce)];
    [selectView addSubview:lineView];
    
    UIButton *blankButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [blankButton setFrame:selectView.frame];
    [blankButton addTarget:self action:@selector(closeOptionItemView:) forControlEvents:UIControlEventTouchUpInside];
    [blankButton setTag:0];
    [headerView addSubview:blankButton];
    
    //날짜형이 아닌 경우 검색 노출
    if (![@"Y" isEqualToString:dateOptYn] && !isAdditional) {
        UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(selectView.frame), CGRectGetWidth(_optionTableView.frame), 49)];
        [searchView setBackgroundColor:UIColorFromRGB(0xffffff)];
        [headerView addSubview:searchView];
        
        UIView *leftInsetView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 32)];
        [leftInsetView setBackgroundColor:[UIColor clearColor]];
        
        UIImage *backgroundImage = [UIImage imageNamed:@"layer_optionbar_searchbox"];
        backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, CGRectGetWidth(searchView.frame)-20, 33)];
        [backgroundImageView setImage:backgroundImage];
        [backgroundImageView setUserInteractionEnabled:YES];
        [searchView addSubview:backgroundImageView];
        
        NSAttributedString *placeholderAttribute = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"ProductOptionSearchHint", nil)
                                                                                   attributes:@{
                                                                                                NSForegroundColorAttributeName: UIColorFromRGB(0x999999), NSFontAttributeName: [UIFont systemFontOfSize:14] }];
        
        searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(backgroundImageView.frame)-30, 33)];
        [searchTextField setDelegate:self];
        [searchTextField setLeftView:leftInsetView];
        [searchTextField setBackground:backgroundImage];
        [searchTextField setReturnKeyType:UIReturnKeyDone];
        [searchTextField setBorderStyle:UITextBorderStyleNone];
        [searchTextField setTextColor:UIColorFromRGB(0x4957e3)];
        [searchTextField setFont:[UIFont systemFontOfSize:13]];
        [searchTextField setBackgroundColor:[UIColor clearColor]];
        [searchTextField setLeftViewMode:UITextFieldViewModeAlways];
        [searchTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [searchTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [searchTextField setAttributedPlaceholder:placeholderAttribute];
        [searchTextField setTag:ProductOptionTagsSearch];
        [searchTextField setText:self.searchWord];
        [backgroundImageView addSubview:searchTextField];
        
        UIView *verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(backgroundImageView.frame)-34, 7, 1, 19)];
        [verticalLineView setBackgroundColor:UIColorFromRGB(0xd6d6d6)];
        [backgroundImageView addSubview:verticalLineView];
        
        UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [searchButton setFrame:CGRectMake(CGRectGetWidth(backgroundImageView.frame)-33, 0, 33, 33)];
        [searchButton setImage:[UIImage imageNamed:@"ic_optionbar_search_nor.png"] forState:UIControlStateNormal];
        [searchButton addTarget:self action:@selector(onClickKeyboardDown:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundImageView addSubview:searchButton];
    }
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerView.frame)-1, CGRectGetWidth(headerView.frame), 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0xe5e5e5)];
    [headerView addSubview:lineView];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 35;
    
    // 옵셩항목구분 (01:조합형 ,02:독립형, 03:입력형)
    NSString *optClfCd = self.options[indexPath.row][@"optClfCd"];
    
    // 입력형은 비노출
    if ([@"03" isEqualToString:optClfCd]) {
        rowHeight = 0;
    }
    else {
        if(selectedIndex == indexPath.row) {
            
            NSInteger optionCount;
            if (isSearching && searchingIndex == indexPath.row) {
                optionCount = searchOptionsArray.count;
                
                if (searchOptionsArray.count == 0) {
                    rowHeight += 61;
                }
            }
            else {
                optionCount = [self.options[indexPath.row][@"optItemList"] count];
            }
            
            for (int i = 0; i < optionCount; i++) {
                
                NSDictionary *option;
                if (isSearching && searchingIndex == indexPath.row) {
                    option = searchOptionsArray[i];
                }
                else {
                    option = self.options[indexPath.row][@"optItemList"][i];
                }
                
                //옵션명
                NSString *optionName = option[@"dtlOptNm"];
                
                //옵션가 있을 경우
                if (![option[@"addPrc"] isEqualToString:@"0"]) {
                    optionName = [optionName stringByAppendingString:[NSString stringWithFormat:@" (+%@원)", [option[@"addPrc"] stringByInsertingComma]]];
                }
                
                CGSize size = [optionName sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGRectGetWidth(_optionTableView.frame)-(48+40), 10000) lineBreakMode:NSLineBreakByWordWrapping];
                
                rowHeight += size.height + 20;
            }
        }
    }
    
//    NSLog(@"height: %li, %f", (long)indexPath.row, rowHeight);
    
    return rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isAdditional) {
        return [self configureAdditionalOptionCell:tableView atIndexPath:indexPath];
    }
    else {
        return [self configureOptionCell:tableView atIndexPath:indexPath];
    }
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row) {
        [self stopLoadingAnimation];
    }
}

- (UITableViewCell *)configureOptionCell:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"OptionCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    [cell.contentView setBackgroundColor:UIColorFromRGB(0xf6f6f6)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    //옵션 타이틀
    NSString *name = self.options[indexPath.row][@"optItemNm"];
    
    CGSize nameSize = [name sizeWithFont:[UIFont systemFontOfSize:14]];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, nameSize.width, 35)];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel setFont:[UIFont systemFontOfSize:14]];
    [nameLabel setText:name];
    [nameLabel setTextColor:UIColorFromRGB(0x333333)];
    [nameLabel setTag:ProductOptionTagsNameLabel];
    [cell.contentView addSubview:nameLabel];
    
    // 옵셩항목구분 (01:조합형 ,02:독립형, 03:입력형)
    NSString *optClfCd = self.options[indexPath.row][@"optClfCd"];
    CGFloat lineY = 34;
    
    // 입력형은 비노출
    if ([@"03" isEqualToString:optClfCd]) {
        [nameLabel setHidden:YES];
    }
    else if ([@"01" isEqualToString:optClfCd] || [@"02" isEqualToString:optClfCd]) {
        [nameLabel setHidden:NO];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_optionTableView.frame)-21, 14.5f, 10, 6)];
        [arrowImageView setImage:(selectedIndex == indexPath.row ? [UIImage imageNamed:@"ic_optionbar_arrow_up_02.png"] : [UIImage imageNamed:@"ic_optionbar_arrow_down_01.png"])];
        [cell.contentView addSubview:arrowImageView];
        
        //        NSLog(@"selectedIndex: %i, %i", selectedIndex, indexPath.row);
    }
    
    NSString *selectedItemNm = self.options[indexPath.row][@"selectedItemNm"];
//    CGSize optionNameSize = [selectedItemNm sizeWithFont:[UIFont systemFontOfSize:14]];
    
    UILabel *selectedOptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame)+8, 0, CGRectGetWidth(self.optionTableView.frame)-(CGRectGetMaxX(nameLabel.frame)+8+25), 35)];
    [selectedOptionLabel setFont:[UIFont systemFontOfSize:14]];
    [selectedOptionLabel setTextColor:UIColorFromRGB(0x5460de)];
    [selectedOptionLabel setTag:ProductOptionTagsSelectedLabel];
    [selectedOptionLabel setText:(selectedItemNm ? selectedItemNm : @"")];
    [selectedOptionLabel setBackgroundColor:[UIColor clearColor]];
    [cell.contentView addSubview:selectedOptionLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, lineY, CGRectGetWidth(_optionTableView.frame), 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0xe5e5e5)];
    [cell.contentView addSubview:lineView];
    
    //상세옵션
    NSInteger optionCount;
    //    NSLog(@"searchingIndex: %i, selectedIndex: %i", searchingIndex, selectedIndex);
    if (isSearching && searchingIndex == indexPath.row) {
        optionCount = searchOptionsArray.count;
        
        //검색결과 없음
        if (searchOptionsArray.count == 0) {
            
            UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(nameLabel.frame), CGRectGetWidth(_optionTableView.frame), 61)];
            [noDataLabel setBackgroundColor:UIColorFromRGB(0xffffff)];
            [noDataLabel setText:@"검색어에 해당하는 옵션이 없습니다."];
            [noDataLabel setTextAlignment:NSTextAlignmentCenter];
            [noDataLabel setFont:[UIFont systemFontOfSize:13]];
            [noDataLabel setTextColor:UIColorFromRGB(0x999999)];
            [cell.contentView addSubview:noDataLabel];
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(nameLabel.frame)+60, CGRectGetWidth(_optionTableView.frame), 1)];
            [lineView setBackgroundColor:UIColorFromRGB(0xededed)];
            [cell.contentView addSubview:lineView];
        }
    }
    else {
        optionCount = [self.options[indexPath.row][@"optItemList"] count];
    }
    
    CGFloat optionContainerViewHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath] - 35;
    
    UIView *optionContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 35, CGRectGetWidth(_optionTableView.frame), optionContainerViewHeight)];
    [optionContainerView setHidden:(selectedIndex == indexPath.row ? NO : YES)];
    [optionContainerView setBackgroundColor:[UIColor clearColor]];
    [cell.contentView addSubview:optionContainerView];
    
    CGFloat optionViewY = 0;
    
    for (int i = 0; i < optionCount; i++) {
        
        NSDictionary *option;
        if (isSearching && searchingIndex == indexPath.row) {
            option = searchOptionsArray[i];
        }
        else {
            option = self.options[indexPath.row][@"optItemList"][i];
        }

        //선택된 옵션인지 체크
        BOOL isSelectedItem = NO;
        
        if (self.selectedItemArray.count > 0) {
            NSDictionary *selectedItem = self.selectedItemArray.lastObject;
            NSArray *compareOptNoArray = [selectedItem[@"compareOptNo"] componentsSeparatedByString:@","];
            
            //inputOptionCount 입력형옵션은 제외한 인덱스
            if (compareOptNoArray.count > 1 && [option[@"optNo"] isEqualToString:compareOptNoArray[indexPath.row-inputOptionCount]]) {
                isSelectedItem = YES;
//                NSLog(@"selectedItem: %@, %@", selectedItem[@"compareOptNo"], option[@"optNo"]);
                //                    break;
            }
            else if (compareOptNoArray.count == 1 && [option[@"optNo"] isEqualToString:selectedItem[@"compareOptNo"]]) {
                isSelectedItem = YES;
            }
        }
        
        if (isResetSelected) {
            isSelectedItem = NO;
        }
        
        if ([option[@"dtlOptNm"] isEqualToString:selectedOptionLabel.text]) {
            isSelectedItem = YES;
        }
        
//        NSLog(@"name:%@, %li, %li, reset:%@, selected:%@", name, (long)indexPath.row, (long)selectedIndex, isResetSelected?@"y":@"n", isSelectedItem?@"y":@"n");
        
        if (isSelectedItem) {
            [selectedOptionLabel setText:option[@"dtlOptNm"]];
        }
        
        //품절체크
        BOOL isSoldout = NO;
        if ((option[@"optNo"] && [option[@"optNo"] hasPrefix:self.selOptCnt]) && [@"0" isEqualToString:option[@"stckQty"]] && ![@"02" isEqualToString:optClfCd]) {
            isSoldout = YES;
        }
        
        //옵션명
        NSString *optionName = option[@"dtlOptNm"];
        
        //옵션가 있을 경우
        if (![option[@"addPrc"] isEqualToString:@"0"]) {
            NSString *plusString = @"";
            if ([option[@"addPrc"] integerValue] > 0) {
                plusString = @"+";
            }
            optionName = [optionName stringByAppendingString:[NSString stringWithFormat:@" (%@%@원)", plusString, [option[@"addPrc"] stringByInsertingComma]]];
        }
        
        CGSize size = [optionName sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGRectGetWidth(_optionTableView.frame)-(48+40), 10000) lineBreakMode:NSLineBreakByWordWrapping];
        
        CGFloat labelHeight = size.height + 20;
        
        UIView *optionView = [[UIView alloc] initWithFrame:CGRectMake(0, optionViewY, CGRectGetWidth(_optionTableView.frame), labelHeight)];
        [optionView setBackgroundColor:UIColorFromRGB(0xffffff)];
        [optionContainerView addSubview:optionView];
        
        optionViewY += labelHeight;
        
        //라디오버튼
        UIButton *radioButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [radioButton setBackgroundColor:[UIColor clearColor]];
        [radioButton setFrame:CGRectMake(9, (labelHeight-18)/2, 19, 18)];
        [radioButton setImage:[UIImage imageNamed:@"bt_optionbar_check_nor.png"] forState:UIControlStateNormal];
        [radioButton setImage:[UIImage imageNamed:@"bt_optionbar_check_press.png"] forState:UIControlStateSelected];
        [radioButton setSelected:isSelectedItem];
        [optionView addSubview:radioButton];
    
        //상세옵션명
        NZLabel *detailLabel =  [[NZLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(radioButton.frame)+10, 10, CGRectGetWidth(_optionTableView.frame)-(48+40), size.height)];
        [detailLabel setBackgroundColor:[UIColor clearColor]];
        [detailLabel setText:optionName];
        [detailLabel setTextColor:(isSoldout ? UIColorFromRGB(0x999999) : (isSelectedItem ? UIColorFromRGB(0x5460de) : UIColorFromRGB(0x333333)))];
        [detailLabel setFont:[UIFont systemFontOfSize:14]];
        [detailLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [detailLabel setNumberOfLines:3];
        [detailLabel setTag:ProductOptionTagsColorLabel];
        [optionView addSubview:detailLabel];
        
        if (self.searchWord.length > 0) {
            [detailLabel setFontColor:UIColorFromRGB(0x4957e3) string:self.searchWord];
        }
        
        //품절
        UILabel *soldoutLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(_optionTableView.frame)-32, 0, 25, labelHeight)];
        [soldoutLabel setText:@"품절"];
        [soldoutLabel setFont:[UIFont systemFontOfSize:14]];
        [soldoutLabel setTextColor:UIColorFromRGB(0x999999)];
        [optionView addSubview:soldoutLabel];
        
        if (isSoldout) {
            [soldoutLabel setHidden:NO];
        }
        else {
            [soldoutLabel setHidden:YES];
        }
        
        //옵션버튼
        UIButton *optionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [optionButton setBackgroundColor:[UIColor clearColor]];
        [optionButton setFrame:CGRectMake(0, 0, CGRectGetWidth(_optionTableView.frame), 35)];
        [optionButton setTitle:option[@"dtlOptNm"] forState:UIControlStateNormal];
        [optionButton.titleLabel setFont:[UIFont systemFontOfSize:0]];
        [optionButton addTarget:self action:@selector(touchOptionButton:) forControlEvents:UIControlEventTouchUpInside];
        [optionButton setTag:i];
        [optionView addSubview:optionButton];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, labelHeight-1, CGRectGetWidth(_optionTableView.frame), 1)];
        [lineView setBackgroundColor:UIColorFromRGB(0xededed)];
        [optionView addSubview:lineView];
    }
    
    return cell;
}

- (UITableViewCell *)configureAdditionalOptionCell:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"AdditionalOptionCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    [cell.contentView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSDictionary *option = self.options[indexPath.row];
    
    //선택된 옵션인지 체크
    BOOL isSelectedItem = NO;
    NSArray *optNoSeparator = [option[@"prdNo"] componentsSeparatedByString:@":"];
    
    if ((optNoSeparator && [optNoSeparator count] > 1 && [optNoSeparator[0] intValue] < [self.selOptCnt intValue])) {
        if (self.multiOptionDictionary && [self.multiOptionDictionary count] > 0) {
            NSDictionary *selectedOptNoDictionary = [self.multiOptionDictionary objectForKey:optNoSeparator[0]];
            
            if (selectedOptNoDictionary && selectedOptNoDictionary[@"optNo"] && [selectedOptNoDictionary[@"optNo"] isEqualToString:option[@"prdNo"]]) {
                isSelectedItem = YES;
            }
        }
    }
    else {
        for (NSDictionary *selectedItem in self.selectedItemArray) {
            NSString *compare = @"";
            
            if (self.optionType && ![@"03" isEqualToString:self.optionType]) {
                compare = [NSString stringWithFormat:@"%@%@", ![@"" isEqualToString:self.compareOptNo] ? [NSString stringWithFormat:@"%@,", self.compareOptNo] : @"", option[@"prdNo"]];
            }
            else {
                compare = option[@"prdNo"];
            }
            
            if ([selectedItem[@"compareOptNo"] isEqualToString:compare]) {
                isSelectedItem = YES;
                
                break;
            }
        }
    }
    
    //라디오버튼
    UIButton *radioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [radioButton setBackgroundColor:[UIColor clearColor]];
    [radioButton setFrame:CGRectMake(9, 8.5f, 19, 18)];
    [radioButton setImage:[UIImage imageNamed:@"bt_optionbar_check_nor.png"] forState:UIControlStateNormal];
    [radioButton setImage:[UIImage imageNamed:@"bt_optionbar_check_press.png"] forState:UIControlStateSelected];
    [radioButton setSelected:isSelectedItem];
    [cell.contentView addSubview:radioButton];
    
    //옵션 타이틀
    NSString *name = option[@"prdNm"];
    
    //옵션가 있을 경우
    if (![option[@"addCompPrc"] isEqualToString:@"0"]) {
        name = [name stringByAppendingString:[NSString stringWithFormat:@" (%@원)", [option[@"addCompPrc"] stringByInsertingComma]]];
    }
    
//    CGSize nameSize = [name sizeWithFont:[UIFont systemFontOfSize:14]];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(radioButton.frame)+10, 0, CGRectGetWidth(self.optionTableView.frame)-(CGRectGetMaxX(radioButton.frame)+20), 35)];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel setFont:[UIFont systemFontOfSize:14]];
    [nameLabel setText:name];
    [nameLabel setTextColor:(isSelectedItem ? UIColorFromRGB(0x5460de) : UIColorFromRGB(0x333333))];
    [nameLabel setTag:ProductOptionTagsNameLabel];
    [cell.contentView addSubview:nameLabel];
    
    //옵션버튼
    UIButton *optionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [optionButton setBackgroundColor:[UIColor clearColor]];
    [optionButton setFrame:CGRectMake(0, 0, CGRectGetWidth(_optionTableView.frame), 35)];
    [optionButton setTitle:name forState:UIControlStateNormal];
    [optionButton.titleLabel setFont:[UIFont systemFontOfSize:0]];
    [optionButton addTarget:self action:@selector(touchOptionButton:) forControlEvents:UIControlEventTouchUpInside];
    [optionButton setTag:indexPath.row];
    [cell.contentView addSubview:optionButton];

    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 34, CGRectGetWidth(_optionTableView.frame), 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0xe5e5e5)];
    [cell.contentView addSubview:lineView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (isKeyboardShown) {
        isEditing = NO;
        isKeyboardShown = NO;
        [self endEditing:YES];
        return;
    }
    
    if (self.searchWord) {
        isSearching = NO;
        searchingIndex = -1;
        self.searchWord = @"";
        [searchTextField setText:nil];
        [searchOptionsArray removeAllObjects];
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *selectedOptionLabel = (UILabel *)[cell viewWithTag:ProductOptionTagsSelectedLabel];
    
    //최소 한개의 옵션은 열려있어야 함
    if (nilCheck(selectedOptionLabel.text)) {
        NSInteger optionCount = [self.options[indexPath.row][@"optItemList"] count];
        NSInteger idx = [self.options[indexPath.row][@"optIdx"] integerValue];
        
        //        NSLog(@"searchingIndex: %i, selectedIndex: %i optionCount:%i idx:%i", searchingIndex, selectedIndex, optionCount, idx);
        
        if (idx == 1) {
            return;
        }
        else {
            if (optionCount == 0) {
                return;
            }
        }
    }
    
    if (selectedIndex == indexPath.row) {
        
        selectedIndex = -1;
        
        return;
    }
    
    if (selectedIndex >= 0) {
        selectedIndex = indexPath.row;
    }
    
    selectedIndex = indexPath.row;
    
    [_optionTableView reloadData];
}

#pragma mark - Privates Methods

- (void)setInputOptionCount
{
    inputOptionCount = 0;
    
    for (NSDictionary *option in self.options) {
        if ([@"03" isEqualToString:option[@"optClfCd"]]) {
            inputOptionCount++;
        }
    }
}

- (void)setSelectedIndex:(NSMutableArray *)originalOptions
{
    for (int i = 0; i < originalOptions.count; i++) {
        
        NSMutableDictionary *options = originalOptions[i];
        
        if ([options[@"optClfCd"] isEqualToString:@"01"] || [options[@"optClfCd"] isEqualToString:@"02"]) {
            selectedIndex = i;
            break;
        }
    }
}

- (void)filterProductOption:(NSMutableArray *)originalOptions keyword:(NSString *)keyword
{
    [searchOptionsArray removeAllObjects];
    
    for (int i = 0; i < originalOptions.count; i++) {
        NSMutableDictionary *option = originalOptions[i];
        
        NSString *text = option[@"dtlOptNm"];
        
        if (option[@"dtlOptNm"] && [[text lowercaseString] rangeOfString:[keyword lowercaseString]].location != NSNotFound) {
            //                        [filteredOption addObject:option];
            [searchOptionsArray addObject:option];
        }
    }
}

- (void)searchForProductOptionItems:(NSString *)word
{
    if (!word || !isSearching) {
        return;
    }
    
    self.searchWord = word;
    
    [self filterProductOption:self.options[selectedIndex][@"optItemList"] keyword:word];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
    [self.optionTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Selectors

- (void)closeOptionItemView:(id)sender
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)view;
            
            if ([textField resignFirstResponder]) {
                [textField setText:nil];
                
                return;
            }
        }
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        [self setAlpha:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
        if ([_optionDelegate respondsToSelector:@selector(didCloseOptionItem:)])
        {
            [_optionDelegate performSelector:@selector(didCloseOptionItem:) withObject:self];
        }
    }];
}

- (BOOL)isSelectedItem:(NSDictionary *)targetItem
{
    //
    BOOL isSelectedItem = NO;
    
    //상품 선택 완료시 이미 선택된 옵션인지 확인한다.
    for (NSDictionary *selectedItem in self.selectedItemArray) {
        NSString *compare = @"";
        
        if (self.optionType && ![@"03" isEqualToString:self.optionType]) {
            compare = [NSString stringWithFormat:@"%@%@", ![@"" isEqualToString:self.compareOptNo] ? [NSString stringWithFormat:@"%@,", self.compareOptNo] : @"", targetItem[@"optNo"]];
        }
        else {
            compare = targetItem[@"prdNo"];
        }
        
        if ([selectedItem[@"compareOptNo"] isEqualToString:compare]) {
            isSelectedItem = YES;
            break;
        }
    }
    
//    if (isSelectedItem) {
//        DEFAULT_ALERT(STR_APP_TITLE, @"이미 선택된 옵션입니다.");
//        return;
//    }
    return isSelectedItem;
}

- (void)touchOptionWithIndex:(NSInteger)optionIndex
{
    UITableViewCell *visibleCell = _optionTableView.visibleCells.firstObject;
    
    UIButton *button = (UIButton *)[visibleCell viewWithTag:optionIndex];
    
    [self touchOptionButton:button];
}

- (void)touchOptionButton:(id)sender
{
    NSLog(@"isKeyboardShown");
    if (isKeyboardShown) {
        isEditing = NO;
        isKeyboardShown = NO;
        [self endEditing:YES];
        NSLog(@"endEditing");
        return;
    }
    
    if (self.searchWord) {
        self.searchWord = nil;
        [searchTextField setText:nil];
    }
    
    [self startLoadingAnimation];
    
    UIButton *button = (UIButton *)sender;
    NSInteger optionIndex = button.tag;
    
    CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.optionTableView];
    NSIndexPath *indexPath = [self.optionTableView indexPathForRowAtPoint:buttonOriginInTableView];
    
    // 옵셩항목구분 (01:조합형 ,02:독립형, 03:입력형)
    //독립형 상품은(optionType = @"02") 옵션이 모두 선택되어 있다면 옵션을 하나씩 선택할때 마다 옵션이 완성됨
    NSString *optClfCd = self.options[indexPath.row][@"optClfCd"];
    BOOL isConfirm = [self isConfirmOption:self.options optionType:optClfCd index:indexPath.row];

    if (isSearching) {
        NSInteger rowCount = self.options.count;
        
        if (indexPath.row < rowCount-1) {
            selectedIndex = indexPath.row+1;
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            [_optionTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:previousIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
            [_optionTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:nextIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            NSDictionary *currentItem = searchOptionsArray[optionIndex];
            selectedRow = indexPath.row;
            
            isSearching = NO;
            
            if ([self.optionDelegate respondsToSelector:@selector(didSelectedOptionItem:item:selectedRow:isConfirm:)]) {
                
                if ((currentItem[@"optNo"] && [currentItem[@"optNo"] hasPrefix:self.selOptCnt]) && [@"0" isEqualToString:currentItem[@"stckQty"]] && ![@"02" isEqualToString:optClfCd]) {
                    [self stopLoadingAnimation];
                    return;
                }
                
                if ([self isSelectedItem:currentItem]) {
                    DEFAULT_ALERT(STR_APP_TITLE, @"이미 선택된 옵션입니다.");
                    [self stopLoadingAnimation];
                    return;
                }
                
                [self.optionDelegate didSelectedOptionItem:self item:currentItem selectedRow:selectedRow isConfirm:isConfirm];
                
                if ([@"02" isEqualToString:optClfCd]) {
                    [self.options[indexPath.row] setObject:currentItem[@"dtlOptNm"] forKey:@"selectedItemNm"];
                }
            }
            
            //선택된 옵션 표기
            UITableViewCell *cell = [_optionTableView cellForRowAtIndexPath:previousIndexPath];
            UILabel *selectedOptionLabel = (UILabel *)[cell.contentView viewWithTag:ProductOptionTagsSelectedLabel];
            [selectedOptionLabel setText:button.titleLabel.text];
        }
        else {
            NSDictionary *currentItem = searchOptionsArray[optionIndex];
            selectedRow = indexPath.row;

            if ([self.optionDelegate respondsToSelector:@selector(didSelectedOptionItem:item:selectedRow:isConfirm:)]) {
                
                if ((currentItem[@"optNo"] && [currentItem[@"optNo"] hasPrefix:self.selOptCnt]) && [@"0" isEqualToString:currentItem[@"stckQty"]] && ![@"02" isEqualToString:optClfCd]) {
                    [self stopLoadingAnimation];
                    return;
                }
                
                if ([self isSelectedItem:currentItem]) {
                    DEFAULT_ALERT(STR_APP_TITLE, @"이미 선택된 옵션입니다.");
                    [self stopLoadingAnimation];
                    return;
                }
                
                [self.optionDelegate didSelectedOptionItem:self item:currentItem selectedRow:selectedRow isConfirm:isConfirm];
                
                if ([@"02" isEqualToString:optClfCd]) {
                    [self.options[indexPath.row] setObject:currentItem[@"dtlOptNm"] forKey:@"selectedItemNm"];
                }
            }
        }
    }
    else {
        
        if (isAdditional) { //추가구성상품
            NSDictionary *currentItem = self.options[indexPath.row];
            selectedRow = indexPath.row;
            
            if ([self.optionDelegate respondsToSelector:@selector(didSelectedOptionItem:item:selectedRow:isConfirm:)]) {
                
                if ((currentItem[@"optNo"] && [currentItem[@"optNo"] hasPrefix:self.selOptCnt]) && [@"0" isEqualToString:currentItem[@"stckQty"]] && ![@"02" isEqualToString:optClfCd]) {
                    [self stopLoadingAnimation];
                    return;
                }
                
                if ([self isSelectedItem:currentItem]) {
                    DEFAULT_ALERT(STR_APP_TITLE, @"이미 선택된 옵션입니다.");
                    [self stopLoadingAnimation];
                    return;
                }
                
                //추가구성상품의 selectedRow 은 0
                [self.optionDelegate didSelectedOptionItem:self item:currentItem selectedRow:0 isConfirm:isConfirm];
                
                if ([@"02" isEqualToString:optClfCd]) {
                    [self.options[indexPath.row] setObject:currentItem[@"dtlOptNm"] forKey:@"selectedItemNm"];
                }
            }
        }
        else {
            NSInteger rowCount = self.options.count;
            
            if (indexPath.row < rowCount-1) {
                selectedIndex = indexPath.row+1;
                
                NSDictionary *currentItem = self.options[indexPath.row][@"optItemList"][optionIndex];
                selectedRow = indexPath.row;
                
                //선택된 옵션이 아닌 것을 선택하면 하위 옵션들은 초기화
                isResetSelected = YES;
                
                if (self.selectedItemArray.count > 0) {
                    NSDictionary *selectedItem = self.selectedItemArray.lastObject;
                    NSArray *compareOptNoArray = [selectedItem[@"compareOptNo"] componentsSeparatedByString:@","];
                    
                    //inputOptionCount 입력형옵션은 제외한 인덱스
                    if (compareOptNoArray.count > 1 && [currentItem[@"optNo"] isEqualToString:compareOptNoArray[indexPath.row-inputOptionCount]]) {
                        isResetSelected = NO;
                        NSLog(@"selectedItem: %@, %@", selectedItem[@"compareOptNo"], currentItem[@"optNo"]);
                        //                    break;
                    }
                }
                
                for (NSInteger i = indexPath.row; i < rowCount-1; i++) {
                    
                    if (i == indexPath.row) {
                        //선택된 옵션 표기
                        UITableViewCell *cell = [self.optionTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                        UILabel *selectedOptionLabel = (UILabel *)[cell.contentView viewWithTag:ProductOptionTagsSelectedLabel];
                        [selectedOptionLabel setText:([button isKindOfClass:[UIButton class]] ? button.titleLabel.text : @"")];
                    }
                    
                    NSIndexPath *targetIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [self.optionTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:targetIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                }
                
//                NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
//                [_optionTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:previousIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//                
//                NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
//                [_optionTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:nextIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                
                
                if ([self.optionDelegate respondsToSelector:@selector(didSelectedOptionItem:item:selectedRow:isConfirm:)]) {
                    
                    if ((currentItem[@"optNo"] && [currentItem[@"optNo"] hasPrefix:self.selOptCnt]) && [@"0" isEqualToString:currentItem[@"stckQty"]] && ![@"02" isEqualToString:optClfCd]) {
                        [self stopLoadingAnimation];
                        return;
                    }
                    
                    if ([self isSelectedItem:currentItem]) {
                        DEFAULT_ALERT(STR_APP_TITLE, @"이미 선택된 옵션입니다.");
                        [self stopLoadingAnimation];
                        return;
                    }
                    
                    [self.optionDelegate didSelectedOptionItem:self item:currentItem selectedRow:selectedRow isConfirm:isConfirm];
                    
                    if ([@"02" isEqualToString:optClfCd]) {
                        [self.options[indexPath.row] setObject:currentItem[@"dtlOptNm"] forKey:@"selectedItemNm"];
                    }
                }
                
//                //선택된 옵션 표기
//                UITableViewCell *cell = [_optionTableView cellForRowAtIndexPath:previousIndexPath];
//                UILabel *selectedOptionLabel = (UILabel *)[cell.contentView viewWithTag:ProductOptionTagsSelectedLabel];
//                [selectedOptionLabel setText:button.titleLabel.text];
            }
            else {
                NSDictionary *currentItem = self.options[indexPath.row][@"optItemList"][optionIndex];
                selectedRow = indexPath.row;
                
                if ([self.optionDelegate respondsToSelector:@selector(didSelectedOptionItem:item:selectedRow:isConfirm:)]) {
                    
                    if ((currentItem[@"optNo"] && [currentItem[@"optNo"] hasPrefix:self.selOptCnt]) && [@"0" isEqualToString:currentItem[@"stckQty"]] && ![@"02" isEqualToString:optClfCd]) {
                        [self stopLoadingAnimation];
                        return;
                    }
                    
                    if ([self isSelectedItem:currentItem]) {
                        DEFAULT_ALERT(STR_APP_TITLE, @"이미 선택된 옵션입니다.");
                        [self stopLoadingAnimation];
                        return;
                    }
                    
                    [self.optionDelegate didSelectedOptionItem:self item:currentItem selectedRow:selectedRow isConfirm:isConfirm];
                    
                    if ([@"02" isEqualToString:optClfCd]) {
                        [self.options[indexPath.row] setObject:currentItem[@"dtlOptNm"] forKey:@"selectedItemNm"];
                    }
                }
            }
        }
    }
    
    //AccessLog - 옵션서랍 - 옵션선택(선택형)
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"MPG0103"];
}

- (BOOL)isConfirmOption:(NSArray *)options optionType:(NSString *)optionType index:(NSInteger)index
{
    BOOL isConfirm = YES;
    NSInteger rowCount = options.count;
    
    //선택형 옵션만 필터링
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"optClfCd == '01' || optClfCd == '02'"];
    NSArray *filteredArray = [options filteredArrayUsingPredicate:predicate];
    
    //옵셩항목구분 (01:조합형 ,02:독립형, 03:입력형)
    //독립형 상품은 옵션이 모두 선택되어 있다면 옵션을 하나씩 선택할때 마다 옵션이 완성됨
    if ([@"02" isEqualToString:optionType]) {
        isConfirm = [self isAllSelectedIndipendentOption:filteredArray];
    }
    else if (isAdditional) {
        isConfirm = YES;
    }
    else { //일반 상품
        if (index < rowCount-1) {
            isConfirm = NO;
        }
        else {
            isConfirm = YES;
        }
    }
    
    return isConfirm;
}

- (BOOL)isAllSelectedIndipendentOption:(NSArray *)array
{
    if (!array) return NO;
    
    //독립형 옵션 확인
    NSInteger tIndipendentOptionCount = 0;
    NSInteger tIdipendentSelectCount = 0;
    for (int i=0; i<array.count; i++) {
        NSString *tOptClfCd = [[array objectAtIndex:i] objectForKey:@"optClfCd"];
        NSString *tSelectItemNm = [[array objectAtIndex:i] objectForKey:@"selectedItemNm"];
        
        if ([@"02" isEqualToString:tOptClfCd]) {
            tIndipendentOptionCount++;
            
            if (tSelectItemNm && [[tSelectItemNm trim] length] > 0) {
                tIdipendentSelectCount++;
            }
        }
    }
    
    return tIdipendentSelectCount >= tIndipendentOptionCount - 1 ? YES : NO;
}

- (void)touchCloseDrawerButton
{
    [self closeOptionItemView:nil];
    
    if ([self.optionDelegate respondsToSelector:@selector(didTouchCloseDrawerButton)]) {
        [self.optionDelegate didTouchCloseDrawerButton];
    }
}

- (void)touchOpenDrawerButton
{
    if ([self.optionDelegate respondsToSelector:@selector(didTouchCloseDrawerButton)]) {
        [self.optionDelegate didTouchOpenDrawerButton];
    }
}

- (void)onClickKeyboardDown:(id)sender
{
    [self keyboardHide];
}


#pragma mark - UITextField Delegate

- (void)textFieldTextDidChanged:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)[notification object];
    
    if (textField.tag == ProductOptionTagsSearch) {
        if ([@"" isEqualToString:[textField text]]) {
            
            isSearching = NO;
            self.searchWord = @"";
            searchingIndex = -1;
            [searchOptionsArray removeAllObjects];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
            [self.optionTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else {
            isSearching = YES;
            searchingIndex = selectedIndex;
        }
        
        [self searchForProductOptionItems:[[textField text] trim]];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (!isEditing) {
        isEditing = YES;
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == ProductOptionTagsSearch) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
        
        //        isSearching = NO;
    }
    else {
        activeTextField = textField;
    }
    
    isKeyboardShown = YES;
}

//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    if (textField.tag == ProductOptionTagsSearch) {
//        //        isSearching = NO;
//        
//        [textField setText:nil];
//        [textField resignFirstResponder];
//    }
//    else {
//        if (activeTextField) {
////            if ([self.delegate respondsToSelector:@selector(optionItem:textFieldShouldReturn:selectedRow:)]) {
////                [self.delegate optionItem:self textFieldShouldReturn:activeTextField.text selectedRow:activeTextField.tag];
////            }
//        }
//        
//        [textField resignFirstResponder];
//    }
//    
//    return YES;
//}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == ProductOptionTagsSearch) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
        
        //        isSearching = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == ProductOptionTagsSearch) {
        //        isSearching = NO;
        
//        [textField setText:nil];
        [textField resignFirstResponder];
        
        //AccessLog - 옵션서랍 - 옵션검색
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"MPG0101"];
    }
    else {
//        if ([self.delegate respondsToSelector:@selector(optionItem:textFieldShouldReturn:selectedRow:)]) {
//            [self.delegate optionItem:self textFieldShouldReturn:textField.text selectedRow:textField.tag];
//        }
        
        [textField resignFirstResponder];
    }
    
    isEditing = NO;
    
    return YES;
}

#pragma mark - Keyboard Notification

- (void)keyboardWillShow:(NSNotification *)noti
{
    CGRect keyboardFrame = [[[noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    NSNumber *durationValue = [noti userInfo][UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    
    NSNumber *curveValue = [noti userInfo][UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    
    beforeRectKeyboardShowSelfView = self.frame;
    beforeRectKeyboardShowOptionTableView = self.optionTableView.frame;
    beforeRectKeyboardShowOptionBottomView = self.optionBottomView.frame;
    
    
    [self.optionBottomView setFrame:CGRectMake(0, self.frame.size.height - _keyboardToolView.frame.size.height, self.frame.size.width, 0)];
    [self.optionBottomView setAlpha:0.f];
    
    [UIView animateWithDuration:animationDuration delay:0 options:(animationCurve << 16) animations:^{
        [self setFrame:CGRectMake(0, self.openOffset, self.frame.size.width, self.superviewFrame.size.height - self.openOffset - keyboardFrame.size.height)];
        [self.keyboardToolView setFrame:CGRectMake(0, self.frame.size.height - _keyboardToolView.frame.size.height, _keyboardToolView.frame.size.width, _keyboardToolView.frame.size.height)];
        [self.optionTableView setFrame:CGRectMake(self.optionTableView.frame.origin.x,
                                                  self.optionTableView.frame.origin.y,
                                                  self.optionTableView.frame.size.width,
                                                  self.frame.size.height-_keyboardToolView.frame.size.height-self.optionTableView.frame.origin.y)];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillHide:(NSNotification *)noti
{
    NSNumber *durationValue = [noti userInfo][UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    
    NSNumber *curveValue = [noti userInfo][UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    
    [UIView animateWithDuration:animationDuration delay:0 options:(animationCurve << 16) animations:^{
        if (CGRectEqualToRect(beforeRectKeyboardShowSelfView, CGRectZero))
        {
            [self setFrame:CGRectMake(0, self.superviewFrame.size.height - self.openMinimumHeight, self.frame.size.width, self.openMinimumHeight)];
        }
        else
        {
            [self setFrame:beforeRectKeyboardShowSelfView];
        }
        
        [self.keyboardToolView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, _keyboardToolView.frame.size.width, _keyboardToolView.frame.size.height)];
        
        if (CGRectEqualToRect(beforeRectKeyboardShowOptionBottomView, CGRectZero))
        {
            [self.optionBottomView setFrame:CGRectMake(0, self.frame.size.height - _optionBottomView.frame.size.height, self.frame.size.width, _optionBottomView.frame.size.height)];
        }
        else
        {
            [self.optionBottomView setFrame:beforeRectKeyboardShowOptionBottomView];
        }
        [self.optionBottomView setAlpha:1.f];
        
        if (CGRectEqualToRect(beforeRectKeyboardShowSelfView, CGRectZero))
        {
            [self.optionTableView setFrame:CGRectMake(10.f, 29.f, self.frame.size.width - 20.f, self.frame.size.height - 126.f)];
        }
        else
        {
            [self.optionTableView setFrame:beforeRectKeyboardShowOptionTableView];
        }
    } completion:^(BOOL finished) {
        beforeRectKeyboardShowSelfView = CGRectZero;
        beforeRectKeyboardShowOptionTableView = CGRectZero;
        beforeRectKeyboardShowOptionBottomView = CGRectZero;
    }];
}

- (void)keyboardHide
{
    UIWindow *tempWindow;
    
    for (int j = 0; j < [[[UIApplication sharedApplication] windows] count]; j++)
    {
        tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:j];
        
        for (int i = 0; i < [tempWindow.subviews count]; i++)
        {
            [self keyboardHide:[tempWindow.subviews objectAtIndex:i]];
        }
    }
}

- (void)keyboardHide:(UIView *)view
{
    if ([view conformsToProtocol:@protocol(UITextInputTraits)]) {
        [view resignFirstResponder];
    }
    
    if ([view.subviews count] > 0) {
        for (NSInteger i = 0 ; i < [view.subviews count]; i++) {
            [self keyboardHide:[view.subviews objectAtIndex:i]];
        }
    }
}

#pragma mark - CPLoadingView

- (void)startLoadingAnimation
{
    [self addSubview:loadingView];
    [self bringSubviewToFront:loadingView];
    [loadingView setHidden:NO];
    [loadingView startAnimation];
}

- (void)stopLoadingAnimation
{
    [loadingView stopAnimation];
    [loadingView setHidden:YES];
//    [loadingView removeFromSuperview];
}

@end
