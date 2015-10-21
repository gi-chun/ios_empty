//
//  CPMyInfoViewController.m
//  11st
//
//  Created by spearhead on 2014. 8. 28..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPMyInfoViewController.h"
#import "CPHomeViewController.h"
#import "CPWebViewController.h"
#import "CPLoadingView.h"
#import "CPCommonInfo.h"
#import "CPThumbnailView.h"
#import "CPRESTClient.h"
#import "UIImageView+WebCache.h"
#import "AccessLog.h"
#import <CoreText/CoreText.h>

#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"

typedef NS_ENUM(NSUInteger, CPMyInfoCellType){
    CPMyInfoCellTypeProperty = 0,         //쿠폰등 정보
    CPMyInfoCellTypeDataFree,             //데이터프리정보
    CPMyInfoCellTypeMyPage,               //마이페이지
    CPMyInfoCellTypeRecent,               //최근본상품
    CPMyInfoCellTypeSetting               //설정
};

typedef NS_ENUM(NSUInteger, CPPropertyType){
    CPPropertyTypeCoupon = 0,           //쿠폰
    CPPropertyTypePoint,                //포인트
    CPPropertyTypeMileage,              //마일리지
    CPPropertyTypeCash,                 //캐시
    CPPropertyTypeBenefit               //추가혜택
};

@interface CPMyInfoViewController () <UITableViewDataSource,
                                      UITableViewDelegate>
{
    UITableView *myInfoTableView;
    
    NSMutableDictionary *mypageArea;
    NSMutableDictionary *loginArea;
    NSMutableDictionary *rewardArea;
    NSMutableDictionary *todayViewArea;
    NSMutableDictionary *dataFreeArea;
    
    CPLoadingView *loadingView;
    
    CGFloat statusBarHeight;
	CGFloat screenHeight;
}

@end

@implementation CPMyInfoViewController

