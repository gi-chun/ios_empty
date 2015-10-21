//
//  CPContactViewController.m
//  11st
//
//  Created by spearhead on 2014. 12. 1..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPContactViewController.h"
#import "CPAddressBookManager.h"
#import "CPAddressBookInfo.h"
#import "JSTokenField.h"
#import "SBJSON.h"
#import "ALToastView.h"

typedef NS_ENUM(NSUInteger, CMProfileViewTags) {
    CPProfileNameLabelViewTag = 1300,
    CPProfileViewTag,
    CPProfileBackgroundImageViewTag,
    CPProfileImageViewTag,
    CPProfileCheckedImageViewTag,
    CPProfileNewViewTag,
    CPProfileMobileNumberViewTag
};

@interface CPContactViewController () <CPAddressBookManagerDelegate,
                                    JSTokenFieldDelegate,
                                    UITableViewDataSource,
                                    UITableViewDelegate>
{
    NSDictionary *contactInfo;
    NSInteger maxRecipients;
    NSInteger minRecipients;
    
    UILabel *countLabel;
    
    NSArray *sectionDataList;
    NSMutableArray *filteredContactList;
    
    UITableView *contactTableView;
    BOOL isSearching;
    
    NSMutableArray *toRecipients;
    JSTokenField *searchView;
    BOOL didRemoveFromTableView;
    
    UITapGestureRecognizer *tapRecognizer;
    
    UIImageView *lineBackgroundView;
}
@end

@implementation CPContactViewController

