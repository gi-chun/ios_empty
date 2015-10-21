//
//  CPProductDeliveryView.m
//  11st
//
//  Created by spearhead on 2015. 6. 26..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductDeliveryView.h"
#import "TTTAttributedLabel.h"
#import "CPRESTClient.h"
#import "CPLoadingView.h"
#import "AccessLog.h"

typedef NS_ENUM(NSUInteger, CheckButtonType)
{
    CheckButtonTypeDlvCstPay = 0,
    CheckButtonTypeDispVisitDlv
};

#define CHANGE_BUTTON_TAG       100
#define kDeliveryDefaultHeight  44

@interface CPProductDeliveryView() <TTTAttributedLabelDelegate>
{
    NSMutableDictionary *product;
    NSMutableDictionary *deliveryInfo;
    NSMutableArray *addressSettingArray;
    NSMutableDictionary *addressSettingInfo;
    NSString *productNumber;
    
    UIImageView *arrowImageView;
    UIView *lineView;
    UIView *containerLineView;
    
    UIButton *confirmButton;
    UILabel *deliveryInfoLabel;
    
    UIView *containerView;
    CPLoadingView *loadingView;
    
    UIView *deliveryListContentView;
    
    //배송지 목록
    UIButton *deliveryListButton;
    //배송지 - baseAddr
    UIScrollView *deliveryBaseScrollView;
    UILabel *deliveryBaseLabel;
    
    //배송지 - dtlsAddr
    UIScrollView *deliveryDtlsScrollView;
    UILabel *deliveryDtlsLabel;
    
    //배송점 목록
    UIButton *shopListButton;
    
    BOOL isExpandView;
    BOOL isDlvCstPayCheck;
    BOOL isVisitDlvCheck;
    
    BOOL isShopList;
    NSInteger addedHeight;
}

@end

@implementation CPProductDeliveryView

- (void)releaseItem
{
    if (product)                    product = nil;
    if (deliveryInfo)               deliveryInfo = nil;
    if (addressSettingArray)        addressSettingArray = nil;
    if (addressSettingInfo)         addressSettingInfo = nil;
    if (productNumber)              productNumber = nil;
    if (arrowImageView)             arrowImageView = nil;
    if (lineView)                   lineView = nil;
    if (containerLineView)          containerLineView = nil;
    if (confirmButton)              confirmButton = nil;
    if (deliveryInfoLabel)          deliveryInfoLabel = nil;
    if (containerView)              containerView = nil;
    if (loadingView)                loadingView = nil;
    if (deliveryListContentView)    deliveryListContentView = nil;
    if (deliveryListButton)         deliveryListButton = nil;
    if (deliveryBaseScrollView)     deliveryBaseScrollView = nil;
    if (deliveryBaseLabel)          deliveryBaseLabel = nil;
    if (deliveryDtlsScrollView)     deliveryDtlsScrollView.delegate = nil, deliveryDtlsScrollView = nil;
    if (deliveryDtlsLabel)          deliveryDtlsLabel = nil;
    if (shopListButton)             shopListButton = nil;
}

- (void)removeFromSuperview
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    [super removeFromSuperview];
}

- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct productNumber:(NSString *)aProductNumber dlvCstPayChecked:(BOOL)aIsDlvCstPayChecked visitDlvChecked:(BOOL)aIsVisitDlvChecked
{
    if (self = [super initWithFrame:frame]) {
        
        product = [NSMutableDictionary dictionary];
        deliveryInfo = [NSMutableDictionary dictionary];
        addressSettingArray = [NSMutableArray array];
        addressSettingInfo = [NSMutableDictionary dictionary];
        
        product = [aProduct mutableCopy];
        
        if (product[@"prdDelivery"]) {
            
            deliveryInfo = [product[@"prdDelivery"] mutableCopy];
            productNumber = aProductNumber;
            isDlvCstPayCheck = aIsDlvCstPayChecked;
            isVisitDlvCheck = aIsVisitDlvChecked;
            [self initData];
            [self initLayout];
        }
        else {
            self.frame = CGRectMake(self.frame.origin.x,
                                    self.frame.origin.y,
                                    self.frame.size.width,
                                    0);
        }
    }
    return self;
}

- (void)initData
{
    self.selectedIndex = -1;
    self.selectedShopIndex = 0;
    isExpandView = NO;
    addedHeight = 0;
}

