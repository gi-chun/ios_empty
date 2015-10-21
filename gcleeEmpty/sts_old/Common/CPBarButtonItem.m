//
//  CPBarButtonItem.m
//  11st
//
//  Created by spearhead on 2014. 8. 26..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPBarButtonItem.h"

@implementation CPBarButtonItem

- (id) initWithBarButtonType:(CPBarButtonItemType)aBarButtonType withDelegate:(id<CPBarButtonItemDelegate>)aDelegate
{
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    switch (aBarButtonType) {
        case CPBarButtonItemTypeBack: {
            [menuButton setFrame:CGRectMake(0, 7.5f, 48, 29)];
            [menuButton setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
            [menuButton setTitleColor:UIColorFromRGB(0xd8d8d8) forState:UIControlStateNormal];
            [menuButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 2, 0)];
            [menuButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"btn_top_left_arr.png"] forState:UIControlStateNormal];
            [menuButton addTarget:aDelegate action:@selector(touchBackButton) forControlEvents:UIControlEventTouchUpInside];
            self = [super initWithCustomView:menuButton];
            self.style = UIBarButtonItemStylePlain;
            break;
        }
        case CPBarButtonItemTypeLogo: {
            [menuButton setFrame:CGRectMake(0, 4, 53, 36)];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"btn_logo_nor.png"] forState:UIControlStateNormal];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"btn_logo_press.png"] forState:UIControlStateHighlighted];
            [menuButton addTarget:aDelegate action:@selector(touchLogoButton) forControlEvents:UIControlEventTouchUpInside];
            self = [super initWithCustomView:menuButton];
            self.style = UIBarButtonItemStylePlain;
            break;
        }
        case CPBarButtonItemTypeBasket: {
            [menuButton setFrame:CGRectMake(0, 4, 40, 36)];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"ic_basket_nor.png"] forState:UIControlStateNormal];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"ic_basket_press.png"] forState:UIControlStateHighlighted];
            [menuButton addTarget:aDelegate action:@selector(touchBasketButton) forControlEvents:UIControlEventTouchUpInside];
            self = [super initWithCustomView:menuButton];
            self.style = UIBarButtonItemStylePlain;
            break;
        }
        case CPBarButtonItemTypeMyInfo: {
            [menuButton setFrame:CGRectMake(0, 4, 40, 36)];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"ic_my11_nor.png"] forState:UIControlStateNormal];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"ic_my11_press.png"] forState:UIControlStateHighlighted];
            [menuButton addTarget:aDelegate action:@selector(touchMyInfoButton) forControlEvents:UIControlEventTouchUpInside];
            self = [super initWithCustomView:menuButton];
            self.style = UIBarButtonItemStylePlain;
            break;
        }
		case CPBarButtonItemTypeSpace: {
            self = [super initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            //iOS7
            if ([SYSTEM_VERSION intValue] >= 7) {
                self.width = -8.0f;
            }
		}
        case CPBarButtonItemTypeMenu:
        default: {
            [menuButton setFrame:CGRectMake(0, 4, 40, 36)];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"btn_side_nor.png"] forState:UIControlStateNormal];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"btn_side_press.png"] forState:UIControlStateHighlighted];
            [menuButton addTarget:aDelegate action:@selector(touchMenuButton) forControlEvents:UIControlEventTouchUpInside];
            self = [super initWithCustomView:menuButton];
            self.style = UIBarButtonItemStylePlain;
            break;
        }
    }
    
    return self;
}

@end