- (id)initWithContact:(NSDictionary *)contact
{
    if ((self = [super init])) {
        
        filteredContactList = [NSMutableArray array];
        toRecipients = [NSMutableArray array];
        
        contactInfo = contact;
        
        if (contactInfo[@"max"]) {
            maxRecipients = [contactInfo[@"max"] integerValue];
        }
        else {
            maxRecipients = 15;
        }
        
        if (contactInfo[@"min"]) {
            minRecipients = [contactInfo[@"min"] integerValue];
        }
        else {
            minRecipients = 1;
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Status Bar style
    if ([SYSTEM_VERSION intValue] >= 7) {
        UIView *statusBar = [[UIView alloc] init];
        statusBar.frame = CGRectMake(0, 0, kScreenBoundsWidth, 20);
        [statusBar setBackgroundColor:UIColorFromRGB(0x000000)];
        [self.view addSubview:statusBar];
    }
    
    [self.view setBackgroundColor:UIColorFromRGB(0xf3f5fb)];
    
    UIView *topBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, kScreenBoundsWidth, 44)];
    topBarView.backgroundColor = NAVIGATION_BAR_COLOR;
    [self.view addSubview:topBarView];
    
    //타이틀
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectZero];
    [topBarView addSubview:titleView];
    
    NSString *title = @"연락처 불러오기";
    NSString *count = [NSString stringWithFormat:@"(%lu/%li)", (unsigned long)toRecipients.count, (long)maxRecipients];
    CGSize titleSize = [title sizeWithFont:[UIFont boldSystemFontOfSize:18]];
    CGSize countSize = [count sizeWithFont:[UIFont boldSystemFontOfSize:18]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, titleSize.width, 44)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:title];
    [titleView addSubview:titleLabel];
    
    countLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame), 0, countSize.width+10, 44)];
    [countLabel setBackgroundColor:[UIColor clearColor]];
    [countLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [countLabel setTextColor:UIColorFromRGB(0x54bdff)];
    [countLabel setTextAlignment:NSTextAlignmentCenter];
    [countLabel setText:count];
    [titleView addSubview:countLabel];
    
    [titleView setFrame:CGRectMake(0, 0, CGRectGetMaxX(countLabel.frame), 44)];
    [titleView setCenter:CGPointMake(CGRectGetWidth(topBarView.frame)/2, CGRectGetHeight(topBarView.frame)/2)];
    
    //확인버튼
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton setFrame:CGRectMake(kScreenBoundsWidth-50, 0, 50, 44)];
    [confirmButton setTitle:NSLocalizedString(@"Confirm", nil) forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [confirmButton setBackgroundColor:[UIColor clearColor]];
    [confirmButton addTarget:self action:@selector(touchConfirmButton) forControlEvents:UIControlEventTouchUpInside];
    [confirmButton setAccessibilityLabel:@"확인" Hint:@"화면을 닫습니다"];
    [topBarView addSubview:confirmButton];
    
    //주소록 불러오기 호출
    CPAddressBookManager *addressBookManager = [CPAddressBookManager sharedInstance];
    [addressBookManager setDelegate:self];
    [addressBookManager allowPermission:CPAddressBookManagerRequestFetchAddressBook
                            showMessage:YES];
    
    NSAttributedString *placeholderAttribute = [[NSAttributedString alloc] initWithString:@"이름, 전화번호 검색"
                                                                               attributes:@{NSForegroundColorAttributeName: UIColorFromRGB(0xb5b5b5),
                                                                                            NSFontAttributeName:[UIFont systemFontOfSize:13] }];
    
    
    searchView = [[JSTokenField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topBarView.frame), kScreenBoundsWidth, 56)];
    [searchView setBackgroundColor:UIColorFromRGB(0xf3f5fb)];
    [searchView.textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [searchView.textField setTextAlignment:NSTextAlignmentLeft];
    [searchView.textField setFont:[UIFont systemFontOfSize:13]];
    [searchView.textField setTextColor:UIColorFromRGB(0x111111)];
    [searchView.textField setKeyboardType:UIKeyboardTypeDefault];
    [searchView.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [searchView.textField setReturnKeyType:UIReturnKeySearch];
    [searchView.textField setAttributedPlaceholder:placeholderAttribute];
    [searchView setTokenDelegate:self];
    [searchView setScrollsToTop:NO];
    [self.view addSubview:searchView];
    [searchView redrawSubviews];
    
    //연락처 테이블
    contactTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(searchView.frame), kScreenBoundsWidth, kScreenBoundsHeight-(64+43))
                                                       style:UITableViewStylePlain];
    [contactTableView registerClass:[UITableViewCell class]
                forCellReuseIdentifier:@"Cell"];
    [contactTableView setDataSource:self];
    [contactTableView setDelegate:self];
    [contactTableView setBackgroundColor:UIColorFromRGB(0xf3f5fb)];
    [contactTableView setSeparatorColor:UIColorFromRGB(0xe5e8f3)];
    if ([self respondsToSelector:@selector(separatorInset)]) {
        [contactTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    [contactTableView setScrollsToTop:YES];
    
    // 인덱스 바 색상 변경
    if ([contactTableView respondsToSelector:@selector(setSectionIndexColor:)]) {
        contactTableView.sectionIndexColor = UIColorFromRGB(0xafb3c2);
        contactTableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        
        // 기본 bg는 7.0 이상에만 변경 가능.
        if ([contactTableView respondsToSelector:@selector(setSectionIndexBackgroundColor:)]) {
            contactTableView.sectionIndexBackgroundColor = [UIColor clearColor];
        }
    }
    [self.view addSubview:contactTableView];
    
    // 라인
    lineBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(searchView.frame), kScreenBoundsWidth, 4)];
    [lineBackgroundView setImage:[UIImage imageNamed:@"search_line_shadow.png"]];
    [self.view addSubview:lineBackgroundView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0xd5d8e5)];
    [lineBackgroundView addSubview:lineView];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(dismissKeyboard:)];
    
    // 주소록 검색창 관련
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTokenFieldFrameDidChange:)
                                                 name:JSTokenFieldFrameDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CPAddressBookManager Delegate