- (void)initLayout
{
    [self setBackgroundColor:[UIColor clearColor]];
    CGFloat cellOffsetY = 0;
    
    //LoadingView
    loadingView = [[CPLoadingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2-40,
                                                                  (CGRectGetHeight(self.frame)-kToolBarHeight)/2-40,
                                                                  80,
                                                                  80)];
    
    //배송
    NSString *title = deliveryInfo[@"label"];
    CGSize labelSize = GET_STRING_SIZE(title, [UIFont boldSystemFontOfSize:15], kScreenBoundsWidth);
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, labelSize.width, 0)];
    [titleLabel setTextColor:UIColorFromRGB(0x333333)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [titleLabel setText:title];
    [titleLabel sizeToFit];
    [self addSubview:titleLabel];
    
    //텍스트 (푸른색 영역의 텍스트)
    NSString *text = deliveryInfo[@"text"];
    CGSize textSize = GET_STRING_SIZE(text, [UIFont systemFontOfSize:15], kScreenBoundsWidth);
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame)+7, 15, textSize.width, 0)];
    [textLabel setTextColor:UIColorFromRGB(0x52bbff)];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setFont:[UIFont systemFontOfSize:15]];
    [textLabel setTextAlignment:NSTextAlignmentLeft];
    [textLabel setText:text];
    [textLabel sizeToFit];
    [self addSubview:textLabel];
    
    if (text) {
        cellOffsetY += CGRectGetMaxY(titleLabel.frame);
    }
    
    //배송 관련 도움말
    NSArray *dlvHelpArray = deliveryInfo[@"dlvHelp"];
    for (NSDictionary *dic in dlvHelpArray) {
        
        NSString *str = [dic objectForKey:@"text"];
        NSString *url = [dic objectForKey:@"helpLinkUrl"];
        CGSize strSize = GET_STRING_SIZE(str, [UIFont systemFontOfSize:15], [dlvHelpArray indexOfObject:dic] == 0 ? kScreenBoundsWidth-(CGRectGetMaxX(textLabel.frame)+3) : kScreenBoundsWidth-(CGRectGetMaxX(titleLabel.frame)+7));
        
        UILabel *helpLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [helpLabel setTextColor:UIColorFromRGB(0x999999)];
        [helpLabel setBackgroundColor:[UIColor clearColor]];
        [helpLabel setFont:[UIFont systemFontOfSize:15]];
        [helpLabel setText:str];
        [helpLabel setNumberOfLines:100];
        [self addSubview:helpLabel];
        
        //텍스트 설명
        UIButton *textIconButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [textIconButton setFrame:CGRectZero];
        [textIconButton setImage:[UIImage imageNamed:@"ic_pd_information.png"] forState:UIControlStateNormal];
        [textIconButton addTarget:self action:@selector(touchTextIconButton:) forControlEvents:UIControlEventTouchUpInside];
        [textIconButton setTag:[dlvHelpArray indexOfObject:dic]];
        [textIconButton setHidden:YES];
        [self addSubview:textIconButton];
        
        //index = 0 이면 textLabel옆에 배치
        if ([dlvHelpArray indexOfObject:dic] == 0) {
            BOOL isIcon = url && url.length > 0;
//            CGFloat helpLabelStrSize = isIcon?(kScreenBoundsWidth-CGRectGetMaxX(textLabel.frame)+3)-33:(kScreenBoundsWidth-CGRectGetMaxX(textLabel.frame)+3);
            
            [helpLabel setFrame:CGRectMake(CGRectGetMaxX(textLabel.frame)+3, 15, strSize.width, strSize.height)];
            
            if (isIcon) {
                [textIconButton setHidden:NO];
                [textIconButton setFrame:CGRectMake(CGRectGetMaxX(helpLabel.frame)+5, 15, 18, 18)];
            }
            
            //화면밖으로 넘어가면 줄바꿈 처리
            if (CGRectGetMaxX(textIconButton.frame) > kScreenBoundsWidth) {
                strSize = GET_STRING_SIZE(str, [UIFont systemFontOfSize:15], kScreenBoundsWidth-(CGRectGetMaxX(titleLabel.frame)+7));
                
                [helpLabel setFrame:CGRectMake(textLabel.frame.origin.x, cellOffsetY+6, strSize.width, 0)];
                [helpLabel sizeToFit];
                [textIconButton setFrame:CGRectMake(CGRectGetMaxX(helpLabel.frame)+5, cellOffsetY+6, 18, 18)];
            }
            cellOffsetY = CGRectGetMaxY(helpLabel.frame);
        }
        else {
            [helpLabel setFrame:CGRectMake(textLabel.frame.origin.x, cellOffsetY+6, strSize.width, 0)];
            [helpLabel sizeToFit];
            
            if (url && url.length > 0) {
                [textIconButton setHidden:NO];
                [textIconButton setFrame:CGRectMake(CGRectGetMaxX(helpLabel.frame)+5, cellOffsetY+6, 18, 18)];
            }
            
            cellOffsetY = cellOffsetY+6+CGRectGetHeight(helpLabel.frame);
        }
    }
    
    //선결제 여부
    NSString *dlvCstInstBasiCd = deliveryInfo[@"dlvCstInstBasiCd"];
    
    //무료배송이면 배송비 결제방법을 표시하지 않는다.
    if (!(dlvCstInstBasiCd && [dlvCstInstBasiCd isEqualToString:@"01"])) {
        //상품수령시 결제(착불) 노출여부 (true:노출, false:비노출) : "dlvCstPayYn":"Y|N"
        BOOL dlvCstPayYn = [deliveryInfo[@"dlvCstPayYn"] isEqualToString:@"Y"];
        if (dlvCstPayYn) {
            
            UIButton *dlvCstPayCheckButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [dlvCstPayCheckButton setFrame:CGRectMake(textLabel.frame.origin.x, cellOffsetY+12, 25, 25)];
            [dlvCstPayCheckButton setImage:[UIImage imageNamed:@"bt_pd_delivery_on.png"] forState:UIControlStateSelected];
            [dlvCstPayCheckButton setBackgroundImage:[UIImage imageNamed:@"bt_pd_delivery_off.png"] forState:UIControlStateNormal];
            [dlvCstPayCheckButton setBackgroundImage:[UIImage imageNamed:@"bt_pd_delivery_on.png"] forState:UIControlStateSelected];
            [dlvCstPayCheckButton setSelected:isDlvCstPayCheck];
            [dlvCstPayCheckButton setTag:CheckButtonTypeDlvCstPay];
            [dlvCstPayCheckButton addTarget:self action:@selector(touchCheckDlvCstPayButton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:dlvCstPayCheckButton];
            
            NSString *dlvCstPayStr = @"상품수령시 결제(착불)";
            
            //상품수령시 결제방법 코드 (01:선결제 가능, 02 선결제 불가, 03 선결제 필요)
            NSString *dlvCstPayTypCd = deliveryInfo[@"dlvCstPayTypCd"];
            
            if (dlvCstPayTypCd && [dlvCstPayTypCd isEqualToString:@"01"]) {
//                [dlvCstPayCheckButton setSelected:NO];
                [dlvCstPayCheckButton setHidden:NO];
            }
            else if (dlvCstPayTypCd && [dlvCstPayTypCd isEqualToString:@"02"]) { //02일 경우(디폴트 선택된 상태로 무조건착불처리)
                [dlvCstPayCheckButton setFrame:CGRectZero];
                [dlvCstPayCheckButton setHidden:YES];
            }
            else if (dlvCstPayTypCd && [dlvCstPayTypCd isEqualToString:@"03"]) {
                dlvCstPayStr = @"주문시결제(선결제)";
                [dlvCstPayCheckButton setFrame:CGRectZero];
                [dlvCstPayCheckButton setHidden:YES];
            }
            
            CGSize dlvCstPayStrSize = GET_STRING_SIZE(dlvCstPayStr, [UIFont systemFontOfSize:14], kScreenBoundsWidth);
            //01:선결제 가능 시에만 체크박스 표시
            CGFloat dlvCstPayLabelX = (dlvCstPayTypCd && [dlvCstPayTypCd isEqualToString:@"01"]) ? CGRectGetMaxX(dlvCstPayCheckButton.frame)+5 : textLabel.frame.origin.x;
            
            UILabel *dlvCstPayLabel = [[UILabel alloc] initWithFrame:CGRectMake(dlvCstPayLabelX, cellOffsetY+12, dlvCstPayStrSize.width, 26)];
            [dlvCstPayLabel setTextColor:UIColorFromRGB(0x333333)];
            [dlvCstPayLabel setBackgroundColor:[UIColor clearColor]];
            [dlvCstPayLabel setFont:[UIFont systemFontOfSize:14]];
            [dlvCstPayLabel setTextAlignment:NSTextAlignmentCenter];
            [dlvCstPayLabel setText:dlvCstPayStr];
            [self addSubview:dlvCstPayLabel];
            
            cellOffsetY += 12+CGRectGetHeight(dlvCstPayLabel.frame);
            
            //AccessLog - 배송료 결제 체크박스 노출
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPE01"];
        }
    }
    
    // 방문수령 노출 여부, false 일경우 앱 방문수령 layout 비 노출 : "dispVisitDlvYn":"Y|N",
    BOOL dispVisitDlvYn = [deliveryInfo[@"dispVisitDlvYn"] isEqualToString:@"Y"];
    if (dispVisitDlvYn) {
        
        UIButton *dispVisitDlvCheckButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [dispVisitDlvCheckButton setFrame:CGRectMake(textLabel.frame.origin.x, cellOffsetY+12, 25, 25)];
        [dispVisitDlvCheckButton setImage:[UIImage imageNamed:@"bt_pd_delivery_on.png"] forState:UIControlStateSelected];
        [dispVisitDlvCheckButton setBackgroundImage:[UIImage imageNamed:@"bt_pd_delivery_off.png"] forState:UIControlStateNormal];
        [dispVisitDlvCheckButton setBackgroundImage:[UIImage imageNamed:@"bt_pd_delivery_on.png"] forState:UIControlStateSelected];
        [dispVisitDlvCheckButton setSelected:isVisitDlvCheck];
        [dispVisitDlvCheckButton setTag:CheckButtonTypeDispVisitDlv];
        [dispVisitDlvCheckButton addTarget:self action:@selector(touchCheckDispVisitDlvButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dispVisitDlvCheckButton];
        
        NSString *dispVisitDlvStr = @"방문수령";
        CGSize dispVisitDlvStrSize = GET_STRING_SIZE(dispVisitDlvStr, [UIFont systemFontOfSize:14], kScreenBoundsWidth);
        
        UILabel *dispVisitDlvLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(dispVisitDlvCheckButton.frame)+5, dispVisitDlvCheckButton.frame.origin.y, dispVisitDlvStrSize.width, 26)];
        [dispVisitDlvLabel setTextColor:UIColorFromRGB(0x333333)];
        [dispVisitDlvLabel setBackgroundColor:[UIColor clearColor]];
        [dispVisitDlvLabel setFont:[UIFont systemFontOfSize:14]];
        [dispVisitDlvLabel setTextAlignment:NSTextAlignmentCenter];
        [dispVisitDlvLabel setText:dispVisitDlvStr];
        [self addSubview:dispVisitDlvLabel];
        
        
        if (deliveryInfo[@"visitDlvLinkUrl"]) {
            NSString *linkStr = @"위치보기";
            CGSize linkStrSize = GET_STRING_SIZE(linkStr, [UIFont systemFontOfSize:14], kScreenBoundsWidth);
            
            TTTAttributedLabel *linkLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(dispVisitDlvLabel.frame)+6, dispVisitDlvCheckButton.frame.origin.y, linkStrSize.width, 26)];
            [linkLabel setDelegate:self];
            [linkLabel setBackgroundColor:[UIColor clearColor]];
            [linkLabel setTextColor:UIColorFromRGB(0x999999)];
            [linkLabel setFont:[UIFont systemFontOfSize:14]];
            [linkLabel setTextAlignment:NSTextAlignmentCenter];
            [linkLabel setText:linkStr];
            [linkLabel addLinkToURL:deliveryInfo[@"visitDlvLinkUrl"] withRange:[linkLabel.text rangeOfString:linkStr]];
            [self addSubview:linkLabel];
        }
        
        cellOffsetY += 12+CGRectGetHeight(dispVisitDlvCheckButton.frame);
        
        //AccessLog - 방문수령 체크박스 노출
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPE03"];
    }
    
    
    // 예약상품 예약기간 (값이 있을 경우 노출) : planSelDy
    BOOL planSelDy = deliveryInfo[@"planSelDy"] && [deliveryInfo[@"planSelDy"] length] > 0;
    if (planSelDy) {
        
        NSString *planSelDyStr = [NSString stringWithFormat:@"예약기간 : %@", deliveryInfo[@"planSelDy"]];
        CGSize planSelDyStrSize = GET_STRING_SIZE(planSelDyStr, [UIFont systemFontOfSize:14], kScreenBoundsWidth);
        
        UILabel *planSelDyLabel = [[UILabel alloc] initWithFrame:CGRectMake(textLabel.frame.origin.x, cellOffsetY+12, planSelDyStrSize.width, 0)];
        [planSelDyLabel setTextColor:UIColorFromRGB(0x999999)];
        [planSelDyLabel setBackgroundColor:[UIColor clearColor]];
        [planSelDyLabel setFont:[UIFont systemFontOfSize:14]];
        [planSelDyLabel setTextAlignment:NSTextAlignmentLeft];
        [planSelDyLabel setText:planSelDyStr];
        [planSelDyLabel sizeToFit];
        [self addSubview:planSelDyLabel];
        
        cellOffsetY += 12+planSelDyStrSize.height;
    }
    
    
    // 예약상품 입고예정일 (값이 있을 경우 노출) : wrhsPlnDy
    BOOL wrhsPlnDy = deliveryInfo[@"wrhsPlnDy"] && [deliveryInfo[@"wrhsPlnDy"] length] > 0;
    if (wrhsPlnDy) {
        
        NSString *wrhsPlnDyStr = [NSString stringWithFormat:@"입고예정일 : %@", deliveryInfo[@"wrhsPlnDy"]];
        CGSize wrhsPlnDyStrSize = GET_STRING_SIZE(wrhsPlnDyStr, [UIFont systemFontOfSize:14], kScreenBoundsWidth);
        
        UILabel *wrhsPlnDyLabel = [[UILabel alloc] initWithFrame:CGRectMake(textLabel.frame.origin.x, cellOffsetY+(planSelDy?6:12), wrhsPlnDyStrSize.width, 0)];
        [wrhsPlnDyLabel setTextColor:UIColorFromRGB(0x999999)];
        [wrhsPlnDyLabel setBackgroundColor:[UIColor clearColor]];
        [wrhsPlnDyLabel setFont:[UIFont systemFontOfSize:14]];
        [wrhsPlnDyLabel setTextAlignment:NSTextAlignmentLeft];
        [wrhsPlnDyLabel setText:wrhsPlnDyStr];
        [wrhsPlnDyLabel sizeToFit];
        [self addSubview:wrhsPlnDyLabel];
        
        cellOffsetY += (planSelDy?6:12)+wrhsPlnDyStrSize.height;
    }
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, cellOffsetY+14, kScreenBoundsWidth, 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0xededed)];
    [self addSubview:lineView];
    
    cellOffsetY += 14+1;
    
    //배송지 설정 여부 : isMart : YN
    if (product[@"martInfo"] && [product[@"martInfo"][@"isMart"] isEqualToString:@"Y"] && [Modules checkLoginFromCookie]) {
        
        deliveryListContentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), CGRectGetWidth(self.frame), kDeliveryDefaultHeight)];
        [self addSubview:deliveryListContentView];
        
