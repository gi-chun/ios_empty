//
//  CPBarButtonItem.h
//  11st
//
//  Created by spearhead on 2014. 8. 26..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BAR_BUTTON_ITEM_SPACE       [[CPBarButtonItem alloc] initWithBarButtonType:CPBarButtonItemTypeSpace withDelegate:nil]

typedef NS_ENUM(NSUInteger, CPBarButtonItemType){
    CPBarButtonItemTypeMenu = 0,             //메뉴 버튼
    CPBarButtonItemTypeBack,                 //뒤로 버튼
    CPBarButtonItemTypeLogo,                 //로고
    CPBarButtonItemTypeBasket,               //장바구니
    CPBarButtonItemTypeMyInfo,               //내정보 버튼
    CPBarButtonItemTypeSpace                 // iOS 7 대응용 FixedSpace Button
};

@protocol CPBarButtonItemDelegate <NSObject>

@optional
- (void)touchBackButton;
- (void)touchMenuButton;
- (void)touchLogoButton;
- (void)touchBasketButton;
- (void)touchMyInfoButton;
- (void)touchDoneButton;
- (void)touchSettingButton;
@end

@interface CPBarButtonItem : UIBarButtonItem

- (id) initWithBarButtonType:(CPBarButtonItemType)aBarButtonType withDelegate:(id<CPBarButtonItemDelegate>)aDelegate;

@end