- (void)fetchAddressBookSuccess:(NSArray *)data
{
    // 섹션에 사용할 지역화 인덱스를 가지고 국가 코드를 다시 정렬한다.
    NSMutableArray *tempDatas = [NSMutableArray arrayWithArray:data];
    
    //스킴으로 넘어온 연락처 기존 연락처에 추가
    NSArray *contactList = contactInfo[@"contactList"];
    for (NSDictionary *contactItem in contactList) {
        if (![self isAddressBook:tempDatas phoneNumber:contactItem[@"phone"]]) {
            
            CPAddressBookInfo *addressInfo = [[CPAddressBookInfo alloc] init];
            
            if (contactItem[@"name"] && [contactItem[@"name"] length] > 0) {
                [addressInfo setName:contactItem[@"name"]];
            }
            else {
                [addressInfo setName:contactItem[@"phone"]];
            }
            
            [addressInfo setThumbnail:nil];
            [addressInfo setPhoneNumber:contactItem[@"phone"]];
            
            [tempDatas addObject:addressInfo];
        }
    }
    
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    NSInteger sectionCount = [[collation sectionTitles] count];
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    for (int i = 0; i < sectionCount; i++) {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    
    for (id data in tempDatas) {
        NSInteger index = [collation sectionForObject:data collationStringSelector:@selector(name)];
        [unsortedSections[index] addObject:data];
    }
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
    for (NSMutableArray *section in unsortedSections) {
        [sections addObject:[collation sortedArrayFromArray:section collationStringSelector:@selector(name)]];
    }
    
    sectionDataList = [[NSArray alloc] initWithArray:sections];
    
    //스킴으로 넘어온 연락처들 선택 처리
    for (NSArray *section in sectionDataList) {
        for (CPAddressBookInfo *data in section)  {
            NSArray *contactList = contactInfo[@"contactList"];
            for (NSDictionary *contactItem in contactList) {
                
                NSString *currentNumber = [self replacingPhoneNumber:contactItem[@"phone"]];
                NSString *recipientNumber = [self replacingPhoneNumber:data.phoneNumber];
                
                if ([currentNumber isEqualToString:recipientNumber]) {
                    [self addSelectedProfileToSearchView:data];
                }
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [contactTableView reloadData];
        
        [UIView transitionWithView: contactTableView
                          duration: 0.35f
                           options: UIViewAnimationOptionTransitionCrossDissolve
                        animations: ^(void) {
//                            [searchView setAlpha:1.0f];
                        }
                        completion: nil];
    });
}

- (void)fetchAddressBookFailed:(NSError *)error
{
    if (contactInfo[@"contactList"] && [contactInfo[@"contactList"] count] > 0) {
        NSMutableArray *tempDatas = [NSMutableArray array];
        
        //스킴으로 넘어온 연락처 기존 연락처에 추가
        NSArray *contactList = contactInfo[@"contactList"];
        for (NSDictionary *contactItem in contactList) {
            if (![self isAddressBook:tempDatas phoneNumber:contactItem[@"phone"]]) {
                
                CPAddressBookInfo *addressInfo = [[CPAddressBookInfo alloc] init];
                
                if (contactItem[@"name"] && [contactItem[@"name"] length] > 0) {
                    [addressInfo setName:contactItem[@"name"]];
                }
                else {
                    [addressInfo setName:contactItem[@"phone"]];
                }
                
                [addressInfo setThumbnail:nil];
                [addressInfo setPhoneNumber:contactItem[@"phone"]];
                
                [tempDatas addObject:addressInfo];
            }
        }
        
        UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
        
        NSInteger sectionCount = [[collation sectionTitles] count];
        NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
        
        for (int i = 0; i < sectionCount; i++) {
            [unsortedSections addObject:[NSMutableArray array]];
        }
        
        for (id data in tempDatas) {
            NSInteger index = [collation sectionForObject:data collationStringSelector:@selector(name)];
            [unsortedSections[index] addObject:data];
        }
        
        NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
        for (NSMutableArray *section in unsortedSections) {
            [sections addObject:[collation sortedArrayFromArray:section collationStringSelector:@selector(name)]];
        }
        
        sectionDataList = [[NSArray alloc] initWithArray:sections];
        
        //스킴으로 넘어온 연락처들 선택 처리
        for (NSArray *section in sectionDataList) {
            for (CPAddressBookInfo *data in section)  {
                NSArray *contactList = contactInfo[@"contactList"];
                for (NSDictionary *contactItem in contactList) {
                    
                    NSString *currentNumber = [self replacingPhoneNumber:contactItem[@"phone"]];
                    NSString *recipientNumber = [self replacingPhoneNumber:data.phoneNumber];
                    
                    if ([currentNumber isEqualToString:recipientNumber]) {
                        [self addSelectedProfileToSearchView:data];
                    }
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [contactTableView reloadData];
            
            [UIView transitionWithView: contactTableView
                              duration: 0.35f
                               options: UIViewAnimationOptionTransitionCrossDissolve
                            animations: ^(void) {
                                //                            [searchView setAlpha:1.0f];
                            }
                            completion: nil];
        });
    }
    else {
        // 데이터가 없습니다.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림"
                                                        message:@"연락처 데이터가 없습니다."
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
                                              otherButtonTitles:nil];
        
        [alert setDelegate:self];
        [alert show];
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Selectors

- (void)touchConfirmButton
{
//    if (toRecipients.count < minRecipients) {
//        [ALToastView toastInView:self.view withText:[NSString stringWithFormat:@"연락처를 더 추가해주세요. \n연락처는 최소 %i까지 추가할 수 있습니다.", minRecipients]];
//        return;
//    }
    
    if ([self.delegate respondsToSelector:@selector(didTouchContactConfirmButton:)]) {
        
        SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
        
        NSMutableArray *tempArray = [NSMutableArray array];
        for (CPAddressBookInfo *info in toRecipients) {
            
            NSString *phoneNumber = [self replacingPhoneNumber:info.phoneNumber];
            
            NSString *name = info.name;
            if (name) {
                name = URLEncode(name);
            }
            else{
                name = @"";
            }
            NSDictionary *dict = @{@"name": name, @"phone": phoneNumber};
            [tempArray addObject:dict];
        }
        
        [self.delegate didTouchContactConfirmButton:[jsonWriter stringWithObject:tempArray]];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isSearching) {
        return 1;
    }
    
    // Return the number of sections.
    return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isSearching) {
        return filteredContactList.count;
    }
    
    return [sectionDataList[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (isSearching) {
        return 0;
    }
    
    // 데이터가 없는 섹션은 섹션 헤더를 표시하지 않는다.
    if ([sectionDataList[section] count] == 0) {
        return 0;
    }
    
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell.contentView setBackgroundColor:UIColorFromRGB(0xffffff)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    CPAddressBookInfo *data = nil;
    if (isSearching) {
//        NSLog(@"row: %d / size: %d", indexPath.row, [filteredContactList count]);
        data = filteredContactList[indexPath.row];
//        NSLog(@"row: %d / size: %d", indexPath.row, [filteredContactList count]);
    }
    else {
        data = sectionDataList[indexPath.section][indexPath.row];
    }
    
    UIImageView *checkedProfileImageView = (UIImageView *)[cell viewWithTag:CPProfileCheckedImageViewTag];
    
    if (checkedProfileImageView == nil) {
        checkedProfileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 36, 36)];
        [checkedProfileImageView setImage:[UIImage imageNamed:@"list_img_check.png"]];
        [checkedProfileImageView setTag:CPProfileCheckedImageViewTag];
        [checkedProfileImageView setHidden:YES];
        [cell addSubview:checkedProfileImageView];
    }
    
    UIView *profileView = (UIView *)[cell viewWithTag:CPProfileViewTag];

    if (profileView == nil) {
        profileView = [[UIView alloc] initWithFrame:CGRectMake(10, 12, 36, 36)];
        [profileView setBackgroundColor:[UIColor clearColor]];
        [profileView setTag:CPProfileViewTag];
        [profileView setHidden:NO];
        [cell addSubview:profileView];
    }
    
    UIImageView *profileImageView = (UIImageView *)[profileView viewWithTag:CPProfileImageViewTag];
    if (!profileImageView) {
        profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
        [profileImageView setContentMode:UIViewContentModeScaleToFill];
        [profileImageView setTag:CPProfileImageViewTag];
        [profileView addSubview:profileImageView];
    }
    
    if (data.thumbnail) {
        [profileImageView setImage:data.thumbnail];
    }
    else {
        [profileImageView setImage:[UIImage imageNamed:@"list_img_default.png"]];
    }
    
    UILabel *profileNameLabel = (UILabel *)[cell viewWithTag:CPProfileNameLabelViewTag];
    if (profileNameLabel == nil) {
        profileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(profileView.frame)+12, 12, kScreenBoundsWidth-CGRectGetMaxX(profileView.frame)+12, 20)];
        [profileNameLabel setBackgroundColor:[UIColor clearColor]];
        [profileNameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [profileNameLabel setTextColor:UIColorFromRGB(0x111111)];
        [profileNameLabel setHighlightedTextColor:UIColorFromRGB(0xffffff)];
        [profileNameLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [profileNameLabel setTag:CPProfileNameLabelViewTag];
        [cell addSubview:profileNameLabel];
    }
    [profileNameLabel setText:[NSString stringWithFormat:@"%@", data.name]];

    UILabel *mobileNumberLabel = (UILabel *)[cell viewWithTag:CPProfileMobileNumberViewTag];
    if (!mobileNumberLabel) {
        mobileNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(profileView.frame)+12, 32, kScreenBoundsWidth-CGRectGetMaxX(profileView.frame)+12, 16)];
        [mobileNumberLabel setBackgroundColor:[UIColor clearColor]];
        [mobileNumberLabel setTextColor:UIColorFromRGB(0xafb3c2)];
        [mobileNumberLabel setFont:[UIFont systemFontOfSize:12]];
        [mobileNumberLabel setTag:CPProfileMobileNumberViewTag];
        [cell addSubview:mobileNumberLabel];
    }
    [mobileNumberLabel setText:[NSString stringWithFormat:@"%@", data.phoneNumber]];
    
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    [selectedBackgroundView setBackgroundColor:UIColorFromRGB(0xe9e9e9)];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
        [selectedBackgroundView setBackgroundColor:UIColorFromRGB(0x44C2B2)];
    }
//    [cell setSelectedBackgroundView:selectedBackgroundView];
    
    BOOL isSelected = [self isSelectedData:data];
    if (isSelected) {
        [checkedProfileImageView setHidden:NO];
        [profileView setHidden:YES];
    }
    else {
        [checkedProfileImageView setHidden:YES];
        [profileView setHidden:NO];
    }
//    NSLog(@"cell : %@", (isSelected ? @"YES" : @"NO"));

    return cell;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([sectionDataList[section] count] == 0) {
        return nil;
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 20)];
    [headerView setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreenBoundsWidth - 15, 20)];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    [headerLabel setText:[[UILocalizedIndexedCollation currentCollation] sectionTitles][section]];
    [headerLabel setTextColor:UIColorFromRGB(0x959595)];
    [headerLabel setContentMode:UIViewContentModeCenter];
    [headerLabel setFont:[UIFont systemFontOfSize:12]];
    [headerView addSubview:headerLabel];
    
    UIView *topSeparator = [[UIView alloc] initWithFrame:CGRectZero];
    [topSeparator setBackgroundColor:UIColorFromRGB(0xe9e9e9)];
    [topSeparator setFrame:CGRectMake(0, 0, kScreenBoundsWidth, 1)];
    [headerView addSubview:topSeparator];
    
    UIView *bottomSeparator = [[UIView alloc] initWithFrame:CGRectZero];
    [bottomSeparator setBackgroundColor:UIColorFromRGB(0xe9e9e9)];
    [bottomSeparator setFrame:CGRectMake(0, 19, kScreenBoundsWidth, 1)];
    [headerView addSubview:bottomSeparator];
    
    return headerView;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (sectionDataList == nil || [sectionDataList count] == 0) {
        return nil;
    }
    
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (sectionDataList == nil || [sectionDataList count] == 0) {
        return -1;
    }
    
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CPAddressBookInfo *data = nil;
    if (isSearching) {
        data = filteredContactList[indexPath.row];
    }
    else {
        data = sectionDataList[indexPath.section][indexPath.row];
    }
    
    didRemoveFromTableView = NO;
    BOOL isSelected = [self isSelectedData:data];
    if (isSelected) {
        didRemoveFromTableView = YES;
//        [self didUnselectRowAnimaion:[tableView cellForRowAtIndexPath:indexPath]];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        UIView *profileView = (UIView *)[cell viewWithTag:CPProfileViewTag];
        UIImageView *checkedProfileImageView = (UIImageView *)[cell viewWithTag:CPProfileCheckedImageViewTag];
        
        [profileView setHidden:NO];
        [checkedProfileImageView setHidden:YES];
        
        [self removeSelectedProfileFromSearchView:data];
    }
    else {
//        [self didSelectRowAnimation:[tableView cellForRowAtIndexPath:indexPath]];
        if (toRecipients.count < maxRecipients) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            UIView *profileView = (UIView *)[cell viewWithTag:CPProfileViewTag];
            UIImageView *checkedProfileImageView = (UIImageView *)[cell viewWithTag:CPProfileCheckedImageViewTag];
            
            [profileView setHidden:YES];
            [checkedProfileImageView setHidden:NO];
            
            [self addSelectedProfileToSearchView:data];
        }
        else {
            [ALToastView toastInView:self.view withText:[NSString stringWithFormat:@"연락처는 최대 %li까지 추가할수 있습니다.", (long)maxRecipients]];
        }
    }
    
    // 선택 후 초기화
    if (isSearching) {
        isSearching = NO;
        [searchView textField].text = @"";

        [contactTableView reloadData];
    }
}