//            //배송
//            NSString *title = deliveryInfo[@"label"];
//            CGSize labelSize = GET_STRING_SIZE(title, [UIFont boldSystemFontOfSize:15], kScreenBoundsWidth);
//            
//            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, labelSize.width, 0)];//CGRectMake(10, 15, labelSize.width, 0)];
//            [titleLabel setTextColor:UIColorFromRGB(0x333333)];
//            [titleLabel setBackgroundColor:[UIColor clearColor]];
//            [titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
//            [titleLabel setTextAlignment:NSTextAlignmentLeft];
//            [titleLabel setText:title];
//            [titleLabel sizeToFit];
//            [deliveryListContentView addSubview:titleLabel];
        
        //배송지 존재여부
        BOOL existMart = NO;
        for (NSDictionary *dic in deliveryInfo[@"dlvAddrList"]) {
            
            if ([[dic objectForKey:@"martAddrYn"] isEqualToString:@"Y"]) {
                existMart = YES;
                break;
            }
        }
        
        //텍스트 (푸른색 영역의 텍스트)
        NSString *text = existMart ? @"배송지 변경" :@"배송지 설정 후 주문이 가능합니다.";
        CGSize textSize = GET_STRING_SIZE(text, [UIFont systemFontOfSize:15], kScreenBoundsWidth);
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, textSize.width, 0)];
        [textLabel setTextColor:UIColorFromRGB(0x52bbff)];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setFont:[UIFont systemFontOfSize:15]];
        [textLabel setTextAlignment:NSTextAlignmentLeft];
        [textLabel setText:text];
        [textLabel sizeToFit];
        [deliveryListContentView addSubview:textLabel];
        
        //arrow
        arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenBoundsWidth-10-11, (kDeliveryDefaultHeight-6)/2+1, 11, 6)];
        [arrowImageView setImage:[UIImage imageNamed:@"ic_pd_arrow_down_03.png"]];
        [deliveryListContentView addSubview:arrowImageView];
        
        //설정/변경
        NSString *changeStr = existMart ? @"변경" : @"설정";
        CGSize changeStrSize = GET_STRING_SIZE(changeStr, [UIFont systemFontOfSize:13], kScreenBoundsWidth);
        
        UILabel *changeLabel = [[UILabel alloc] initWithFrame:CGRectMake(arrowImageView.frame.origin.x-5-changeStrSize.width, 16, changeStrSize.width, 0)];
        [changeLabel setTextColor:UIColorFromRGB(0x283593)];
        [changeLabel setBackgroundColor:[UIColor clearColor]];
        [changeLabel setFont:[UIFont systemFontOfSize:13]];
        [changeLabel setTextAlignment:NSTextAlignmentLeft];
        [changeLabel setText:changeStr];
        [changeLabel sizeToFit];
        [deliveryListContentView addSubview:changeLabel];
        
        UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(deliveryListContentView.frame)-1, kScreenBoundsWidth, 1)];
        [underLineView setBackgroundColor:UIColorFromRGB(0xededed)];
        [deliveryListContentView addSubview:underLineView];
        
        UIButton *blankButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [blankButton setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), kDeliveryDefaultHeight)];
        [blankButton setTag:CHANGE_BUTTON_TAG];
        [blankButton addTarget:self action:@selector(touchDropDownButton:) forControlEvents:UIControlEventTouchUpInside];
        [blankButton setSelected:NO];
        [deliveryListContentView addSubview:blankButton];
        
        cellOffsetY += kDeliveryDefaultHeight;
        
        //배송지설정 영역
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, kDeliveryDefaultHeight, CGRectGetWidth(self.frame), 0)];
        [containerView setBackgroundColor:UIColorFromRGB(0xf2f2f2)];
        [containerView setClipsToBounds:YES];
        [deliveryListContentView addSubview:containerView];
        
        
        NSString *deliveryTitle = @"배송지 설정";
        CGSize deliveryTitleSize = GET_STRING_SIZE(deliveryTitle, [UIFont systemFontOfSize:14], kScreenBoundsWidth);
        
        UILabel *deliveryTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, deliveryTitleSize.width, 0)];
        [deliveryTitleLabel setTextColor:UIColorFromRGB(0x333333)];
        [deliveryTitleLabel setBackgroundColor:[UIColor clearColor]];
        [deliveryTitleLabel setFont:[UIFont systemFontOfSize:14]];
        [deliveryTitleLabel setTextAlignment:NSTextAlignmentLeft];
        [deliveryTitleLabel setText:deliveryTitle];
        [deliveryTitleLabel sizeToFit];
        [containerView addSubview:deliveryTitleLabel];
        
        NSString *deliveryDesc = @"지점에 따라 상품의 가격/재고가 달라질 수 있습니다.";
        CGSize deliveryDescSize = GET_STRING_SIZE(deliveryDesc, [UIFont systemFontOfSize:13], kScreenBoundsWidth);
        
        UILabel *deliveryDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(deliveryTitleLabel.frame)+6, deliveryDescSize.width, 0)];
        [deliveryDescLabel setTextColor:UIColorFromRGB(0x999999)];
        [deliveryDescLabel setBackgroundColor:[UIColor clearColor]];
        [deliveryDescLabel setFont:[UIFont systemFontOfSize:13]];
        [deliveryDescLabel setTextAlignment:NSTextAlignmentLeft];
        [deliveryDescLabel setText:deliveryDesc];
        [deliveryDescLabel sizeToFit];
        [containerView addSubview:deliveryDescLabel];
        
        //배송지 추가
        UIImage *addDeliveryImage = [[UIImage imageNamed:@"bt_pd_delivery.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        
        UIButton *addDeliveryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addDeliveryButton setFrame:CGRectMake(kScreenBoundsWidth-10-74, CGRectGetMaxY(deliveryDescLabel.frame)+9, 74, 32)];
        [addDeliveryButton setTitle:@"배송지 추가" forState:UIControlStateNormal];
        [addDeliveryButton setTitleColor:UIColorFromRGB(0x717588) forState:UIControlStateNormal];
        [addDeliveryButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [addDeliveryButton setBackgroundImage:addDeliveryImage forState:UIControlStateNormal];
        [addDeliveryButton addTarget:self action:@selector(touchAddDeliveryAddress:) forControlEvents:UIControlEventTouchUpInside];
        [addDeliveryButton setSelected:NO];
        [containerView addSubview:addDeliveryButton];
        
        
        //배송지 목록
        UIImage *deliveryListImage = [[UIImage imageNamed:@"layer_pd_inputbox.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        
        deliveryListButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deliveryListButton setFrame:CGRectMake(10, CGRectGetMaxY(deliveryDescLabel.frame)+9, addDeliveryButton.frame.origin.x-15, 32)];
        [deliveryListButton setTitle:@"배송지 목록" forState:UIControlStateNormal];
        [deliveryListButton setTitleColor:UIColorFromRGB(0xb7b7b7) forState:UIControlStateNormal];
        [deliveryListButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [deliveryListButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [deliveryListButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 9, 0, 0)];
        [deliveryListButton setBackgroundImage:deliveryListImage forState:UIControlStateNormal];
        [deliveryListButton addTarget:self action:@selector(touchDeliveryList:) forControlEvents:UIControlEventTouchUpInside];
        [deliveryListButton setTag:self.selectedIndex];
        [containerView addSubview:deliveryListButton];
        
        UIImageView *inputDownIconView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(deliveryListButton.frame)-32, 0, 32, 32)];
        [inputDownIconView setImage:[UIImage imageNamed:@"layer_pd_input_down.png"]];
        [deliveryListButton addSubview:inputDownIconView];
        
        //배송지 - baseAddr
        UIImageView *deliveryBaseLocationView = [[UIImageView alloc] init];
        [deliveryBaseLocationView setFrame:CGRectMake(10, CGRectGetMaxY(deliveryListButton.frame)+5, kScreenBoundsWidth-20, 32)];
        [deliveryBaseLocationView setImage:deliveryListImage];
        [deliveryBaseLocationView setUserInteractionEnabled:YES];
        [containerView addSubview:deliveryBaseLocationView];
        
        deliveryBaseScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(9, 0, kScreenBoundsWidth-38, deliveryBaseLocationView.frame.size.height)];
        [deliveryBaseScrollView setContentSize:CGSizeMake(CGRectGetWidth(deliveryBaseScrollView.frame), CGRectGetHeight(deliveryBaseScrollView.frame))];
        [deliveryBaseScrollView setBackgroundColor:[UIColor clearColor]];
        [deliveryBaseScrollView setBounces:NO];
        [deliveryBaseLocationView addSubview:deliveryBaseScrollView];
        
        deliveryBaseLabel = [[UILabel alloc] init];
        [deliveryBaseLabel setTextColor:UIColorFromRGB(0x333333)];
        [deliveryBaseLabel setBackgroundColor:[UIColor clearColor]];
        [deliveryBaseLabel setFont:[UIFont systemFontOfSize:14]];
        [deliveryBaseLabel setTextAlignment:NSTextAlignmentLeft];
        [deliveryBaseScrollView addSubview:deliveryBaseLabel];
        
        
        //배송지 - dtlsAddr
        UIImageView *deliveryDtlsLocationView = [[UIImageView alloc] init];
        [deliveryDtlsLocationView setFrame:CGRectMake(10, CGRectGetMaxY(deliveryBaseLocationView.frame)+5, kScreenBoundsWidth-20, 32)];
        [deliveryDtlsLocationView setImage:deliveryListImage];
        [deliveryDtlsLocationView setUserInteractionEnabled:YES];
        [containerView addSubview:deliveryDtlsLocationView];
        
        deliveryDtlsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(9, 0, kScreenBoundsWidth-38, deliveryDtlsLocationView.frame.size.height)];
        [deliveryDtlsScrollView setContentSize:CGSizeMake(CGRectGetWidth(deliveryDtlsScrollView.frame), CGRectGetHeight(deliveryDtlsScrollView.frame))];
        [deliveryDtlsScrollView setBackgroundColor:[UIColor clearColor]];
        [deliveryDtlsScrollView setBounces:NO];
        [deliveryDtlsLocationView addSubview:deliveryDtlsScrollView];
        
        deliveryDtlsLabel = [[UILabel alloc] init];
        [deliveryDtlsLabel setTextColor:UIColorFromRGB(0x333333)];
        [deliveryDtlsLabel setBackgroundColor:[UIColor clearColor]];
        [deliveryDtlsLabel setFont:[UIFont systemFontOfSize:14]];
        [deliveryDtlsLabel setTextAlignment:NSTextAlignmentLeft];
        [deliveryDtlsScrollView addSubview:deliveryDtlsLabel];
        
        
        //배송지정보
        for (NSDictionary *dic in deliveryInfo[@"dlvAddrList"]) {
            
            if ([[dic objectForKey:@"martAddrYn"] isEqualToString:@"Y"]) {
                self.selectedIndex = [deliveryInfo[@"dlvAddrList"] indexOfObject:dic];
                [deliveryListButton setTitle:[dic objectForKey:@"addrNm"] forState:UIControlStateNormal];
                
                NSString *deliveryBaseLocationStr = [dic objectForKey:@"baseAddr"];
                CGSize deliveryBaseLocationStrSize = GET_STRING_SIZE(deliveryBaseLocationStr, [UIFont systemFontOfSize:14], 10000);
                
                [deliveryBaseScrollView setContentSize:CGSizeMake(deliveryBaseLocationStrSize.width, CGRectGetHeight(deliveryBaseScrollView.frame))];
                [deliveryBaseLabel setText:deliveryBaseLocationStr];
                [deliveryBaseLabel setFrame:CGRectMake(0, 0, deliveryBaseLocationStrSize.width, deliveryBaseScrollView.frame.size.height)];
                
                NSString *deliveryDtlsLocationStr = [dic objectForKey:@"dtlsAddr"];
                CGSize deliveryDtlsLocationStrSize = GET_STRING_SIZE(deliveryDtlsLocationStr, [UIFont systemFontOfSize:14], 10000);
                
                [deliveryDtlsScrollView setContentSize:CGSizeMake(deliveryDtlsLocationStrSize.width, CGRectGetHeight(deliveryDtlsScrollView.frame))];
                [deliveryDtlsLabel setText:deliveryDtlsLocationStr];
                [deliveryDtlsLabel setFrame:CGRectMake(0, 0, deliveryDtlsLocationStrSize.width, deliveryDtlsScrollView.frame.size.height)];
                break;
            }
        }
        
        //설정
        UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [settingButton setFrame:CGRectMake(kScreenBoundsWidth-10-42, CGRectGetMaxY(deliveryDtlsLocationView.frame)+5, 42, 32)];
        [settingButton setTitle:@"설정" forState:UIControlStateNormal];
        [settingButton setTitleColor:UIColorFromRGB(0x717588) forState:UIControlStateNormal];
        [settingButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [settingButton setBackgroundImage:addDeliveryImage forState:UIControlStateNormal];
        [settingButton addTarget:self action:@selector(getAddressSettingData:) forControlEvents:UIControlEventTouchUpInside];
        [settingButton setSelected:NO];
        [containerView addSubview:settingButton];
        
        //취소
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setFrame:CGRectMake(settingButton.frame.origin.x-5-42, CGRectGetMaxY(deliveryDtlsLocationView.frame)+5, 42, 32)];
        [cancelButton setTitle:@"취소" forState:UIControlStateNormal];
        [cancelButton setTitleColor:UIColorFromRGB(0x717588) forState:UIControlStateNormal];
        [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [cancelButton setBackgroundImage:addDeliveryImage forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(touchDropDownButton:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setSelected:NO];
        [containerView addSubview:cancelButton];
        
        containerLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(cancelButton.frame)+15, kScreenBoundsWidth, 1)];
        [containerLineView setBackgroundColor:UIColorFromRGB(0xededed)];
        [containerView addSubview:containerLineView];
        
        [deliveryListContentView setFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), CGRectGetWidth(self.frame), CGRectGetMaxY(containerLineView.frame))];
        
        //배송점 확인
        UIImage *confirmImage = [[UIImage imageNamed:@"bt_pd_delivery.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        
        confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [confirmButton setFrame:CGRectMake(kScreenBoundsWidth-10-42, CGRectGetMaxY(settingButton.frame)+5, 42, 32)];
        [confirmButton setTitle:@"확인" forState:UIControlStateNormal];
        [confirmButton setTitleColor:UIColorFromRGB(0x5764e6) forState:UIControlStateNormal];
        [confirmButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [confirmButton setBackgroundImage:confirmImage forState:UIControlStateNormal];
        [confirmButton addTarget:self action:@selector(getConfirmData) forControlEvents:UIControlEventTouchUpInside];
        [confirmButton setHidden:YES];
        [containerView addSubview:confirmButton];
        
        //배송점 목록
        UIImage *shopListImage = [[UIImage imageNamed:@"layer_pd_inputbox.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        NSString *shopListStr = addressSettingArray && addressSettingArray.count > 0 ? addressSettingArray[self.selectedShopIndex][@"strNm"] : @"";
        
        shopListButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shopListButton setFrame:CGRectMake(10, CGRectGetMaxY(deliveryInfoLabel.frame)+5, kScreenBoundsWidth-20, 32)];
        [shopListButton setTitle:shopListStr forState:UIControlStateNormal];
        [shopListButton setTitleColor:UIColorFromRGB(0xb7b7b7) forState:UIControlStateNormal];
        [shopListButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [shopListButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [shopListButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 9, 0, 0)];
        [shopListButton setBackgroundImage:shopListImage forState:UIControlStateNormal];
        [shopListButton addTarget:self action:@selector(touchShopList:) forControlEvents:UIControlEventTouchUpInside];
        [shopListButton setTag:self.selectedShopIndex];
        [shopListButton setHidden:YES];
        [containerView addSubview:shopListButton];
        
        UIImageView *inputDownListIconView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(shopListButton.frame)-32, 0, 32, 32)];
        [inputDownListIconView setImage:[UIImage imageNamed:@"layer_pd_input_down.png"]];
        [shopListButton addSubview:inputDownListIconView];
        
        //배송지 정보
        deliveryInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(settingButton.frame)+5, confirmButton.frame.origin.x-10, 32)];
        [deliveryInfoLabel setTextColor:UIColorFromRGB(0x999999)];
        [deliveryInfoLabel setBackgroundColor:[UIColor clearColor]];
        [deliveryInfoLabel setFont:[UIFont systemFontOfSize:13]];
        [deliveryInfoLabel setTextAlignment:NSTextAlignmentLeft];
        [deliveryInfoLabel setHidden:YES];
        [deliveryInfoLabel setNumberOfLines:0];
        [containerView addSubview:deliveryInfoLabel];
    }
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            cellOffsetY);
}

