//
//  CPMartSearchViewController.m
//  11st
//
//  Created by spearhead on 2015. 3. 31..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPMartSearchViewController.h"
#import "CPProductListViewController.h"
#import "ColorLabel.h"
#import "CPRESTClient.h"
#import "CPCommonInfo.h"
#import "AccessLog.h"
#import "RegexKitLite.h"

@interface CPMartSearchViewController () <UITextFieldDelegate,
                                        UITableViewDataSource,
                                        UITableViewDelegate>
{
    NSMutableArray *autoCompleteLeftKeywordArray;
    NSMutableArray *autoCompleteRightKeywordArray;
    
    UITableView *autoCompleteTableView;
    
    BOOL isAutoComplete;
    
    CGFloat statusBarHeight;
    
    UITextField *searchTextField;
}

@end

@implementation CPMartSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    autoCompleteLeftKeywordArray = [NSMutableArray array];
    autoCompleteRightKeywordArray = [NSMutableArray array];
    
    // iOS7 Layout
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
        statusBarHeight = 20;
    }
    
    [self.view setBackgroundColor:UIColorFromRGB(0xf0f0f2)];
    
    [self loadContentsView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadContentsView
{
    UIView *statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), statusBarHeight)];
    [statusBar setBackgroundColor:UIColorFromRGB(0x000000)];
    [self.view addSubview:statusBar];
    
    UIView *searchAreaView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, CGRectGetWidth(self.view.frame), 52)];
    [searchAreaView setBackgroundColor:UIColorFromRGB(0x00cab4)];
    [self.view addSubview:searchAreaView];

    // 검색
    UIView *serachContainerView = [[UIView alloc] initWithFrame:CGRectMake(10, 8, CGRectGetWidth(searchAreaView.frame)-54, 36)];
    [searchAreaView addSubview:serachContainerView];
    
    UIImageView *rightCornerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 4, 36)];
    [rightCornerImageView setImage:[UIImage imageNamed:@"gnb_search_corner.png"]];
    [serachContainerView addSubview:rightCornerImageView];
    
    UIView *textFieldBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(4, 0, CGRectGetWidth(serachContainerView.frame)-48, 36)];
    [textFieldBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"gnb_search_middle.png"]]];
    [serachContainerView addSubview:textFieldBackgroundView];
    
    searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(serachContainerView.frame)-56, 36)];
    [searchTextField setDelegate:self];
    [searchTextField setPlaceholder:@"마트 상품을 검색해보세요!"];
    [searchTextField setTextColor:UIColorFromRGB(0x444444)];
    [searchTextField setFont:[UIFont systemFontOfSize:16]];
    [searchTextField setReturnKeyType:UIReturnKeySearch];
    [searchTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [searchTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [serachContainerView addSubview:searchTextField];
    
    [self performSelector:@selector(textFieldBecomeFirstResponder) withObject:nil afterDelay:0.5f];
    
    UIView *buttonBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(serachContainerView.frame)-44, 0, 40, 36)];
    [buttonBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"gnb_search_bt_middle.png"]]];
    [serachContainerView addSubview:buttonBackgroundView];
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setFrame:CGRectMake(CGRectGetWidth(serachContainerView.frame)-40, 0, 36, 36)];
    [searchButton setImage:[UIImage imageNamed:@"gnb_btn_search_nor.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"gnb_btn_search_press.png"] forState:UIControlStateHighlighted];
    [searchButton addTarget:self action:@selector(touchSearchButton) forControlEvents:UIControlEventTouchUpInside];
    [searchButton setAccessibilityLabel:@"검색" Hint:@"검색을 시작합니다"];
    [serachContainerView addSubview:searchButton];
    
    UIImageView *leftCornerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(serachContainerView.frame)-4, 0, 4, 36)];
    [leftCornerImageView setImage:[UIImage imageNamed:@"gnb_search_bt.png"]];
    [serachContainerView addSubview:leftCornerImageView];
    
    // 닫기 버튼
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setFrame:CGRectMake(CGRectGetWidth(searchAreaView.frame)-40, 8, 36, 36)];
    [closeButton setTitle:@"닫기" forState:UIControlStateNormal];
    [closeButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [closeButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"gnb_btn_close_press.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(touchCancelButton) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setAccessibilityLabel:@"닫기" Hint:@"검색창을 닫습니다"];
    [searchAreaView addSubview:closeButton];
    
    // 자동완성 테이블뷰
    UIImageView *tableBgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [tableBgImageView setImage:[UIImage imageNamed:@"autocomplete_bg.png"]];
    
    autoCompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                          CGRectGetMaxY(searchAreaView.frame),
                                                                          kScreenBoundsWidth,
                                                                          CGRectGetHeight(self.view.frame)-CGRectGetHeight(searchAreaView.frame))
                                                         style:UITableViewStylePlain];
    [autoCompleteTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [autoCompleteTableView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [autoCompleteTableView setDataSource:self];
    [autoCompleteTableView setDelegate:self];
    [autoCompleteTableView setScrollsToTop:NO];
    [autoCompleteTableView setShowsVerticalScrollIndicator:NO];
    [autoCompleteTableView setHidden:YES];
    [autoCompleteTableView setBackgroundView:tableBgImageView];
    [self.view addSubview:autoCompleteTableView];
}

#pragma mark - API

- (void)getLoadAutoCompleteData:(NSString *)keyword
{
    if (nilCheck(keyword)) {
        return;
    }
    
    //인코딩을 두번해야 한글 검색 가능
    keyword = [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    keyword = [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *apiUrl = [APP_MART_AUTOCOMPLETE_URL stringByReplacingOccurrencesOfString:@"{{key}}" withString:keyword];
    
    void (^searchSuccess)(NSDictionary *);
    searchSuccess = ^(NSDictionary *result) {
        if (result && [result count] > 0) {
            
            if (isAutoComplete) {
                [autoCompleteLeftKeywordArray removeAllObjects];
                [autoCompleteRightKeywordArray removeAllObjects];
                
                NSArray *outKeywordLeftArray = result[@"AKCResult"][@"outKwd"];
                NSArray *outKeywordRightArray = result[@"AKCResult1"][@"outKwd1"];
                
                if (outKeywordLeftArray && outKeywordLeftArray.count > 0) {
                    for (NSString *keyword in outKeywordLeftArray) {
                        if (keyword && ![keyword isEqual:[NSNull null]]) {
                            [autoCompleteLeftKeywordArray addObject:keyword];
                        }
                    }
                }
                
                if (outKeywordRightArray && outKeywordRightArray.count > 0) {
                    for (NSString *keyword in outKeywordRightArray) {
                        if (keyword && ![keyword isEqual:[NSNull null]]) {
                            [autoCompleteRightKeywordArray addObject:keyword];
                        }
                    }
                }
                
                [autoCompleteTableView setHidden:NO];
                [autoCompleteTableView reloadData];
            }
        }
        
    };
    
    void (^searchFailure)(NSError *);
    searchFailure = ^(NSError *error) {
        //
        
    };
    
    [[CPRESTClient sharedClient] requestSearchWithUrl:apiUrl
                                              success:searchSuccess
                                              failure:searchFailure];
}

#pragma mark - Private Methods

- (void)textFieldBecomeFirstResponder
{
    [searchTextField becomeFirstResponder];
}

- (void)closeSearchViewController
{
    [searchTextField resignFirstResponder];
    isAutoComplete = NO;
    
//    [self.navigationController setNavigationBarHidden:NO];
//    [self.navigationController popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)search:(NSString *)keyword
{
    if (!keyword || [[keyword trim] isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"검색어를 입력해주세요."
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
                                              otherButtonTitles:nil];
        
        [alert setDelegate:self];
        [alert setTag:1];
        [alert show];
        
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(martSearchWithKeyword:)]) {
        [self.delegate martSearchWithKeyword:keyword];
    }
    
    //최근 검색어 저장
//    if ([self isValidateKeyword:keyword]) {
//        [CPCommonInfo addRecentSearchItems:keyword];
//    }
    
    [self closeSearchViewController];
    
//    //AccessLog - 검색
//    [[AccessLog sharedInstance] sendAccessLogWithCode:@"UMA0201"];
}

- (BOOL)isValidateKeyword:(NSString *)keyword
{
    NSString *regular = @"[^\uAC00-\uD7AF\u1100-\u11FF\u3130-\u318f a- zA-Z0-9]+";
    NSString *inputKeyword = [keyword stringByReplacingOccurrencesOfString:regular withString:@" "];
    inputKeyword = [inputKeyword stringByReplacingOccurrencesOfString:@"\\p{Space}" withString:@""];
    inputKeyword = [inputKeyword lowercaseString];
    
    if ([inputKeyword isMatchedByRegex:@"[ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ]"]) {
        return NO;
    }
    
    if ([inputKeyword isMatchedByRegex:@"[ㅏ ㅐ ㅑ ㅒ ㅓ ㅔ ㅕ ㅖ ㅗ ㅘ ㅙ ㅚ ㅛ ㅜ ㅝ ㅞ ㅟ ㅠ ㅡ ㅢ ㅣ]"]) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Selectors

- (void)touchKeyword:(id)sender
{
    NSUInteger index = [(UIButton *)sender tag];
    NSString *keyword = nil;
    
    if (isAutoComplete) {
        if (autoCompleteLeftKeywordArray && autoCompleteLeftKeywordArray.count > 0) {
            keyword = index % 2 == 0 ? [autoCompleteLeftKeywordArray objectAtIndex:index / 2] : [autoCompleteRightKeywordArray objectAtIndex:index / 2];
        }
        
//        //AccessLog - 검색창 자동완성 검색어 선택
//        [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRB01"];
    }
    
    [self search:keyword];
}

- (void)touchSearchButton
{
    //AccessLog - 검색창 검색 버튼
//    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRB08"];
    
    [self search:[searchTextField.text trim]];
}

- (void)touchCancelButton
{
    [self closeSearchViewController];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowsCount = 0;
    
    if (isAutoComplete) {
        rowsCount = [autoCompleteLeftKeywordArray count] > [autoCompleteRightKeywordArray count] ? [autoCompleteLeftKeywordArray count]: [autoCompleteRightKeywordArray count];
    }
    
    return rowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"autoCompleteCellLeft";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    if (isAutoComplete) {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if ([autoCompleteLeftKeywordArray count] > indexPath.row) {
            
            ColorLabel *leftLabel = [[ColorLabel alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(autoCompleteTableView.frame)/2-20, 40)];
            [leftLabel setBackgroundColor:[UIColor clearColor]];
            //            [leftLabel setText:[[autoCompleteLeftKeywordArray objectAtIndex:indexPath.row] objectForKey:@"Word"]];
            [leftLabel setText:autoCompleteLeftKeywordArray[indexPath.row]];
            [leftLabel setTextColor:[UIColor blackColor]];
            [leftLabel setFont:[UIFont systemFontOfSize:16.0f]];
            [leftLabel setLineBreakMode:NSLineBreakByTruncatingTail];
            [leftLabel setColorWord:[searchTextField.text trim] withColor:[UIColor redColor]];
            [cell.contentView addSubview:leftLabel];
            
            UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [leftButton setTag:indexPath.row * 2];
            [leftButton setFrame:CGRectMake(10, 0, CGRectGetWidth(autoCompleteTableView.frame)/2-20, 40)];
            [leftButton setBackgroundColor:[UIColor clearColor]];
            [leftButton addTarget:self action:@selector(touchKeyword:) forControlEvents:UIControlEventTouchUpInside];
            [leftButton setAccessibilityLabel:@"자동완성 검색어" Hint:@"자동완성 검색어를 선택합니다"];
            [cell.contentView addSubview:leftButton];
        }
        
        if ([autoCompleteRightKeywordArray count] > indexPath.row) {
            ColorLabel *rightLabel = [[ColorLabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(autoCompleteTableView.frame)/2+10, 10, CGRectGetWidth(autoCompleteTableView.frame)/2-20, 40)];
            [rightLabel setBackgroundColor:[UIColor clearColor]];
            [rightLabel setTextAlignment:NSTextAlignmentRight];
            //            [rightLabel setText:[[autoCompleteRightKeywordArray objectAtIndex:indexPath.row] objectForKey:@"Word"]];
            [rightLabel setText:autoCompleteRightKeywordArray[indexPath.row]];
            [rightLabel setTextColor:[UIColor blackColor]];
            [rightLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
            [rightLabel setFont:[UIFont systemFontOfSize:16.0f]];
            [rightLabel setTag:indexPath.row * 2 + 1];
            [rightLabel setColorWord:[searchTextField.text trim] withColor:[UIColor redColor]];
            [cell.contentView addSubview:rightLabel];
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [rightButton setTag:indexPath.row * 2 + 1];
            [rightButton setFrame:CGRectMake(CGRectGetWidth(autoCompleteTableView.frame)/2, 0, CGRectGetWidth(autoCompleteTableView.frame)/2-20, 40)];
            [rightButton setBackgroundColor:[UIColor clearColor]];
            [rightButton addTarget:self action:@selector(touchKeyword:) forControlEvents:UIControlEventTouchUpInside];
            [rightButton setAccessibilityLabel:@"자동완성 검색어" Hint:@"자동완성 검색어를 선택합니다"];
            [cell.contentView addSubview:rightButton];
        }
    }
    
    //iOS7 대응 : iOS7이상에서 cell의 background가 투명이 아니기때문에 투명하게 지정함.
    if ([SYSTEM_VERSION intValue] >= 7) {
        cell.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//    // 키보드 액세사리뷰
//    UIView *cancelView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenBoundsHeight-36, kScreenBoundsWidth, 36)];
//    [cancelView setBackgroundColor:[UIColor clearColor]];
//    [textField setInputAccessoryView:cancelView];
//    
//    // 닫기 버튼
//    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [cancelButton setFrame:CGRectMake(CGRectGetWidth(cancelView.frame)-59, 0, 51, 27)];
//    [cancelButton setBackgroundImage:[UIImage imageNamed:@"search_btn_close.png"] forState:UIControlStateNormal];
//    [cancelButton setBackgroundImage:[UIImage imageNamed:@"search_btn_close_press.png"] forState:UIControlStateHighlighted];
//    [cancelButton addTarget:self action:@selector(touchCancelButton) forControlEvents:UIControlEventTouchUpInside];
//    [cancelButton setAccessibilityLabel:@"닫기" Hint:@"검색창을 닫습니다"];
//    [cancelView addSubview:cancelButton];
    
    return YES;
}

- (void)onTextDidChanged:(NSNotification *)notification
{
    isAutoComplete = YES;
    
    if ([searchTextField.text length] == 1) {
        [autoCompleteTableView.backgroundView setHidden:NO];
    }
    
    if ([[searchTextField.text trim] length] > 0) {
        [NSThread detachNewThreadSelector:@selector(getLoadAutoCompleteData:) toTarget:self withObject:[searchTextField.text trim]];
    }
    else {
        isAutoComplete = NO;
        [autoCompleteTableView setHidden:YES];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTextDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    
    if (!isAutoComplete) {
        [textField setFont:[UIFont systemFontOfSize:16]];
        
        isAutoComplete = NO;
        
        return;
    }
    
    isAutoComplete = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([[searchTextField.text trim] length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"검색어를 입력해주세요."
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
                                              otherButtonTitles:nil];
        
        [alert setDelegate:self];
        [alert setTag:1];
        [alert show];
        
        return NO;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
    
    
    [self search:[searchTextField.text trim]];
    
    return YES;
}

//- (BOOL)textFieldShouldClear:(UITextField *)textField
//{
//    //AccessLog - 검색창 검색어 삭제
//    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRB07"];
//    
//    return YES;
//}

@end
