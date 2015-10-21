#import "CPProductOptionItem.h"
#import "CPWebView.h"
#import "Common.h"
#import "Modules.h"
#import "ColorLabel.h"
#import "CPProductOption.h"
#import "CPCommonInfo.h"
#import "CPProductOptionLoadingView.h"
#import "SBJSON.h"
#import "AccessLog.h"
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSUInteger, ProductOptionTags) {
    ProductOptionTagsNameLabel = 1300,
    ProductOptionTagsSelectedLabel,
    ProductOptionTagsRadioImageView,
    ProductOptionTagsColorLabel,
    ProductOptionTagsSearch
};

@interface CPProductOptionItem () <UITableViewDataSource,
                                UITableViewDelegate,
                                UITextFieldDelegate>
{
    UITableView *itemTableView;
    
    NSMutableArray *searchOptionsArray;
    
    BOOL isSearching;
    BOOL isEditing;
    BOOL isKeyboardShown;
    
    NSInteger selectedRow;
    NSInteger selectedIndex;
    NSInteger searchingIndex;
    
    BOOL isOpenChild;
    
    UITextField *activeTextField;
    
    UIImageView *optionBarImageView;
    UIImageView *optionBarLineImageView;
    UIView *backgroundView;
    UIView *lineBackgroundView;
    
    UIButton *drawerButton;
    UIButton *optionBarButton;
    
    CPProductOptionLoadingView *loadingView;
}

@end

@implementation CPProductOptionItem

@synthesize delegate;
@synthesize searchWord;
@synthesize productOptionInfo;


- (id)initWithFrame:(CGRect)frame productOptionRawData:(NSDictionary *)productOptionRawData
{
    if ((self = [super initWithFrame:frame])) {
        
        searchingIndex = -1;
        
        searchOptionsArray = [NSMutableArray array];
        
        [self setSelectedIndex:[NSMutableDictionary dictionaryWithDictionary:productOptionRawData]];
        
        [self initProductOptionInfo:productOptionRawData];
        
        [self initLayout];
    }
    
    return self;
}