//배송지정보 세팅
- (void)setDeliveryAddressView
{
    NSDictionary *dict = deliveryInfo[@"dlvAddrList"][self.selectedIndex];
    
    [deliveryListButton setTitle:[dict objectForKey:@"addrNm"] forState:UIControlStateNormal];
    
    NSString *deliveryBaseLocationStr = [dict objectForKey:@"baseAddr"];
    CGSize deliveryBaseLocationStrSize = GET_STRING_SIZE(deliveryBaseLocationStr, [UIFont systemFontOfSize:14], 10000);
    
    [deliveryBaseScrollView setContentSize:CGSizeMake(deliveryBaseLocationStrSize.width, CGRectGetHeight(deliveryBaseScrollView.frame))];
    [deliveryBaseLabel setText:deliveryBaseLocationStr];
    [deliveryBaseLabel setFrame:CGRectMake(0, 0, deliveryBaseLocationStrSize.width, deliveryBaseScrollView.frame.size.height)];
    
    
    NSString *deliveryDtlsLocationStr = [dict objectForKey:@"dtlsAddr"];
    CGSize deliveryDtlsLocationStrSize = GET_STRING_SIZE(deliveryDtlsLocationStr, [UIFont systemFontOfSize:14], 10000);
    
    [deliveryDtlsScrollView setContentSize:CGSizeMake(deliveryDtlsLocationStrSize.width, CGRectGetHeight(deliveryDtlsScrollView.frame))];
    [deliveryDtlsLabel setText:deliveryDtlsLocationStr];
    [deliveryDtlsLabel setFrame:CGRectMake(0, 0, deliveryDtlsLocationStrSize.width, deliveryDtlsScrollView.frame.size.height)];
}