- (id)init
{
	if ((self = [super init])) {
        mypageArea = [[CPCommonInfo sharedInfo] mypageArea];
	}
    
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:UIColorFromRGB(0xf7f7f7)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // iOS7 Layout
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        statusBarHeight = 20;
    }
	
	screenHeight = 0.f;
	if ([SYSTEM_VERSION intValue] > 6)	screenHeight = kScreenBoundsHeight;
	else								screenHeight = kScreenBoundsHeight - 20.f;
	
    //TableView
    myInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, statusBarHeight, kSideMenuWidth, screenHeight-statusBarHeight)
                                                   style:UITableViewStylePlain];
    [myInfoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [myInfoTableView setBackgroundColor:UIColorFromRGB(0xf7f7f7)];
    [myInfoTableView setDataSource:self];
    [myInfoTableView setDelegate:self];
    [myInfoTableView setScrollsToTop:YES];
    [myInfoTableView setShowsVerticalScrollIndicator:NO];
    [myInfoTableView setHidden:YES];
    [self.view addSubview:myInfoTableView];
    
    //LoadingView
//    loadingView = [[CPLoadingView alloc] initWithFrame:CGRectMake(0, statusBarHeight, 264, screenHeight-statusBarHeight)];
    loadingView = [[CPLoadingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(myInfoTableView.frame)/2-40,
                                                                  CGRectGetHeight(self.view.frame)/2-40,
                                                                  80,
                                                                  80)];
    [self startLoadingAnimation];
    
    //최근 상품 API 호출
    [self performSelectorInBackground:@selector(getMyInfo) withObject:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - API

- (void)getMyInfo
{
    void (^myPageSuccess)(NSDictionary *);
    myPageSuccess = ^(NSDictionary *result) {
        if (result && [result count] > 0) {
            
            loginArea = result[@"menuArea"][@"loginArea"];
            rewardArea = result[@"menuArea"][@"rewardArea"];
            todayViewArea = result[@"menuArea"][@"todayViewArea"];
            dataFreeArea = result[@"menuArea"][@"dataFreeArea"];
        }
        
        [myInfoTableView setHidden:NO];
        [myInfoTableView reloadData];
        [self stopLoadingAnimation];
    };
    
    void (^myPageFailure)(NSError *);
    myPageFailure = ^(NSError *error) {
        [self stopLoadingAnimation];
    };
    
    NSString *apiUrl = [[Modules urlWithQueryString:APP_MY_INFO_URL] stringByAppendingFormat:@"&requestTime=%@", [Modules stringFromDate:[NSDate date] format:@"yyyyMMddHH"]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"apiUrl"] = apiUrl;
    
    [[CPRESTClient sharedClient] requestMyPageWithParam:params
                                                success:myPageSuccess
                                                failure:myPageFailure];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case CPMyInfoCellTypeProperty:
        {
            return 190;
        }
        case CPMyInfoCellTypeDataFree:
        {
            if (dataFreeArea) {
            //if (true) {
                return 50;
            }
            else {
                return 0;
            }
        }
        case CPMyInfoCellTypeMyPage:
        {
            NSInteger itemCount = [mypageArea[@"items"] count] / 2 + [mypageArea[@"items"] count] % 2;
            return 49*itemCount+1;
        }
        case CPMyInfoCellTypeRecent:
            return 153;
        case CPMyInfoCellTypeSetting:
        default:
            return 60;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 63;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 63)];
    [headerView setBackgroundColor:UIColorFromRGB(0xF5F6F8)];
    
    if ([loginArea[@"loginYN"] isEqualToString:@"Y"]) {
        
        //01(vvip), 02(vip), 03(top), 04(best), 05(new)
        NSDictionary *stringGradeToNumber = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:1], @"vvip",
                                             [NSNumber numberWithInt:2], @"vip",
                                             [NSNumber numberWithInt:3], @"top",
                                             [NSNumber numberWithInt:4], @"best",
                                             [NSNumber numberWithInt:5], @"new",
                                             nil];
        
        NSNumber *numberGrade = [stringGradeToNumber objectForKey:[loginArea[@"grade"] lowercaseString]];
        
        NSString *gradeImageName = [NSString stringWithFormat:@"r_side_ic_level_0%@.png", numberGrade];
        
        //시작점 10 -> 32 ?
        UIImageView *gradeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 11, 40, 40)];
        [gradeImageView setImage:[UIImage imageNamed:gradeImageName]];
        [headerView addSubview:gradeImageView];
        
        UIButton *nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [nameButton setBackgroundColor:[UIColor clearColor]];
        [nameButton setFrame:CGRectMake(CGRectGetMaxX(gradeImageView.frame)+7, 11, 50, 40)];
        [nameButton setTitle:[NSString stringWithFormat:@"%@", loginArea[@"name"]] forState:UIControlStateNormal];
        [nameButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
        [nameButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
        [nameButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [nameButton addTarget:self action:@selector(touchMyHomeButton) forControlEvents:UIControlEventTouchUpInside];
        [nameButton setAccessibilityLabel:@"회원이름" Hint:@"11번가 홈으로 이동합니다"];
        [headerView addSubview:nameButton];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nameButton.frame)+3, 25, 10, 15)];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setFont:[UIFont boldSystemFontOfSize:13]];
        [nameLabel setText:@"님"];
        [nameLabel setTextColor:UIColorFromRGB(0x757575)];
        [headerView addSubview:nameLabel];
        
    }
    else {
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [loginButton setBackgroundColor:[UIColor clearColor]];
        [loginButton setFrame:CGRectMake(10, 11, 90, 40)];
        [loginButton setBackgroundImage:[UIImage imageNamed:@"btn_my11_login_nor.png"] forState:UIControlStateNormal];
        [loginButton setBackgroundImage:[UIImage imageNamed:@"btn_my11_login_press.png"] forState:UIControlStateHighlighted];
        [loginButton setTitle:@"로그인" forState:UIControlStateNormal];
        [loginButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [loginButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [loginButton addTarget:self action:@selector(touchLoginButton) forControlEvents:UIControlEventTouchUpInside];
        [loginButton setAccessibilityLabel:@"로그인" Hint:@"로그인을 시작합니다"];
        [headerView addSubview:loginButton];
    }
    
    NSString *title = @"등급혜택";
    UIImage *iconImage = [UIImage imageNamed:@"r_side_ic_lv_bene.png"];
    
    UIButton *benefitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [benefitButton setFrame:CGRectMake(CGRectGetWidth(headerView.frame)-110, -4, 50, 62)]; //-110, -4, 50, 62
    [benefitButton setImage:iconImage forState:UIControlStateNormal];
    [benefitButton setImage:[UIImage imageNamed:@"r_side_ic_lv_bene.png"] forState:UIControlStateHighlighted];
    [benefitButton setTitle:title forState:UIControlStateNormal];
    [benefitButton setTitleColor:UIColorFromRGB(0x4D4D4D) forState:UIControlStateNormal];
    [benefitButton setTitleColor:UIColorFromRGB(0xf62e3d) forState:UIControlStateHighlighted];
    [benefitButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [benefitButton addTarget:self action:@selector(touchBenefitButton) forControlEvents:UIControlEventTouchUpInside];
    [benefitButton setAccessibilityLabel:@"등급혜택" Hint:@"등급혜택으로 이동합니다"];
    [headerView addSubview:benefitButton];
    
    CGSize imageSize = iconImage.size;
    CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:12]];
    [benefitButton setTitleEdgeInsets:UIEdgeInsetsMake(8, - (imageSize.width + 5), - (titleSize.height+20), 0)];
    
    title = @"알리미";
    iconImage = [UIImage imageNamed:@"r_side_ic_alarm.png"]; //btn_alarm_nor.png
    
    UIButton *alimiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [alimiButton setFrame:CGRectMake(CGRectGetMaxX(benefitButton.frame)+5, -5, 50, 62)];
    [alimiButton setImage:iconImage forState:UIControlStateNormal];
    [alimiButton setImage:[UIImage imageNamed:@"r_side_ic_alarm.png"] forState:UIControlStateHighlighted]; //btn_alarm_press.png
    [alimiButton setTitle:title forState:UIControlStateNormal];
    [alimiButton setTitleColor:UIColorFromRGB(0x4D4D4D) forState:UIControlStateNormal];
    [alimiButton setTitleColor:UIColorFromRGB(0xf62e3d) forState:UIControlStateHighlighted];
    [alimiButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [alimiButton addTarget:self action:@selector(touchAlimiButton) forControlEvents:UIControlEventTouchUpInside];
    [alimiButton setAccessibilityLabel:@"알리미" Hint:@"알리미로 이동합니다"];
    [headerView addSubview:alimiButton];
    
    imageSize = iconImage.size;
    titleSize = [title sizeWithFont:[UIFont systemFontOfSize:12]];
    [alimiButton setTitleEdgeInsets:UIEdgeInsetsMake(0 , - (imageSize.width+10) , - (titleSize.height+30), 0)]; //20
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerView.frame)-1, CGRectGetWidth(headerView.frame), 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0xcccccc)];
    [headerView addSubview:lineView];

    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (loginArea && rewardArea && todayViewArea) {
        switch (indexPath.row) {
            case CPMyInfoCellTypeProperty:
                //쿠폰, 포인트
                return [self configurePropertyCell:tableView atIndexPath:indexPath];
            case CPMyInfoCellTypeDataFree:
                //데이터 프리
                return [self configureDataFreeCell:tableView atIndexPath:indexPath];
            case CPMyInfoCellTypeMyPage:
                //마이페이지
                return [self configureMyPageCell:tableView atIndexPath:indexPath];
            case CPMyInfoCellTypeRecent:
                //최근본상품
                return [self configureRecentCell:tableView atIndexPath:indexPath];
            case CPMyInfoCellTypeSetting:
            default:
                //설정
                return [self configureSettingCell:tableView atIndexPath:indexPath];
                break;
        }
    }
    else {
        static NSString *cellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        [cell setBackgroundColor:UIColorFromRGB(0xf7f7f7)];
        
        UILabel *nodataLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(self.view.frame), 116)];
        [nodataLabel setBackgroundColor:[UIColor clearColor]];
        [nodataLabel setFont:[UIFont systemFontOfSize:13]];
        [nodataLabel setText:NSLocalizedString(@"NetworkBadRetry", nil)];
        [nodataLabel setTextColor:UIColorFromRGB(0x333333)];
        [nodataLabel setTextAlignment:NSTextAlignmentCenter];
        [cell.contentView addSubview:nodataLabel];
        
        return cell;
    }
}