#pragma mark - JSTokenFieldDelegate

- (void)tokenField:(JSTokenField *)tokenField didAddToken:(NSString *)title representedObject:(id)obj
{
    [toRecipients addObject:obj];
    [countLabel setText:[NSString stringWithFormat:@"(%lu/%li)", (unsigned long)toRecipients.count, (long)maxRecipients]];
//    NSLog(@"Added token for < %@ : %@ >\n%@", title, obj, toRecipients);
}

- (void)tokenField:(JSTokenField *)tokenField didRemoveToken:(NSString *)title representedObject:(id)obj;
{
//    NSLog(@"Deleted token \n%@", toRecipients);
    
    // 선택된 열 리스트 데이터 초기화
    if (!didRemoveFromTableView) {
        [sectionDataList enumerateObjectsUsingBlock:^(id sectionObj, NSUInteger sectionIdx, BOOL *sectionStop) {
            [sectionObj enumerateObjectsUsingBlock:^(id childObj, NSUInteger childIdx, BOOL *childStop) {
                if ([childObj isEqual:obj]) {
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:childIdx inSection:sectionIdx];
                    UITableViewCell *cell = [contactTableView cellForRowAtIndexPath:indexPath];
                    
                    UIView *profileView = (UIView *)[cell viewWithTag:CPProfileViewTag];
                    UIImageView *checkedProfileImageView = (UIImageView *)[cell viewWithTag:CPProfileCheckedImageViewTag];
                    
                    [profileView setHidden:NO];
                    [checkedProfileImageView setHidden:YES];
                    
                    didRemoveFromTableView = NO;
                    *childStop = YES;
                    *sectionStop = YES;
                }
            }];
//            NSLog(@"enum: %d", sectionIdx);
        }];
    }
    
    [toRecipients removeObject:obj];
    [countLabel setText:[NSString stringWithFormat:@"(%lu/%li)", (unsigned long)toRecipients.count, (long)maxRecipients]];