//배송점정보 세팅
- (void)setShopAddressView
{
    NSDictionary *dict = addressSettingArray[self.selectedShopIndex];
    
    [addressSettingInfo removeAllObjects];
    addressSettingInfo = [dict mutableCopy];
    
    [shopListButton setTitle:[dict objectForKey:@"strNm"] forState:UIControlStateNormal];
}

- (void)reloadView:(NSString *)url
{
    //로그인 시 처리
    if (product[@"martInfo"] && [product[@"martInfo"][@"isMart"] isEqualToString:@"Y"] && [Modules checkLoginFromCookie]) {
        [self getProductData:url];
    }
}

#pragma mark - API

- (void)getProductData:(NSString *)url
{
//    [self startLoadingAnimation];
    
    void (^productSuccess)(NSDictionary *);
    productSuccess = ^(NSDictionary *productData) {
        
        if (productData && [productData count] > 0) {
            
            [product removeAllObjects];
            [deliveryInfo removeAllObjects];
            
            product = [productData[@"appDetail"] mutableCopy];
            deliveryInfo = [product[@"prdDelivery"] mutableCopy];
            
            for (UIView *subView in [self subviews]) {
                [subView removeFromSuperview];
            }
            
            [self initData];
            [self initLayout];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setSelected:YES];
            [button setTag:CHANGE_BUTTON_TAG];
            [self touchDropDownButton:button];
        }
        
        [self stopLoadingAnimation];
    };
    
    void (^productFailure)(NSError *);
    productFailure = ^(NSError *error) {
        [self stopLoadingAnimation];
    };
    
    if (url) {
        [[CPRESTClient sharedClient] requestProductDetailWithUrl:url
                                                         success:productSuccess
                                                         failure:productFailure];
    }
}