- (UITableViewCell *)configurePropertyCell:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"propertyCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if ([cell.contentView subviews]) {
        for (UIView *subView in [cell.contentView subviews]) {
            [subView removeFromSuperview];
        }
    }
    
    [cell setBackgroundColor:UIColorFromRGB(0xffffff)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    CGFloat propertyViewWidth = CGRectGetWidth(myInfoTableView.frame)-20;
    
//    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 244, 138)];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 6, propertyViewWidth, 138)];
    //[backgroundImageView setImage:[UIImage imageNamed:@"bg_sider_my11_blue.png"]];
    [backgroundImageView setUserInteractionEnabled:YES];
    [cell.contentView addSubview:backgroundImageView];
    
    //쿠폰
    NSDictionary *coupon = rewardArea[@"item"][@"coupon"];
    UIView *couponView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, propertyViewWidth/2, 69)];
    couponView = [self makePropertyView:couponView propertyInfo:coupon];
    [backgroundImageView addSubview:couponView];
    
    //포인트
    NSDictionary *point = rewardArea[@"item"][@"point"];
    UIView *pointView = [[UIView alloc] initWithFrame:CGRectMake(propertyViewWidth/2, 0, propertyViewWidth/2, 69)];
    pointView = [self makePropertyView:pointView propertyInfo:point];
    [backgroundImageView addSubview:pointView];
    
    //마일리지
    NSDictionary *mileage = rewardArea[@"item"][@"mileage"];
    UIView *mileageView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(couponView.frame), propertyViewWidth/2, 69)];
    mileageView = [self makePropertyView:mileageView propertyInfo:mileage];
    [backgroundImageView addSubview:mileageView];
    
    //캐시
    NSDictionary *cash = rewardArea[@"item"][@"cash"];
    UIView *cashView = [[UIView alloc] initWithFrame:CGRectMake(propertyViewWidth/2, CGRectGetMaxY(pointView.frame), propertyViewWidth/2, 69)];
    cashView = [self makePropertyView:cashView propertyInfo:cash];
    [backgroundImageView addSubview:cashView];

    //구분선
    UIView *horizontalLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 68.5f, CGRectGetWidth(backgroundImageView.frame), 1)];
    [horizontalLineView setBackgroundColor:UIColorFromRGB(0xE3E4EA)];
    [backgroundImageView addSubview:horizontalLineView];
    
    //위
    UIView *verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(backgroundImageView.frame)/2 - 5,
                                                                             22.5f, 1, 24)]; //158
    [verticalLineView setBackgroundColor:UIColorFromRGB(0xE3E4EA)];
    [backgroundImageView addSubview:verticalLineView];
    
    //아래
    verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(backgroundImageView.frame)/2 - 5,
                                                                             CGRectGetHeight(backgroundImageView.frame)/2 + 22.5f, 1, 24)];
    [verticalLineView setBackgroundColor:UIColorFromRGB(0xE3E4EA)];
    [backgroundImageView addSubview:verticalLineView];

    //특별한 추가혜택
    UIImageView *benefitBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(backgroundImageView.frame), CGRectGetWidth(backgroundImageView.frame), 40)];
    //[benefitBgImageView setImage:[UIImage imageNamed:@"bg_sider_my11_blue2.png"]];
    [benefitBgImageView setBackgroundColor:UIColorFromRGB(0xF9FAFB)];
    [benefitBgImageView setUserInteractionEnabled:YES];
    [cell.contentView addSubview:benefitBgImageView];
    
    NSDictionary *benefit = rewardArea[@"item"][@"benefit"];
    
    UILabel *benefitTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, 0, 150, 36)];
    [benefitTitleLabel setBackgroundColor:[UIColor clearColor]];
    [benefitTitleLabel setFont:[UIFont systemFontOfSize:15]];
    [benefitTitleLabel setText:benefit[@"text"]];
    [benefitTitleLabel setTextColor:UIColorFromRGB(0x3D4050)];
    [benefitBgImageView addSubview:benefitTitleLabel];
    
    //화살표
    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(benefitBgImageView.frame)-18, 12, 6, 10)]; //22,12,8,12
    [arrowImageView setImage:[UIImage imageNamed:@"r_side_menu_arrow_01.png"]];
    [benefitBgImageView addSubview:arrowImageView];
    
    //건
    UILabel *unitLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(arrowImageView.frame)-20, 0, 15, 36)];
    [unitLabel setBackgroundColor:[UIColor clearColor]];
    [unitLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [unitLabel setText:@"건"];
    [unitLabel setTextColor:UIColorFromRGB(0x333333)];
    [benefitBgImageView addSubview:unitLabel];
    
    //숫자
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(unitLabel.frame)-15, 0, 15, 36)];
    [countLabel setBackgroundColor:[UIColor clearColor]];
    [countLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [countLabel setText:benefit[@"reward"]];
    [countLabel setTextColor:UIColorFromRGB(0xF62E3D)];
    [countLabel setTextAlignment:NSTextAlignmentRight];
    [benefitBgImageView addSubview:countLabel];
    
    //쿠폰
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(countLabel.frame)-30, 0, 30, 36)];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [nameLabel setText:@"쿠폰"];
    [nameLabel setTextColor:UIColorFromRGB(0x333333)];
    [nameLabel setTextAlignment:NSTextAlignmentRight];
    [benefitBgImageView addSubview:nameLabel];
    
    UIButton *benefitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [benefitButton setFrame:CGRectMake(CGRectGetMinX(nameLabel.frame), 0, 100, 36)];//60,36
    [benefitButton setBackgroundColor:[UIColor clearColor]];
    [benefitButton addTarget:self action:@selector(touchPropertyBenefitButton) forControlEvents:UIControlEventTouchUpInside];
    [benefitButton setAccessibilityLabel:@"특별한 추가 혜택" Hint:@"특별한 추가 혜택으로 이동합니다"];
    [benefitBgImageView addSubview:benefitButton];

    return cell;
}