//    NSLog(@"Deleted token \n%@", toRecipients);
}

- (void)handleTokenFieldFrameDidChange:(NSNotification *)note
{
    CGFloat maxY = CGRectGetMaxY(searchView.frame);
    CGFloat newHeight = CGRectGetHeight(self.view.bounds) - maxY;
    
    [UIView animateWithDuration:0.25f animations:^{
        [contactTableView setFrame:CGRectMake(CGRectGetMinX(contactTableView.frame), maxY, CGRectGetWidth(contactTableView.frame), newHeight)];
        [lineBackgroundView setFrame:CGRectMake(0, CGRectGetMaxY(searchView.frame), kScreenBoundsWidth, 4)];
    }];
}

- (void)tokenFieldTextDidChange:(JSTokenField *)tokenField
{
    NSString *searchText = [[tokenField textField] text];
    if ([searchText length] == 0) {
        isSearching = NO;
    }
    else {
        isSearching = YES;
        [self filterContentForSearchText:searchText];
    }

    [contactTableView reloadData];
}

#pragma mark - Private Methods

- (void)didSelectRowAnimation:(UITableViewCell *)cell
{
    UIView *profileView = (UIView *)[cell viewWithTag:CPProfileViewTag];
    UILabel *profileNameLabel = (UILabel *)[cell viewWithTag:CPProfileNameLabelViewTag];
    UIImageView *checkedProfileImageView = (UIImageView *)[cell viewWithTag:CPProfileCheckedImageViewTag];
    
    [checkedProfileImageView setAlpha:0.0f];
    [checkedProfileImageView setFrame:CGRectMake(checkedProfileImageView.frame.size.width * -1.0f,
                                                 checkedProfileImageView.frame.origin.y,
                                                 checkedProfileImageView.frame.size.width,
                                                 checkedProfileImageView.frame.size.height)];
    
    [UIView animateWithDuration:0.35f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            
                            [profileNameLabel setFrame:CGRectMake(profileNameLabel.frame.origin.x + 25.0f,
                                                                  profileNameLabel.frame.origin.y,
                                                                  profileNameLabel.frame.size.width - 25.0f,
                                                                  profileNameLabel.frame.size.height)];
                            
                            [checkedProfileImageView setAlpha:1.0f];
                            [checkedProfileImageView setFrame:CGRectMake(9.0f,
                                                                         checkedProfileImageView.frame.origin.y,
                                                                         checkedProfileImageView.frame.size.width,
                                                                         checkedProfileImageView.frame.size.height)];
                            
                            [profileView setFrame:CGRectMake(profileView.frame.origin.x + 25.0f,
                                                             profileView.frame.origin.y,
                                                             profileView.frame.size.width,
                                                             profileView.frame.size.height)];
                            
                        } completion:^(BOOL finished) {
                            
                        }];
    
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0f];
    rotationAnimation.duration = 0.35f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 1.0f;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [profileView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    //    [cell setHighlighted:YES animated:YES];
}

