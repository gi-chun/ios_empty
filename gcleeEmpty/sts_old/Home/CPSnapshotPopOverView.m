//
//  CPSnapshotPopOverView.m
//  11st
//
//  Created by spearhead on 2014. 11. 20..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPSnapshotPopOverView.h"

#define kContainerTag   100

@interface CPSnapshotPopOverView()
{
    NSArray *menuItems;
}

@end

@implementation CPSnapshotPopOverView

- (id)initWithFrame:(CGRect)frame toolbarType:(CPToolbarType)toolbarType
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:UIColorFromRGBA(0x000000, 0.4f)];
        
        CGFloat buttonWidth = (CGRectGetWidth(frame) - 10) / 5;
        CGFloat containerWidth = buttonWidth * 2 + 10;
        CGFloat buttonHeight = 79;
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)/2-containerWidth/2, CGRectGetHeight(frame)-90, containerWidth, 90)];
        [containerView setBackgroundColor:[UIColor clearColor]];
        [containerView setUserInteractionEnabled:YES];
        [containerView setTag:kContainerTag];
        [self addSubview:containerView];
        
        UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 4, 79)];
        [leftImageView setImage:[UIImage imageNamed:@"popover_bg_left.png"]];
        [containerView addSubview:leftImageView];
        
        UIImageView *centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftImageView.frame), 0, CGRectGetWidth(containerView.frame)-8, 79)];
        [centerImageView setImage:[UIImage imageNamed:@"popover_bg_center.png"]];
        [containerView addSubview:centerImageView];
        
        UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(containerView.frame)-4, 0, 4, 79)];
        [rightImageView setImage:[UIImage imageNamed:@"popover_bg_right.png"]];
        [containerView addSubview:rightImageView];
        
        NSString *plistPath = @"snapshotPopOverMenu";
        NSString *path = [[NSBundle mainBundle] pathForResource:plistPath ofType:@"plist"];
        
        menuItems = [NSArray arrayWithContentsOfFile:path];
        
        for (NSInteger i = 0; i < menuItems.count; i++) {
            NSDictionary *menu = menuItems[i];
            
            CGRect kMenuButtonFrame = CGRectMake(5, 0, buttonWidth, buttonHeight);
            CGRect menuButtonFrame = CGRectMake(kMenuButtonFrame.origin.x + (buttonWidth * i),
                                                kMenuButtonFrame.origin.y,
                                                kMenuButtonFrame.size.width,
                                                kMenuButtonFrame.size.height);
            
            UIImage *iconImageNormal = [UIImage imageNamed:menu[@"imageNormal"]];
            NSString *title = menu[@"name"];
            
            UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [menuButton setFrame:menuButtonFrame];
            [menuButton setTitle:title forState:UIControlStateNormal];
            [menuButton setTitleColor:UIColorFromRGB(0x414144) forState:UIControlStateNormal];
            [menuButton setTitleColor:UIColorFromRGBA(0x414144, 0.5f) forState:UIControlStateDisabled];
            [menuButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [menuButton setImage:iconImageNormal forState:UIControlStateNormal];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"popover_bg_press.png"] forState:UIControlStateHighlighted];
            [menuButton addTarget:self action:@selector(touchMenu:) forControlEvents:UIControlEventTouchUpInside];
            [menuButton setTag:i];
            [menuButton setAccessibilityLabel:menu[@"name"] Hint:@""];
            [containerView addSubview:menuButton];
            
            CGSize imageSize = iconImageNormal.size;
            CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:12]];
            CGFloat totalHeight = (imageSize.height + titleSize.height + 6);
            [menuButton setImageEdgeInsets:UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0, 0, - titleSize.width)];
            [menuButton setTitleEdgeInsets:UIEdgeInsetsMake(0, - imageSize.width, - (totalHeight - titleSize.height),0)];
            
            if (CPToolbarTypeApp == toolbarType && [menu[@"key"] isEqualToString:@"bookmark"]) {
                [menuButton setImage:[UIImage imageNamed:menu[@"imageDisabled"]] forState:UIControlStateDisabled];
                [menuButton setEnabled:NO];
            }
        }
        
        CGFloat toolbarButtonWidth = kScreenBoundsWidth / 7;
        CGFloat arrowX = toolbarButtonWidth * 3;
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(arrowX+(toolbarButtonWidth/2)-6, CGRectGetHeight(frame)-11, 12, 6)];
        [arrowImageView setImage:[UIImage imageNamed:@"popover_arrow.png"]];
        [self addSubview:arrowImageView];
    }
    return self;
}

#pragma mark - Selectors

- (void)touchMenu:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSDictionary *buttonInfo = menuItems[button.tag];
    
    if ([self.delegate respondsToSelector:@selector(didTouchSnapshotPopOverButton:buttonInfo:)]) {
        [self.delegate didTouchSnapshotPopOverButton:button buttonInfo:buttonInfo];
    }
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    NSLog(@"touchesBegan outside");
    CGPoint touch = [[touches anyObject] locationInView:self];
    UIView *containerView = [self viewWithTag:kContainerTag];
    
    if (CGRectContainsPoint(containerView.frame, touch)) {
        [self setHidden:NO];
    }
    else {
        [self setHidden:YES];
    }
}

@end