- (void)reloadOptionItemView:(NSDictionary *)productOptionRawData
{
    [self stopLoadingAnimation];
    
    [self initProductOptionInfo:productOptionRawData];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
    [itemTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)initProductOptionInfo:(NSDictionary *)productOptionRawData
{
    productOptionInfo = [NSMutableDictionary dictionaryWithDictionary:productOptionRawData];
    
    productOptionInfo = [self removeBlankOption:productOptionInfo];
}

- (void)initLayout
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    //옵션 바
    UIImage *imgOptionBarBtn = [UIImage imageNamed:@"option_bar_bg"];
    UIImage *imgOptionBarLine = [UIImage imageNamed:@"option_line_bg"];
    
    optionBarImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width/2)-(imgOptionBarBtn.size.width/2),
                                                                       0,
                                                                       imgOptionBarBtn.size.width,
                                                                       imgOptionBarBtn.size.height)];
    [optionBarImageView setImage:imgOptionBarBtn];
    [optionBarImageView setUserInteractionEnabled:YES];
    [self addSubview:optionBarImageView];
    
    optionBarLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                           CGRectGetMaxY(optionBarImageView.frame),
                                                                           CGRectGetWidth(self.frame),
                                                                           imgOptionBarLine.size.height)];
    [optionBarLineImageView setImage:imgOptionBarLine];
    [self addSubview:optionBarLineImageView];
    
    UILabel *optionBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, 0, 50, CGRectGetHeight(optionBarImageView.frame))];
    [optionBarLabel setText:@"옵션선택"];
    [optionBarLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [optionBarLabel setTextColor:UIColorFromRGB(0xffffff)];
    [optionBarLabel setBackgroundColor:[UIColor clearColor]];
    [optionBarImageView addSubview:optionBarLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(optionBarLabel.frame)+8, 7.5f, 1, 13)];
    [lineView setBackgroundColor:UIColorFromRGB(0x758aef)];
    [optionBarImageView addSubview:lineView];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lineView.frame), 7.5f, 1, 13)];
    [lineView setBackgroundColor:UIColorFromRGB(0x4960d3)];
    [optionBarImageView addSubview:lineView];
    
    drawerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [drawerButton setImage:[UIImage imageNamed:@"option_down_nor.png"] forState:UIControlStateNormal];
    [drawerButton setFrame:CGRectMake(CGRectGetMaxX(lineView.frame)+7, 7.5f, 19, 13)];
    [optionBarImageView addSubview:drawerButton];
    
    optionBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [optionBarButton setFrame:CGRectMake(0, 0, CGRectGetWidth(optionBarImageView.frame), CGRectGetHeight(optionBarImageView.frame))];
    [optionBarButton addTarget:self action:@selector(touchCloseDrawerButton) forControlEvents:UIControlEventTouchUpInside];
    [optionBarButton setAccessibilityLabel:@"주문옵션창열기" Hint:@"주문하기 옵션 창을 엽니다"];
    [optionBarImageView addSubview:optionBarButton];
    
    //옵션
    backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                              CGRectGetMaxY(optionBarLineImageView.frame),
                                                              CGRectGetWidth(self.frame),
                                                              CGRectGetHeight(self.frame)-(CGRectGetHeight(optionBarImageView.frame)+CGRectGetHeight(optionBarLineImageView.frame)))];
    [backgroundView setBackgroundColor:UIColorFromRGB(0xeeeeee)];
    [self addSubview:backgroundView];
    
    lineBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(10,
                                                                  CGRectGetMaxY(optionBarLineImageView.frame)+10,
                                                                  CGRectGetWidth(self.frame)-20,
                                                                  CGRectGetHeight(self.frame)-(CGRectGetHeight(optionBarImageView.frame)+CGRectGetHeight(optionBarLineImageView.frame)+20))];
    [lineBackgroundView setBackgroundColor:UIColorFromRGB(0x5d5fd6)];
    [self addSubview:lineBackgroundView];
    
    //옵션 테이블뷰
    itemTableView = [[UITableView alloc] initWithFrame:CGRectMake(1, 1, CGRectGetWidth(lineBackgroundView.frame)-2, CGRectGetHeight(lineBackgroundView.frame)-2) style:UITableViewStylePlain];
    [itemTableView setDelegate:self];
    [itemTableView setDataSource:self];
    [itemTableView setBackgroundColor:UIColorFromRGB(0xeeeeee)];
    [itemTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [lineBackgroundView addSubview:itemTableView];
    
    //테이블 헤더
    [self setTableHeaderView];
    
    //LoadingView
    loadingView = [[CPProductOptionLoadingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2-20,
                                                                               CGRectGetHeight(self.frame)/2-20,
                                                                               40,
                                                                               40)];
}

- (void)redrawTableContainerFrame:(CGRect)frame
{
    //    NSLog(@"redrawTableContainerFrame:%@, %@", NSStringFromCGRect(frame), NSStringFromCGRect(self.frame));
    [backgroundView setFrame:CGRectMake(0,
                                        CGRectGetMaxY(optionBarLineImageView.frame),
                                        CGRectGetWidth(frame),
                                        CGRectGetHeight(frame)-(CGRectGetHeight(optionBarImageView.frame)+CGRectGetHeight(optionBarLineImageView.frame)))];
    
    [lineBackgroundView setFrame:CGRectMake(10,
                                            CGRectGetMaxY(optionBarLineImageView.frame)+10,
                                            CGRectGetWidth(frame)-20,
                                            CGRectGetHeight(frame)-(CGRectGetHeight(optionBarImageView.frame)+CGRectGetHeight(optionBarLineImageView.frame)+20))];
    
    [itemTableView setFrame:CGRectMake(1, 1, CGRectGetWidth(lineBackgroundView.frame)-2, CGRectGetHeight(lineBackgroundView.frame)-2)];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Selectors

- (void)onClickCancel:(id)sender
{
    isSearching = NO;
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)view;
            
            if ([textField resignFirstResponder]) {
                [textField setText:nil];
                
                return;
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(optionItemDidCancel:)]) {
        [self.delegate optionItemDidCancel:self];
    }
}

- (NSMutableDictionary *)removeBlankOption:(NSMutableDictionary *)originalOption
{
    for (NSMutableDictionary *options in originalOption[@"options"]) {
        NSMutableArray *filteredOption = [NSMutableArray array];
        
        for (NSDictionary *option in options[@"option"]) {
            if (![option[@"value"] isEqualToString:@""]) {
                [filteredOption addObject:option];
            }
        }
        
        [options setObject:filteredOption forKey:@"option"];
    }
    
    return originalOption;
}