- (UIView *)makePropertyView:(UIView *)view propertyInfo:(NSDictionary *)propertyInfo
{
    NSString *unitString;
    NSString *iconImageName;
    NSInteger tag;
    
    if ([propertyInfo[@"text"] isEqualToString:@"쿠폰"]) {
        unitString = @"장";
        iconImageName = @"r_side_ic_coupon.png";
        tag = CPPropertyTypeCoupon;
    }
    else if ([propertyInfo[@"text"] isEqualToString:@"포인트"]) {
        unitString = @"P";
        iconImageName = @"r_side_ic_point.png";
        tag = CPPropertyTypePoint;
    }
    else if ([propertyInfo[@"text"] isEqualToString:@"마일리지"]) {
        unitString = @"M";
        iconImageName = @"r_side_ic_mileage.png";
        tag = CPPropertyTypeMileage;
    }
    else if ([propertyInfo[@"text"] isEqualToString:@"캐시"]) {
        unitString = @"원";
        iconImageName = @"r_side_ic_cash.png";
        tag = CPPropertyTypeCash;
    }
    else {
        unitString = @"장";
        iconImageName = @"r_side_ic_coupon.png";
        tag = CPPropertyTypeCoupon;
    }
    
    UIButton *blankButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [blankButton setFrame:CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame))];
    [blankButton setBackgroundColor:[UIColor clearColor]];
    [blankButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xd4e9f2)] forState:UIControlStateHighlighted];
    [blankButton addTarget:self action:@selector(touchPropertyButton:) forControlEvents:UIControlEventTouchUpInside];
    [blankButton setTag:tag];
    [blankButton setAccessibilityLabel:propertyInfo[@"text"] Hint:@""];
    [view addSubview:blankButton];
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 14, 31, 22)]; // 28, 28 , 이미지 원사이즈 56, 40
    [iconImageView setImage:[UIImage imageNamed:iconImageName]];
    [blankButton addSubview:iconImageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-5, CGRectGetMaxY(iconImageView.frame)+6, 61, 14)];
     
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont systemFontOfSize:11]];
    [titleLabel setText:propertyInfo[@"text"]];
    [titleLabel setTextColor:UIColorFromRGB(0x666666)];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [blankButton addSubview:titleLabel];
    
    CGSize unitLabelSize = [unitString sizeWithFont:[UIFont systemFontOfSize:14]];
    
    UILabel *unitLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.frame)-(15+unitLabelSize.width), CGRectGetMaxY(titleLabel.frame)+6-40, unitLabelSize.width, 28)];
    [unitLabel setBackgroundColor:[UIColor clearColor]];
    [unitLabel setFont:[UIFont systemFontOfSize:15]]; //14
    [unitLabel setText:unitString];
    [unitLabel setTextColor:UIColorFromRGB(0x666666)];
    [blankButton addSubview:unitLabel];
    
    NSString *rewardString = propertyInfo[@"reward"];
    //rewardString = @"33333333";
    CGSize countLabelSize = [rewardString sizeWithFont:[UIFont systemFontOfSize:15]];
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(unitLabel.frame)-countLabelSize.width-2, CGRectGetMaxY(titleLabel.frame)+6-40, countLabelSize.width, 28)];
    [countLabel setBackgroundColor:[UIColor clearColor]];
    [countLabel setFont:[UIFont boldSystemFontOfSize:15]]; //14
    [countLabel setText:rewardString];
    [countLabel setTextColor:UIColorFromRGB(0x333333)];
    [blankButton addSubview:countLabel];
    
    return view;
}