- (void)didUnselectRowAnimaion:(UITableViewCell *)cell
{
    UIView *profileView = (UIView *)[cell viewWithTag:CPProfileViewTag];
    UILabel *profileNameLabel = (UILabel *)[cell viewWithTag:CPProfileNameLabelViewTag];
    UIImageView *checkedProfileImageView = (UIImageView *)[cell viewWithTag:CPProfileCheckedImageViewTag];
    
    
    [UIView animateWithDuration:0.35f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        [profileNameLabel setFrame:CGRectMake(profileNameLabel.frame.origin.x - 25.0f,
                                              profileNameLabel.frame.origin.y,
                                              profileNameLabel.frame.size.width + 25.0f,
                                              profileNameLabel.frame.size.height)];
        
        
        [checkedProfileImageView setAlpha:0.0f];
        [checkedProfileImageView setFrame:CGRectMake(checkedProfileImageView.frame.size.width * -1.0f,
                                                     checkedProfileImageView.frame.origin.y,
                                                     checkedProfileImageView.frame.size.width,
                                                     checkedProfileImageView.frame.size.height)];
        
        [profileView setFrame:CGRectMake(profileView.frame.origin.x - 25.0f,
                                         profileView.frame.origin.y,
                                         profileView.frame.size.width,
                                         profileView.frame.size.height)];
        
    } completion:^(BOOL finished) {
        
    }];
    
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * -2.0f];
    rotationAnimation.duration = 0.35f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 1.0f;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [profileView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)addSelectedProfileToSearchView:(id)data
{
    [searchView addTokenWithRepresentedObject:data];
}