- (void)getAddressSettingData:(id)sender
{
    //배송지 미설정 시
    if (self.selectedIndex == -1) {
        NSString *resultMsg = @"배송지 설정 후 주문이 가능합니다.";
        DEFAULT_ALERT(STR_APP_TITLE, resultMsg);
        
        return;
    }
    
//    [self startLoadingAnimation];
    
    void (^addressSettingSuccess)(NSDictionary *);
    addressSettingSuccess = ^(NSDictionary *addressSettingData) {
        
        if (addressSettingData && [addressSettingData count] > 0) {
            
            if ([addressSettingData[@"resultCode"] isEqualToString:@"LOGIN"]) {
                
                //로그인 후 이용
                NSString *resultMsg = addressSettingData[@"resultMsg"];
                DEFAULT_ALERT(STR_APP_TITLE, resultMsg);
            }
            else if ([addressSettingData[@"resultCode"] isEqualToString:@"SUCCESS"]) {
                
                [addressSettingInfo removeAllObjects];
                
                NSArray *mdaList = addressSettingData[@"mdaList"];
                NSString *deliveryInfoStr = @"";
                
                if (mdaList && mdaList.count > 0) {
                    if (mdaList.count == 1) {
                        isShopList = NO;
                        addressSettingInfo = [mdaList[0] mutableCopy];
                        
                        if (addressSettingInfo[@"strNm"] && [addressSettingInfo[@"strNm"] length] > 0) {
                            [confirmButton setHidden:NO];
                            deliveryInfoStr = [NSString stringWithFormat:@"%@ %@에서 배송됩니다.", addressSettingInfo[@"martNm"], addressSettingInfo[@"strNm"]];
                        }
                        else {
                            [confirmButton setHidden:YES];
                            deliveryInfoStr = @"해당 배송지 주소로 이용 가능한 지점이 없습니다. 배송지를 변경하여 주세요.";
                        }
                        
                        [self setContainerAddView:deliveryInfoStr];
                    }
                    else {
                        [addressSettingArray removeAllObjects];
                        addressSettingArray = [addressSettingData[@"mdaList"] mutableCopy];
                        [confirmButton setHidden:NO];
                        isShopList = YES;
                        
                        addressSettingInfo = [mdaList[0] mutableCopy];
                        [self setContainerAddListView];
                    }
                }
            }
        }
        [self stopLoadingAnimation];
    };
    
    void (^addressSettingFailure)(NSError *);
    addressSettingFailure = ^(NSError *error) {
        [self stopLoadingAnimation];
    };
    
    NSString *url = PRODUCT_DELIVARY_SEARCH;
    url = [NSString stringWithFormat:@"%@&addrSeq=%@&martNo=%@&multiMartYn=%@", url, deliveryInfo[@"dlvAddrList"][self.selectedIndex][@"addrSeq"], product[@"martInfo"][@"martNo"], @"N"];
    
    if (url) {
        [[CPRESTClient sharedClient] requestProductDetailWithUrl:url
                                                         success:addressSettingSuccess
                                                         failure:addressSettingFailure];
    }
}