- (UITableViewCell *)configureDataFreeCell:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"dataFreeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if ([cell.contentView subviews]) {
        for (UIView *subView in [cell.contentView subviews]) {
            [subView removeFromSuperview];
        }
    }
    
    [cell setBackgroundColor:UIColorFromRGB(0xffffff)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (dataFreeArea) {
        UIButton *dataFreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [dataFreeButton setFrame:CGRectMake(10, 0, CGRectGetWidth(myInfoTableView.frame)-20, 40)];
        [dataFreeButton setBackgroundColor:UIColorFromRGB(0xF0F7FD)];
        [dataFreeButton setAccessibilityLabel:@"데이터프리" Hint:@"데이터 사용량 확인으로 이동합니다"];
        [cell.contentView addSubview:dataFreeButton];
        
        if (!nilCheck(dataFreeArea[@"link"])) {
            [dataFreeButton setImage:[UIImage imageNamed:@"r_side_menu_arrow_02.png"] forState:UIControlStateNormal];
            [dataFreeButton setImage:[UIImage imageNamed:@"r_side_menu_arrow_02.png"] forState:UIControlStateHighlighted];
            [dataFreeButton setImageEdgeInsets:UIEdgeInsetsMake(0, CGRectGetWidth(myInfoTableView.frame)-55, 0, 0)];
            [dataFreeButton addTarget:self action:@selector(touchDataFreeButton) forControlEvents:UIControlEventTouchUpInside];
        }
        
        NSString *dataFreeText = dataFreeArea[@"text"];
        CGSize textLabelSize = [dataFreeText sizeWithFont:[UIFont systemFontOfSize:15]];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+10, 0, textLabelSize.width, 40)];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setFont:[UIFont systemFontOfSize:15]];
        [textLabel setText:dataFreeText];
        [textLabel setTextColor:UIColorFromRGB(0x3D4050)];
        [dataFreeButton addSubview:textLabel];
        
        NSString *useData = dataFreeArea[@"useData"];
        //useData = @"1000 MB";
        if (!nilCheck(useData)) {
            UILabel *dataLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textLabel.frame), 0, 70, 40)];
            [dataLabel setBackgroundColor:[UIColor clearColor]];
            [dataLabel setFont:[UIFont boldSystemFontOfSize:15]];
            [dataLabel setTextAlignment:NSTextAlignmentCenter];
            [dataLabel setTextColor:UIColorFromRGB(0x666FB1)];
            [dataLabel setText:useData];
            [dataFreeButton addSubview:dataLabel];
            
//            //underline
//            NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:useData];
//            [attrString addAttribute:(NSString *)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:kCTUnderlineStyleSingle] range:(NSRange){0, attrString.length}];
//            [dataLabel setAttributedText:attrString];
        }

    }
    
    return cell;
}