- (void)removeSelectedProfileFromSearchView:(id)data
{
    [searchView removeTokenWithRepresentedObject:data];
//    CPAddressBookInfo *info = (CPAddressBookInfo *)data;
//    [searchView removeTokenForString:info.name];
}

- (BOOL)isSelectedData:(CPAddressBookInfo *)data
{
    BOOL isSelected = NO;
    for (CPAddressBookInfo *oldData in toRecipients) {
        NSString *currentNumber = [self replacingPhoneNumber:data.phoneNumber];
        NSString *recipientNumber = [self replacingPhoneNumber:oldData.phoneNumber];

        if ([currentNumber isEqualToString:recipientNumber]) {
            isSelected = YES;
            
            break;
        }
    }
    
    return isSelected;
}

- (BOOL)isAddressBook:(NSArray *)data phoneNumber:(NSString *)phoneNumber
{
    BOOL isEqual = NO;
    
    for (CPAddressBookInfo *addressBook in data)  {
        NSString *currentNumber = [self replacingPhoneNumber:phoneNumber];
        NSString *recipientNumber = [self replacingPhoneNumber:addressBook.phoneNumber];
        
        if ([currentNumber isEqualToString:recipientNumber]) {
            isEqual = YES;
            break;
        }
    }
    
    return isEqual;
}