- (void)setSelectedIndex:(NSMutableDictionary *)originalOption
{
    for (int i = 0; i < [originalOption[@"options"] count]; i++) {
        
        NSMutableDictionary *options = originalOption[@"options"][i];
        
        if ([options[@"dispType"] isEqualToString:@"select"]) {
            selectedIndex = i;
            break;
        }
    }
}

- (void)filterProductOption:(NSMutableDictionary *)originalOption keyword:(NSString *)keyword
{
    [searchOptionsArray removeAllObjects];
    
    for (int i = 0; i < [originalOption[@"options"] count]; i++) {
        if (i == selectedIndex) {
            NSMutableDictionary *options = originalOption[@"options"][i];
            
            for (NSDictionary *option in options[@"option"]) {
                
                NSString *text = option[@"text"];
                
                if (option[@"text"] && [[text lowercaseString] rangeOfString:[keyword lowercaseString]].location != NSNotFound) {
                    //                        [filteredOption addObject:option];
                    [searchOptionsArray addObject:option];
                }
            }
            //            [options setObject:filteredOption forKey:@"option"];
        }
        
    }
}

- (void)searchForProductOptionItems:(NSString *)word
{
    if (!word || !isSearching) {
        return;
    }
    
    self.searchWord = word;
    
    [self filterProductOption:productOptionInfo keyword:word];
    
    [itemTableView reloadData];
}

- (BOOL)isConfirmOption:(NSArray *)options optionType:(NSString *)optionType index:(NSInteger)index
{
    BOOL isConfirm = YES;
    NSInteger rowCount = options.count;
    
    //선택형 옵션만 필터링
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dispType == 'select'"];
    NSArray *filteredArray = [options filteredArrayUsingPredicate:predicate];
    
    //독립형 상품은 옵션이 모두 선택되어 있다면 옵션을 하나씩 선택할때 마다 옵션이 완성됨
    if ([@"02" isEqualToString:optionType]) {
        for (int i = 0; i < filteredArray.count; i++) {
            NSInteger newIndex = index-(options.count-filteredArray.count);
            NSDictionary *option = filteredArray[i];
            if (([option[@"selectedValue"] isEqualToString:@""] || [option[@"selectedText"] isEqualToString:@""]) && i != newIndex) {
                isConfirm = NO;
                break;
            }
        }
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

- (void)touchOptionButton:(id)sender
{
    if (isKeyboardShown) {
        isEditing = NO;
        isKeyboardShown = NO;
        [self endEditing:YES];
        return;
    }
    
    [self startLoadingAnimation];
    
    UIButton *button = (UIButton *)sender;
    NSInteger optionIndex = button.tag;
    
    CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:itemTableView];
    NSIndexPath *indexPath = [itemTableView indexPathForRowAtPoint:buttonOriginInTableView];
    
    //독립형 상품은(optionType = @"02") 옵션이 모두 선택되어 있다면 옵션을 하나씩 선택할때 마다 옵션이 완성됨
    NSString *optionType = productOptionInfo[@"optionType"];
    BOOL isConfirm = [self isConfirmOption:productOptionInfo[@"options"] optionType:optionType index:indexPath.row];
    
    if (isSearching) {
        NSInteger rowCount = [productOptionInfo[@"options"] count];
        
        if (indexPath.row < rowCount-1) {
            selectedIndex = indexPath.row+1;
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            [itemTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:previousIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
            [itemTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:nextIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            NSDictionary *currentItem = searchOptionsArray[optionIndex];
            selectedRow = indexPath.row;
            
            isSearching = NO;
            
            [self.delegate optionItem:self didSelectOptionItem:currentItem selectedRow:indexPath.row isConfirm:isConfirm];
            
            //선택된 옵션 표기
            UITableViewCell *cell = [itemTableView cellForRowAtIndexPath:previousIndexPath];
            
            UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:ProductOptionTagsNameLabel];
            UILabel *selectedOptionLabel = (UILabel *)[cell.contentView viewWithTag:ProductOptionTagsSelectedLabel];
            
            CGSize optionNameSize = [button.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:14]];
            
            [selectedOptionLabel setFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame)+8, 0, optionNameSize.width, 35)];
            [selectedOptionLabel setText:button.titleLabel.text];
        }
        else {
            NSDictionary *currentItem = searchOptionsArray[optionIndex];
            selectedRow = indexPath.row;
            
            [self.delegate optionItem:self didSelectOptionItem:currentItem selectedRow:indexPath.row isConfirm:isConfirm];
        }
    }
    else {
        NSInteger rowCount = [productOptionInfo[@"options"] count];
        
        if (indexPath.row < rowCount-1) {
            selectedIndex = indexPath.row+1;
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            [itemTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:previousIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
            [itemTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:nextIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            NSDictionary *currentItem = productOptionInfo[@"options"][indexPath.row][@"option"][optionIndex];
            selectedRow = indexPath.row;
            
            [self.delegate optionItem:self didSelectOptionItem:currentItem selectedRow:indexPath.row isConfirm:isConfirm];
            
            //선택된 옵션 표기
            UITableViewCell *cell = [itemTableView cellForRowAtIndexPath:previousIndexPath];
            
            UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:ProductOptionTagsNameLabel];
            UILabel *selectedOptionLabel = (UILabel *)[cell.contentView viewWithTag:ProductOptionTagsSelectedLabel];
            
            CGSize optionNameSize = [button.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:14]];
            
            [selectedOptionLabel setFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame)+8, 0, optionNameSize.width, 35)];
            [selectedOptionLabel setText:button.titleLabel.text];
        }
        else {
            NSDictionary *currentItem = productOptionInfo[@"options"][indexPath.row][@"option"][optionIndex];
            selectedRow = indexPath.row;
            
            [self.delegate optionItem:self didSelectOptionItem:currentItem selectedRow:indexPath.row isConfirm:isConfirm];
        }
    }
    
    //AccessLog - 옵션서랍 - 옵션선택(선택형)
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"MPG0103"];
}