- (UITableViewCell *)configureMyPageCell:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"myPageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if ([cell.contentView subviews]) {
        for (UIView *subView in [cell.contentView subviews]) {
            [subView removeFromSuperview];
        }
    }
    
    [cell setBackgroundColor:UIColorFromRGB(0xebebeb)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    int i = 0;
    CGFloat buttonWidth = 0;
    CGFloat buttonHeight = -49;
    
    for (NSDictionary *myPage in mypageArea[@"items"]) {
        
        CGFloat width = CGRectGetWidth(tableView.frame)/2; ///2-0.5f;
        if (i % 2 == 0) {
            buttonHeight += 49;
            buttonWidth = 0;
        }
        
        UIButton *myPageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [myPageButton setFrame:CGRectMake(buttonWidth, buttonHeight, width, 50)]; //1+buttonHeight 48
        [myPageButton setTitle:myPage[@"text"] forState:UIControlStateNormal];
        [myPageButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        [myPageButton setTitleColor:UIColorFromRGB(0xf62e3d) forState:UIControlStateHighlighted];
        [myPageButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [myPageButton setBackgroundColor:UIColorFromRGB(0xffffff)];
        [myPageButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [myPageButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
        [myPageButton addTarget:self action:@selector(touchMyPageButton:) forControlEvents:UIControlEventTouchUpInside];
        [myPageButton setTag:i];
        [myPageButton setAccessibilityLabel:myPage[@"text"] Hint:@""];
        [cell.contentView addSubview:myPageButton];
        
        if (i % 2 == 0) { //0, 2, 4
            //세로 라인
            UIView *verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(width-10, buttonHeight+18 , 1, 14)];
            [verticalLineView setBackgroundColor:UIColorFromRGB(0xE3E4EA)];
            [cell.contentView addSubview:verticalLineView];
            
        }
        else { //1, 3, 5
            //가로 라인 (첫 라인 생성안함)
            if (i != 1) {
                UIView *horizontalLineView = [[UIView alloc] initWithFrame:CGRectMake(10 , buttonHeight+2 , (width*2)-20, 1)];
                [horizontalLineView setBackgroundColor:UIColorFromRGB(0xE3E4EA)];
                [cell.contentView addSubview:horizontalLineView];
            }
        }
     
        buttonWidth += width; //width+1
        i++;
    }
    
    return cell;
}

- (UITableViewCell *)configureRecentCell:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"recentCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if ([cell.contentView subviews]) {
        for (UIView *subView in [cell.contentView subviews]) {
            [subView removeFromSuperview];
        }
    }
    
    [cell setBackgroundColor:UIColorFromRGB(0xffffff)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 36)];
    [headerView setBackgroundColor:UIColorFromRGB(0xffffff)]; //0xf7f7f7
    [cell.contentView addSubview:headerView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 36)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [titleLabel setText:@"최근 본 상품"];
    [titleLabel setTextColor:UIColorFromRGB(0x6EB8FF)];
    [headerView addSubview:titleLabel];
    
    UIButton *arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [arrowButton setFrame:CGRectMake(CGRectGetWidth(headerView.frame)-85, 0, 70, 36)];
    [arrowButton setTitle:@"전체보기" forState:UIControlStateNormal];
    [arrowButton setTitleColor:UIColorFromRGB(0x757575) forState:UIControlStateNormal];
    [arrowButton setTitleColor:UIColorFromRGB(0xf62e3d) forState:UIControlStateHighlighted];
    [arrowButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [arrowButton addTarget:self action:@selector(touchProductListButton) forControlEvents:UIControlEventTouchUpInside];
    [arrowButton setAccessibilityLabel:@"전체보기" Hint:@"전체보기로 이동합니다"];
    [headerView addSubview:arrowButton];
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(arrowButton.frame)-5, 13, 5, 10)];
    [arrowImageView setImage:[UIImage imageNamed:@"bar_btn_arrow.png"]];
    [arrowButton addSubview:arrowImageView];
    
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(headerView.frame)-1, CGRectGetWidth(headerView.frame)-20, 4)];
    [lineImageView setImage:[UIImage imageNamed:@"sidemenu_titlebar_color.png"]];
    [headerView addSubview:lineImageView];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), CGRectGetWidth(self.view.frame), 116)];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setScrollsToTop:NO];
    [cell.contentView addSubview:scrollView];
    
    if ([todayViewArea[@"items"] count] > 0) {
        
        int i = 0;
        CGFloat offsetX = 10;
        for (NSDictionary *item in todayViewArea[@"items"]) {
            
            NSString *thumbnailUrl = item[@"todayImage"];
            
            CPThumbnailView *thumbnailView = [[CPThumbnailView alloc] initWithFrame:CGRectMake(offsetX, 10, 80, 80)];
            
            if ([thumbnailUrl length] > 0) {
                [thumbnailView.imageView sd_setImageWithURL:[NSURL URLWithString:thumbnailUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
            }
            else {
                [thumbnailView.imageView setImage:[UIImage imageNamed:@"thum_default.png"]];
            }
            
            [scrollView addSubview:thumbnailView];
            
            UIButton *productButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [productButton setFrame:thumbnailView.frame];
            [productButton addTarget:self action:@selector(touchProductButton:) forControlEvents:UIControlEventTouchUpInside];
            [productButton setTag:i];
            [productButton setAccessibilityLabel:@"최근 본 상품" Hint:@"최근 본 상품으로 이동합니다"];
            [productButton setImage:[UIImage imageWithColor:UIColorFromRGBA(0x000000, 0.3f) size:productButton.frame.size]
                           forState:UIControlStateHighlighted];
            [scrollView addSubview:productButton];
            
            UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, CGRectGetMaxY(thumbnailView.frame)+5, 80, 13)];
            [priceLabel setBackgroundColor:[UIColor clearColor]];
            [priceLabel setFont:[UIFont boldSystemFontOfSize:13]];
            [priceLabel setText:[Modules numberFormatComma:item[@"finalDscPrc"] appendUnit:@"원"]];
            [priceLabel setTextColor:UIColorFromRGB(0x333333)];
            [priceLabel setTextAlignment:NSTextAlignmentCenter];
            [scrollView addSubview:priceLabel];
            
            i++;
            offsetX += 90.f;
        }
        
        BOOL todayProductMore  = [@"Y" isEqualToString:todayViewArea[@"todayProductMore"]];
        if (todayProductMore) {
            UIView *moreView = [[UIView alloc] initWithFrame:CGRectMake(offsetX, 10, 80, 98)];
            moreView.backgroundColor = UIColorFromRGB(0xf0f7fd);
            [scrollView addSubview:moreView];
            
            UIImage *moreArrowImage = [UIImage imageNamed:@"r_side_menu_arrow_02.png"];
            
            UILabel *moreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            moreLabel.backgroundColor = [UIColor clearColor];
            moreLabel.textColor = UIColorFromRGB(0x3d4050);
            moreLabel.textAlignment = NSTextAlignmentLeft;
            moreLabel.font = [UIFont systemFontOfSize:15];
            moreLabel.text = @"더보기";
            [moreLabel sizeToFitWithFloor];
            [moreView addSubview:moreLabel];
            
            moreLabel.frame = CGRectMake((moreView.frame.size.width/2)-((moreLabel.frame.size.width+2+moreArrowImage.size.width)/2),
                                         (moreView.frame.size.height/2)-(moreLabel.frame.size.height/2),
                                         moreLabel.frame.size.width, moreLabel.frame.size.height);
        
            UIImageView *moreArrowView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(moreLabel.frame)+2,
                                                                                       (moreView.frame.size.height/2)-(moreArrowImage.size.height/2),
                                                                                       moreArrowImage.size.width, moreArrowImage.size.height)];
            moreArrowView.image = moreArrowImage;
            [moreView addSubview:moreArrowView];
            
            UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            moreBtn.frame = moreView.bounds;
            [moreBtn setImage:[UIImage imageWithColor:UIColorFromRGBA(0x000000, 0.3) size:moreBtn.frame.size]
                     forState:UIControlStateHighlighted];
            [moreBtn addTarget:self action:@selector(touchProductListButton) forControlEvents:UIControlEventTouchUpInside];
            [moreView addSubview:moreBtn];
            
            offsetX += 90.f;
        }
        
        [scrollView setContentSize:CGSizeMake(offsetX, 116)];
    }
    else {
        UILabel *nodataLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(self.view.frame), 116)];
        [nodataLabel setBackgroundColor:[UIColor clearColor]];
        [nodataLabel setFont:[UIFont systemFontOfSize:13]];
        [nodataLabel setText:@"고객님께서 최근 본 상품이 없습니다."];
        [nodataLabel setTextColor:UIColorFromRGB(0x333333)];
        [nodataLabel setTextAlignment:NSTextAlignmentCenter];
        [scrollView addSubview:nodataLabel];
    }
    
    return cell;
}