- (void)getConfirmData
{
    [self startLoadingAnimation];
    
    void (^confirmSuccess)(NSDictionary *);
    confirmSuccess = ^(NSDictionary *confirmData) {
        
        if (confirmData && [confirmData count] > 0) {
            
            NSString *resultMsg = confirmData[@"resultMsg"];
            DEFAULT_ALERT(STR_APP_TITLE, resultMsg);
            
            //정보 리프래시
            [self productReload];
        }
        [self stopLoadingAnimation];
    };
    
    void (^confirmFailure)(NSError *);
    confirmFailure = ^(NSError *error) {
        [self stopLoadingAnimation];
    };
    
    NSString *url = PRODUCT_DELIVARY_STORE;
//    url = [NSString stringWithFormat:@"%@&addrSeq=%@&martNo=%@&strNo=%@", url, deliveryInfo[@"dlvAddrList"][self.selectedIndex][@"addrSeq"], product[@"martInfo"][@"martNo"], product[@"martInfo"][@"strNo"]];
    url = [NSString stringWithFormat:@"%@&addrSeq=%@&martNo=%@&strNo=%@", url, addressSettingInfo[@"addrSeq"], product[@"martInfo"][@"martNo"], addressSettingInfo[@"strNo"]];
    
    if (url) {
        [[CPRESTClient sharedClient] requestProductDetailWithUrl:url
                                                         success:confirmSuccess
                                                         failure:confirmFailure];
    }
}

#pragma mark - Private Methods

- (BOOL)isDlvCstPayChecked
{
    return isDlvCstPayCheck;
}

- (BOOL)isVisitDlvChecked
{
    return isVisitDlvCheck;
}

- (CGFloat)getListButtonY
{
    return deliveryListContentView.frame.origin.y+containerView.frame.origin.y+CGRectGetMaxY(deliveryListButton.frame);
}

- (CGFloat)getShopListButtonY
{
    return deliveryListContentView.frame.origin.y+containerView.frame.origin.y+CGRectGetMaxY(shopListButton.frame);
}

- (void)productReload
{
    if ([self.delegate respondsToSelector:@selector(productReload)]) {
        [self.delegate productReload];
    }
}

- (void)checkDlvCstPayYn
{
    BOOL dlvCstPayYn = [deliveryInfo[@"dlvCstPayYn"] isEqualToString:@"Y"];
    
    //상품수령시 결제방법 코드 (01:선결제 가능, 02 선결제 불가, 03 선결제 필요)
    NSString *dlvCstPayTypCd = deliveryInfo[@"dlvCstPayTypCd"];
    isDlvCstPayCheck = dlvCstPayYn && dlvCstPayTypCd && ![dlvCstPayTypCd isEqualToString:@"01"];
    
    //구매하기에 체크여부 넘겨줌
    if ([self.delegate respondsToSelector:@selector(didTouchDlvCstPayCheckButton:)]) {
        [self.delegate didTouchDlvCstPayCheckButton:isDlvCstPayCheck];
    }
}

#pragma mark - Selectors

- (void)touchDropDownButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (button.tag == CHANGE_BUTTON_TAG && !button.isSelected) {
        [arrowImageView setImage:[UIImage imageNamed:@"ic_pd_arrow_up_02.png"]];
        [containerView setFrame:CGRectMake(0, kDeliveryDefaultHeight, CGRectGetWidth(self.frame), CGRectGetMaxY(containerLineView.frame))];
        [deliveryListContentView setFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(containerView.frame)+kDeliveryDefaultHeight)];
    }
    else {
        [arrowImageView setImage:[UIImage imageNamed:@"ic_pd_arrow_down_03.png"]];
        [containerView setFrame:CGRectMake(0, kDeliveryDefaultHeight, CGRectGetWidth(self.frame), 0)];
        [deliveryListContentView setFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), CGRectGetWidth(self.frame), CGRectGetMaxY(lineView.frame))];
    }
    
    if ([self.delegate respondsToSelector:@selector(didTouchExpandButton: height:)]) {
        [self.delegate didTouchExpandButton:CPProductViewTypeDelivery height:kDeliveryDefaultHeight+CGRectGetMaxY(lineView.frame)+CGRectGetHeight(containerView.frame)];
    }
    
    //목록뷰 닫기
    if ([self.delegate respondsToSelector:@selector(removeDeliveryListView)]) {
        [self.delegate removeDeliveryListView];
    }
    
    [button setSelected:!button.isSelected];
}

//상품수령시 결제(착불) 체크여부
- (void)touchCheckDlvCstPayButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    isDlvCstPayCheck = button.selected;
    
    //구매하기에 체크여부 넘겨줌
    if ([self.delegate respondsToSelector:@selector(didTouchDlvCstPayCheckButton:)]) {
        [self.delegate didTouchDlvCstPayCheckButton:button.selected];
    }
    
    //AccessLog - 배송료 결제 체크 박스 클릭
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPE02"];
}