- (NSString *)replacingPhoneNumber:(NSString *)phoneNumber
{
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    return phoneNumber;
}

#pragma mark - Notification Delegate

- (void)dismissKeyboard:(id)sender
{
    [searchView.textField resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.view removeGestureRecognizer:tapRecognizer];
}

#pragma mark - Filter

- (void)filterContentForSearchText:(NSString *)searchText
{
    [filteredContactList removeAllObjects]; // First clear the filtered array.
    
    for (NSArray *section in sectionDataList) {
        for (CPAddressBookInfo *data in section)  {
            if ([data.name rangeOfString:searchText].location != NSNotFound) {
//                NSLog(@"1.친구: %@, 검색어: %@", data.name, searchText);
                [filteredContactList addObject:data];
            }
            else {
                // 초성 검색
                NSString *searchResult = [Modules filterChosungText:searchText];
                if ([searchResult isEqualToString:searchText]) {
//                    NSLog(@"일치: %@, %@", searchResult, searchText);
                    NSString *searchName = [Modules filterChosungText:data.name];
                    
                    if ([searchName rangeOfString:searchResult].location != NSNotFound) {
//                        NSLog(@"2.친구: %@, 검색어: %@, 이름: %@", data.name, searchResult, searchText);
                        [filteredContactList addObject:data];
                    }
                }
            }
            
        }
    }
}

@end