- (UITableViewCell *)configureSettingCell:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"settingCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if ([cell.contentView subviews]) {
        for (UIView *subView in [cell.contentView subviews]) {
            [subView removeFromSuperview];
        }
    }
    
    [cell setBackgroundColor:UIColorFromRGB(0xf7f7f7)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingButton setFrame:CGRectMake(10, 12, 60, 36)];
    [settingButton setBackgroundColor:[UIColor clearColor]];
    [settingButton setImage:[UIImage imageNamed:@"r_side_ic_setting.png"] forState:UIControlStateNormal];
    [settingButton setImage:[UIImage imageNamed:@"r_side_ic_setting.png"] forState:UIControlStateHighlighted];
    [settingButton setTitle:@"설정" forState:UIControlStateNormal];
    [settingButton setTitleColor:UIColorFromRGB(0x4D4D4D) forState:UIControlStateNormal];
    [settingButton setTitleColor:UIColorFromRGB(0xf62e3d) forState:UIControlStateHighlighted];
    [settingButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [settingButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    
    [settingButton addTarget:self action:@selector(touchSettingButton) forControlEvents:UIControlEventTouchUpInside];
    [settingButton setAccessibilityLabel:@"설정" Hint:@"설정으로 이동합니다"];
    [cell.contentView addSubview:settingButton];
    
    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeButton setFrame:CGRectMake(CGRectGetWidth(tableView.frame)/2+10, 12, 120, 36)]; ///2+10, 12, 110, 36
    [homeButton setImage:[UIImage imageNamed:@"r_side_ic_my11st.png"] forState:UIControlStateNormal];
    [homeButton setImage:[UIImage imageNamed:@"r_side_ic_my11st.png"] forState:UIControlStateHighlighted];
    [homeButton setTitle:@"나의11번가 홈" forState:UIControlStateNormal];
    [homeButton setTitleColor:UIColorFromRGB(0x4D4D4D) forState:UIControlStateNormal]; //757575
    [homeButton setTitleColor:UIColorFromRGB(0xf62e3d) forState:UIControlStateHighlighted];
    [homeButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [homeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [homeButton addTarget:self action:@selector(touchMyHomeButton) forControlEvents:UIControlEventTouchUpInside];
    [homeButton setAccessibilityLabel:@"나의11번가 홈" Hint:@"나의11번가 홈으로 이동합니다"];
    [cell.contentView addSubview:homeButton];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Selectors

- (void)touchLoginButton
{
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = app.homeViewController;
        
        [homeViewController openLoginViewController];
    }];}

- (void)touchAlimiButton
{
    NSString *url = [[CPCommonInfo sharedInfo] urlInfo][@"alimi"];
    
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = app.homeViewController;
        
        [homeViewController openWebViewControllerWithUrl:url animated:NO];
    }];
    
    //AccessLog - 알리미
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGE0201"];
}