//방문수령 체크박스
- (void)touchCheckDispVisitDlvButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    isVisitDlvCheck = button.selected;
    
    //구매하기에 체크여부 넘겨줌
    if ([self.delegate respondsToSelector:@selector(didTouchVisitDlvCheckButton:)]) {
        [self.delegate didTouchVisitDlvCheckButton:button.selected];
    }
    
    //AccessLog - 방문수령 체크 박스 클릭
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPE04"];
}

//배송지 추가
- (void)touchAddDeliveryAddress:(id)sender
{
    NSString *addDeliveryUrl = deliveryInfo[@"dlvAddrSetLinkUrl"];
    
    if ([self.delegate respondsToSelector:@selector(didTouchAddDeliveryAddress:)]) {
        if (addDeliveryUrl && [[addDeliveryUrl trim] length] > 0) {
            [self.delegate didTouchAddDeliveryAddress:addDeliveryUrl];
        }
    }
}

//배송지 목록
- (void)touchDeliveryList:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(drawLayerDeliveryList:listInfo:)]) {
        [self.delegate drawLayerDeliveryList:sender listInfo:deliveryInfo];
    }
}

//배송점 목록
- (void)touchShopList:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(drawLayerShopList:listInfo:)]) {
        [self.delegate drawLayerShopList:sender listInfo:addressSettingArray];
    }
}

//배송도움말 layer 노출
- (void)touchTextIconButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSString *url = deliveryInfo[@"dlvHelp"][button.tag][@"helpLinkUrl"];
    
    if ([self.delegate respondsToSelector:@selector(didTouchTextIconButton:helpTitle:)]) {
        if (url && [[url trim] length] > 0) {
            [self.delegate didTouchTextIconButton:url helpTitle:deliveryInfo[@"dlvHelp"][button.tag][@"helpTitle"]];
        }
    }
}

//배송점 확인
- (void)setContainerAddView:(NSString *)deliveryInfoStr
{
    //배송지 정보
    [deliveryInfoLabel setText:deliveryInfoStr];
    [deliveryInfoLabel setHidden:NO];
    [shopListButton setHidden:YES];
    
    if (isExpandView) {
        isExpandView = NO;
        
        CGRect frame = containerView.frame;
        frame.size.height -= addedHeight;
        containerView.frame = frame;
        
        frame = deliveryListContentView.frame;
        frame.size.height -= addedHeight;
        deliveryListContentView.frame = frame;
        
        [containerLineView setFrame:CGRectMake(0, CGRectGetMaxY(containerLineView.frame)-addedHeight-2, kScreenBoundsWidth, 1)];
        
        if ([self.delegate respondsToSelector:@selector(didTouchExpandButton: height:)]) {
            [self.delegate didTouchExpandButton:CPProductViewTypeDelivery height:kDeliveryDefaultHeight+CGRectGetMaxY(lineView.frame)+CGRectGetHeight(containerView.frame)-addedHeight];
        }
    }
    
    if (!isExpandView) {
        isExpandView = YES;
        addedHeight = 37;
        
        [confirmButton setFrame:CGRectMake(kScreenBoundsWidth-10-42, CGRectGetMaxY(containerLineView.frame)-10, 42, 32)];
        [deliveryInfoLabel setFrame:CGRectMake(10, CGRectGetMaxY(containerLineView.frame)-10, confirmButton.frame.origin.x-10, 32)];
        
        CGRect frame = containerView.frame;
        frame.size.height += addedHeight;
        containerView.frame = frame;
        
        frame = deliveryListContentView.frame;
        frame.size.height += addedHeight;
        deliveryListContentView.frame = frame;
        
        [containerLineView setFrame:CGRectMake(0, CGRectGetMaxY(containerLineView.frame)+addedHeight, kScreenBoundsWidth, 1)];
        
        if ([self.delegate respondsToSelector:@selector(didTouchExpandButton: height:)]) {
            [self.delegate didTouchExpandButton:CPProductViewTypeDelivery height:kDeliveryDefaultHeight+CGRectGetMaxY(lineView.frame)+CGRectGetHeight(containerView.frame)];
        }
    }
}

//배송점이 두군데 이상일 때
- (void)setContainerAddListView
{
    [deliveryInfoLabel setText:@"배송받으실 지점을 선택하여 주십시오."];
    [deliveryInfoLabel setHidden:NO];
    [shopListButton setHidden:NO];
    [confirmButton setHidden:NO];
    
    if (isExpandView) {
        isExpandView = NO;
        
        CGRect frame = containerView.frame;
        frame.size.height -= addedHeight;
        containerView.frame = frame;
        
        frame = deliveryListContentView.frame;
        frame.size.height -= addedHeight;
        deliveryListContentView.frame = frame;
        
        [containerLineView setFrame:CGRectMake(0, CGRectGetMaxY(containerLineView.frame)-addedHeight-2, kScreenBoundsWidth, 1)];
        
        if ([self.delegate respondsToSelector:@selector(didTouchExpandButton: height:)]) {
            [self.delegate didTouchExpandButton:CPProductViewTypeDelivery height:kDeliveryDefaultHeight+CGRectGetMaxY(lineView.frame)+CGRectGetHeight(containerView.frame)-addedHeight];
        }
    }
    
    if (!isExpandView) {
        isExpandView = YES;
        addedHeight = 111;
        
        NSString *shopListStr = addressSettingArray && addressSettingArray.count > 0 ? addressSettingArray[self.selectedShopIndex][@"strNm"] : @"";
        [shopListButton setTitle:shopListStr forState:UIControlStateNormal];
        
        [deliveryInfoLabel setFrame:CGRectMake(10, CGRectGetMaxY(containerLineView.frame)-10, confirmButton.frame.origin.x-10, 32)];
        [shopListButton setFrame:CGRectMake(10, CGRectGetMaxY(deliveryInfoLabel.frame)+5, kScreenBoundsWidth-20, 32)];
        [confirmButton setFrame:CGRectMake(kScreenBoundsWidth-10-42, CGRectGetMaxY(shopListButton.frame)+5, 42, 32)];
        
        CGRect frame = containerView.frame;
        frame.size.height += addedHeight;
        containerView.frame = frame;
        
        frame = deliveryListContentView.frame;
        frame.size.height += addedHeight;
        deliveryListContentView.frame = frame;
        
        [containerLineView setFrame:CGRectMake(0, CGRectGetMaxY(containerLineView.frame)+addedHeight, kScreenBoundsWidth, 1)];
        
        if ([self.delegate respondsToSelector:@selector(didTouchExpandButton: height:)]) {
            [self.delegate didTouchExpandButton:CPProductViewTypeDelivery height:kDeliveryDefaultHeight+CGRectGetMaxY(lineView.frame)+CGRectGetHeight(containerView.frame)];
        }
    }
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    NSString *linkUrl = deliveryInfo[@"visitDlvLinkUrl"];
    linkUrl = [linkUrl stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:productNumber];
    
    if ([self.delegate respondsToSelector:@selector(didTouchVisitDlvLink:)]) {
        [self.delegate didTouchVisitDlvLink:linkUrl];
    }
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