- (void)touchCloseDrawerButton
{
    if ([self.delegate respondsToSelector:@selector(didTouchCloseDrawerButton)]) {
        [drawerButton setImage:[UIImage imageNamed:@"option_up_nor.png"] forState:UIControlStateNormal];
        [optionBarButton addTarget:self action:@selector(touchOpenDrawerButton) forControlEvents:UIControlEventTouchUpInside];
        
        [self.delegate didTouchCloseDrawerButton];
    }
}

- (void)touchOpenDrawerButton
{
    if ([self.delegate respondsToSelector:@selector(didTouchCloseDrawerButton)]) {
        [drawerButton setImage:[UIImage imageNamed:@"option_down_nor.png"] forState:UIControlStateNormal];
        [optionBarButton addTarget:self action:@selector(touchCloseDrawerButton) forControlEvents:UIControlEventTouchUpInside];
        
        [self.delegate didTouchOpenDrawerButton];
    }
}

#pragma mark - UITableView Delegate

- (void)setTableHeaderView
{
    CGFloat headerViewHeight = 84;
    
    //날짜형 상품은(isDateType = "Y") 검색 노출 안함
    NSString *isDateType = productOptionInfo[@"isDateType"];
    if ([@"Y" isEqualToString:isDateType]) {
        headerViewHeight = 32;
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(itemTableView.frame), headerViewHeight)];
    [headerView setBackgroundColor:UIColorFromRGB(0xffffff)];
    
    UIView *selectView = [[UIView alloc] initWithFrame:CGRectMake(-1, -1, CGRectGetWidth(itemTableView.frame)-28.5f, 32)];
    [selectView.layer setBorderWidth:1];
    [selectView.layer setBorderColor:UIColorFromRGB(0x5d5fd6).CGColor];
    [headerView addSubview:selectView];
    
    UILabel *selectLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(itemTableView.frame)-42, 32)];
    [selectLabel setText:@"옵션을 선택해 주세요"];
    [selectLabel setTextColor:UIColorFromRGB(0x5d5fd6)];
    [selectLabel setFont:[UIFont systemFontOfSize:13]];
    [selectView addSubview:selectLabel];
    
    UIButton *arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [arrowButton setFrame:CGRectMake(CGRectGetWidth(itemTableView.frame)-30, -1, 32, 32)];
    [arrowButton setImage:[UIImage imageNamed:@"option_btn_select_on.png"] forState:UIControlStateNormal];
    [arrowButton addTarget:self action:@selector(onClickCancel:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:arrowButton];
    
    UIButton *blankButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [blankButton setFrame:selectView.frame];
    [blankButton addTarget:self action:@selector(onClickCancel:) forControlEvents:UIControlEventTouchUpInside];
    [blankButton setTag:0];
    [headerView addSubview:blankButton];
    
    //날짜형이 아닌 경우 검색 노출
    if (![@"Y" isEqualToString:isDateType]) {
        UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(selectView.frame), CGRectGetWidth(itemTableView.frame), 52)];
        [searchView setBackgroundColor:UIColorFromRGB(0x8d96e3)];
        [headerView addSubview:searchView];
        
        UIView *leftInsetView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 32)];
        [leftInsetView setBackgroundColor:[UIColor clearColor]];
        
        NSAttributedString *placeholderAttribute = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"ProductOptionSearchHint", nil)
                                                                                   attributes:@{
                                                                                                NSForegroundColorAttributeName: UIColorFromRGB(0x868ba8), NSFontAttributeName: [UIFont systemFontOfSize:13] }];
        
        UITextField *searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(searchView.frame)-20, 32)];
        [searchTextField setDelegate:self];
        [searchTextField setLeftView:leftInsetView];
        [searchTextField setReturnKeyType:UIReturnKeyDone];
        [searchTextField setBorderStyle:UITextBorderStyleNone];
        [searchTextField setTextColor:UIColorFromRGB(0x868bab)];
        [searchTextField setFont:[UIFont systemFontOfSize:13]];
        [searchTextField setBackgroundColor:[UIColor whiteColor]];
        [searchTextField setLeftViewMode:UITextFieldViewModeAlways];
        [searchTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [searchTextField.layer setBorderColor:UIColorFromRGB(0x5d5fd6).CGColor];
        [searchTextField.layer setBorderWidth:1.0f];
        [searchTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [searchTextField setAttributedPlaceholder:placeholderAttribute];
        [searchTextField setTag:ProductOptionTagsSearch];
        [searchView addSubview:searchTextField];
    }
    
    [itemTableView setTableHeaderView:headerView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = [productOptionInfo[@"options"] count];
    
    return rowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 35;
    
    NSString *displayType = productOptionInfo[@"options"][indexPath.row][@"dispType"];
    
    // 입력형은 비노출
    if ([@"input" isEqualToString:displayType]) {
        rowHeight = 0;
    }
    else {
        if(selectedIndex == indexPath.row) {
            
            NSInteger optionCount;
            if (isSearching && searchingIndex == indexPath.row) {
                optionCount = searchOptionsArray.count;
            }
            else {
                optionCount = [productOptionInfo[@"options"][indexPath.row][@"option"] count];
            }
            
            for (int i = 0; i < optionCount; i++) {
                
                NSDictionary *option;
                if (isSearching && searchingIndex == indexPath.row) {
                    option = searchOptionsArray[i];
                }
                else {
                    option = productOptionInfo[@"options"][indexPath.row][@"option"][i];
                }
                
                CGSize size = [option[@"text"] sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(CGRectGetWidth(itemTableView.frame)-48, 10000) lineBreakMode:NSLineBreakByWordWrapping];
                
                rowHeight += size.height + 20;
            }
        }
    }
    
    return rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SelectProductOptionCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    [cell.contentView setBackgroundColor:UIColorFromRGB(0xeeeeee)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    //옵션 타이틀
    NSString *name = productOptionInfo[@"options"][indexPath.row][@"label"];
    
    CGSize nameSize = [name sizeWithFont:[UIFont systemFontOfSize:14]];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, nameSize.width, 35)];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel setFont:[UIFont systemFontOfSize:14]];
    [nameLabel setText:name];
    [nameLabel setTextColor:UIColorFromRGB(0x333333)];
    [nameLabel setTag:ProductOptionTagsNameLabel];
    [cell.contentView addSubview:nameLabel];
    
    // 옵션 타입
    NSString *displayType = productOptionInfo[@"options"][indexPath.row][@"dispType"];
    CGFloat lineY = 34;
    
    // 입력형은 비노출
    if ([@"input" isEqualToString:displayType]) {
        [nameLabel setHidden:YES];
    }
    else if ([@"select" isEqualToString:displayType]) {
        [nameLabel setHidden:NO];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(itemTableView.frame)-26, 9.5f, 16, 16)];
        [arrowImageView setImage:(selectedIndex == indexPath.row ? [UIImage imageNamed:@"option_btn_list_close.png"] : [UIImage imageNamed:@"option_btn_list_open.png"])];
        [cell.contentView addSubview:arrowImageView];
        
        //        NSLog(@"selectedIndex: %i, %i", selectedIndex, indexPath.row);
    }
    
    UILabel *selectedOptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [selectedOptionLabel setFont:[UIFont systemFontOfSize:14]];
    [selectedOptionLabel setTextColor:UIColorFromRGB(0x5d5fd6)];
    [selectedOptionLabel setTag:ProductOptionTagsSelectedLabel];
    [cell.contentView addSubview:selectedOptionLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, lineY, CGRectGetWidth(itemTableView.frame), 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0xafb0c2)];
    [cell.contentView addSubview:lineView];
    
    //상세옵션
    NSInteger optionCount;
    //    NSLog(@"searchingIndex: %i, selectedIndex: %i", searchingIndex, selectedIndex);
    if (isSearching && searchingIndex == indexPath.row) {
        optionCount = searchOptionsArray.count;
    }
    else {
        optionCount = [productOptionInfo[@"options"][indexPath.row][@"option"] count];
    }
    
    UIView *optionContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 35, CGRectGetWidth(itemTableView.frame), 35*optionCount)];
    [optionContainerView setHidden:(selectedIndex == indexPath.row ? NO : YES)];
    [cell.contentView addSubview:optionContainerView];
    
    CGFloat optionViewY = 0;
    
    for (int i = 0; i < optionCount; i++) {
        
        NSDictionary *option;
        if (isSearching && searchingIndex == indexPath.row) {
            option = searchOptionsArray[i];
        }
        else {
            option = productOptionInfo[@"options"][indexPath.row][@"option"][i];
        }
        
        CGSize size = [option[@"text"] sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(CGRectGetWidth(itemTableView.frame)-48, 10000) lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat labelHeight = size.height + 20;
        
        UIView *optionView = [[UIView alloc] initWithFrame:CGRectMake(0, optionViewY, CGRectGetWidth(itemTableView.frame), labelHeight)];
        [optionView setBackgroundColor:UIColorFromRGB(0xffffff)];
        [optionContainerView addSubview:optionView];
        
        optionViewY += labelHeight;
        
        UIButton *radioButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [radioButton setBackgroundColor:[UIColor clearColor]];
        [radioButton setFrame:CGRectMake(10, (labelHeight-20)/2, 20, 20)];
        [radioButton setImage:[UIImage imageNamed:@"option_btn_radio_off.png"] forState:UIControlStateNormal];
        [radioButton setImage:[UIImage imageNamed:@"option_btn_radio_on.png"] forState:UIControlStateSelected];
        [radioButton setSelected:[option[@"selected"] boolValue]];
        [optionView addSubview:radioButton];
        
        UIColor *colorLabelTextColor;
        if ([option[@"selected"] boolValue]) {
            colorLabelTextColor = UIColorFromRGB(0x5d5fd6);
            
            CGSize optionNameSize = [option[@"text"] sizeWithFont:[UIFont systemFontOfSize:14]];
            
            [selectedOptionLabel setText:option[@"text"]];
            [selectedOptionLabel setFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame)+8, 0, optionNameSize.width, 35)];
        }
        else {
            colorLabelTextColor = UIColorFromRGB(0x5d5e73);
        }
        
        ColorLabel *colorLabel = [[ColorLabel alloc] initWithFrame:CGRectMake(38, 10, CGRectGetWidth(itemTableView.frame)-48, labelHeight)];
        [colorLabel setBackgroundColor:[UIColor clearColor]];
        [colorLabel setText:option[@"text"]];
        [colorLabel setTextColor:colorLabelTextColor];
        [colorLabel setFont:[UIFont systemFontOfSize:13]];
        [colorLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [colorLabel setNumberOfLines:3];
        [colorLabel setTag:ProductOptionTagsColorLabel];
        
        if (self.searchWord.length > 0) {
            [colorLabel setColorLowercaseWord:self.searchWord withColor:UIColorFromRGB(0xe41313)];
        }
        
        [optionView addSubview:colorLabel];
        
        UIButton *optionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [optionButton setBackgroundColor:[UIColor clearColor]];
        [optionButton setFrame:CGRectMake(0, 0, CGRectGetWidth(itemTableView.frame), 35)];
        [optionButton setTitle:option[@"text"] forState:UIControlStateNormal];
        [optionButton.titleLabel setFont:[UIFont systemFontOfSize:0]];
        [optionButton addTarget:self action:@selector(touchOptionButton:) forControlEvents:UIControlEventTouchUpInside];
        [optionButton setTag:i];
        [optionView addSubview:optionButton];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, labelHeight-1, CGRectGetWidth(itemTableView.frame), 1)];
        [lineView setBackgroundColor:UIColorFromRGB(0xeaeaee)];
        [optionView addSubview:lineView];
    }
    
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
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *selectedOptionLabel = (UILabel *)[cell viewWithTag:ProductOptionTagsSelectedLabel];
    
    //최소 한개의 옵션은 열려있어야 함
    if (nilCheck(selectedOptionLabel.text)) {
        NSInteger optionCount = [productOptionInfo[@"options"][indexPath.row][@"option"] count];
        NSInteger idx = [productOptionInfo[@"options"][indexPath.row][@"idx"] integerValue];
        
        //        NSLog(@"searchingIndex: %i, selectedIndex: %i optionCount:%i idx:%i", searchingIndex, selectedIndex, optionCount, idx);
        
        if (idx == 0) {
            return;
        }
        else {
            if (optionCount == 0) {
                return;
            }
        }
    }
    
    if (selectedIndex == indexPath.row) {
        
        //        //선택된 옵션 임시저장
        //        UITableViewCell *cell = [itemTableView cellForRowAtIndexPath:indexPath];
        //        UILabel *selectedOptionLabel = (UILabel *)[cell.contentView viewWithTag:ProductOptionTagsSelectedLabel];
        //        NSString *selectedOptionText = selectedOptionLabel.text;
        
        selectedIndex = -1;
        
        //        [itemTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        //
        //        //선택된 옵션 표기
        //        UITableViewCell *reloadedCell = [itemTableView cellForRowAtIndexPath:indexPath];
        //
        //        UILabel *nameLabel = (UILabel *)[reloadedCell.contentView viewWithTag:ProductOptionTagsNameLabel];
        //        UILabel *reloadedSelectedOptionLabel = (UILabel *)[reloadedCell.contentView viewWithTag:ProductOptionTagsSelectedLabel];
        //
        //        CGSize optionNameSize = [selectedOptionText sizeWithFont:[UIFont systemFontOfSize:14]];
        //
        //        [reloadedSelectedOptionLabel setFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame)+8, 0, optionNameSize.width, 35)];
        //        [reloadedSelectedOptionLabel setText:selectedOptionText];
        
        //        [itemTableView reloadData];
        return;
    }
    
    if (selectedIndex >= 0) {
        //        NSIndexPath *previousPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
        //        [itemTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:previousPath] withRowAnimation:UITableViewRowAnimationFade];
        
        selectedIndex = indexPath.row;
    }
    
    selectedIndex = indexPath.row;
    //    [itemTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [itemTableView reloadData];
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
            
            [itemTableView reloadData];
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
        if (self.delegate && [self.delegate respondsToSelector:@selector(optionItem:textFieldShouldBeginEditing:)]) {
            [self.delegate optionItem:self textFieldShouldBeginEditing:YES];
            
            isEditing = YES;
        }
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

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.tag == ProductOptionTagsSearch) {
        //        isSearching = NO;
        
        [textField setText:nil];
        [textField resignFirstResponder];
    }
    else {
        if (activeTextField) {
            if ([self.delegate respondsToSelector:@selector(optionItem:textFieldShouldReturn:selectedRow:)]) {
                [self.delegate optionItem:self textFieldShouldReturn:activeTextField.text selectedRow:activeTextField.tag];
            }
        }
        
        [textField resignFirstResponder];
    }
    
    return YES;
}

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
        
        [textField setText:nil];
        [textField resignFirstResponder];
        
        //AccessLog - 옵션서랍 - 옵션검색
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"MPG0101"];
    }
    else {
        if ([self.delegate respondsToSelector:@selector(optionItem:textFieldShouldReturn:selectedRow:)]) {
            [self.delegate optionItem:self textFieldShouldReturn:textField.text selectedRow:textField.tag];
        }
        
        [textField resignFirstResponder];
    }
    
    isEditing = NO;
    //    isKeyboardShown = NO;
    
    return YES;
}

#pragma mark - CPLoadingView

- (void)startLoadingAnimation
{
    [self addSubview:loadingView];
    [loadingView startAnimation];
}

- (void)stopLoadingAnimation
{
    [loadingView stopAnimation];
    [loadingView removeFromSuperview];
}

@end