- (void)touchBenefitButton
{
    NSString *url = [[CPCommonInfo sharedInfo] urlInfo][@"grpBnft"];
    
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = app.homeViewController;
        
        [homeViewController openWebViewControllerWithUrl:url animated:NO];
    }];
    
    //AccessLog - 등급혜택
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGE0101"];
}

- (void)touchMyHomeButton
{
    NSString *url = [[CPCommonInfo sharedInfo] urlInfo][@"my11st"];
    
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = app.homeViewController;
        
        [homeViewController openWebViewControllerWithUrl:url animated:NO];
    }];
    
    //AccessLog - 마이홈
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGE1701"];
}

- (void)touchSettingButton
{
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = app.homeViewController;
        
        [homeViewController openSettingViewController];
    }];
    
    //AccessLog - 설정
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGE1601"];
}

- (void)touchPropertyButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSDictionary *propertyItem;
    switch (button.tag) {
        case CPPropertyTypeCoupon:
            propertyItem = rewardArea[@"item"][@"coupon"];
//            //AccessLog - 쿠폰
//            [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGE0301"];
            break;
        case CPPropertyTypePoint:
            propertyItem = rewardArea[@"item"][@"point"];
//            //AccessLog - 포인트
//            [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGE0501"];
            break;
        case CPPropertyTypeMileage:
            propertyItem = rewardArea[@"item"][@"mileage"];
//            //AccessLog - 마일리지
//            [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGE0401"];
            break;
        case CPPropertyTypeCash:
            propertyItem = rewardArea[@"item"][@"cash"];
//            //AccessLog - 캐시
//            [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGE0601"];
            break;
        default:
            break;
    }
    
    NSString *link = propertyItem[@"link"];
    
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = app.homeViewController;
        
        [homeViewController openWebViewControllerWithUrl:link animated:NO];
    }];
    
    //AccessLog - 포인트 등
    NSString *accessLogCode = propertyItem[@"ac"];
    if (accessLogCode) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:accessLogCode];
    }
}

- (void)touchPropertyBenefitButton
{
    NSDictionary *benefit = rewardArea[@"item"][@"benefit"];
    NSString *link = benefit[@"link"];
    
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = app.homeViewController;
        
        [homeViewController openWebViewControllerWithUrl:link animated:NO];
    }];
    
    //AccessLog - 추가혜택
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGE0701"];
}

- (void)touchMyPageButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSDictionary *myPage = mypageArea[@"items"][button.tag];
    NSString *link = myPage[@"link"];
    
    //AccessLog - 마이페이지
    NSString *accessLogCode = myPage[@"ac"];
    if (accessLogCode) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:accessLogCode];
    }
    
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = app.homeViewController;
        
        [homeViewController openWebViewControllerWithUrl:link animated:NO];
    }];
}

- (void)touchProductListButton
{
    NSString *link = todayViewArea[@"menu"][@"link"];
    
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = app.homeViewController;
        
        [homeViewController openWebViewControllerWithUrl:link animated:NO];
    }];
    
    //AccessLog - 최근본상품 더보기
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGE1502"];
}

- (void)touchProductButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSDictionary *productItem = todayViewArea[@"items"][button.tag];
    NSString *link = productItem[@"link"];
    
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = app.homeViewController;
        
        [homeViewController openWebViewControllerWithUrl:link animated:NO];
    }];
    
    //AccessLog - 최근본상품 클릭
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGE1501"];
}

- (void)touchDataFreeButton
{
    NSString *link = dataFreeArea[@"link"];
    
    if (link) {
        [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            CPHomeViewController *homeViewController = app.homeViewController;
            
            [homeViewController openWebViewControllerWithUrl:link animated:NO];
        }];
    }
}

#pragma mark - CPLoadingView

- (void)startLoadingAnimation
{
    [self.view insertSubview:loadingView aboveSubview:myInfoTableView];
    [loadingView startAnimation];
}

- (void)stopLoadingAnimation
{
    [loadingView stopAnimation];
    [loadingView removeFromSuperview];
}

@end
