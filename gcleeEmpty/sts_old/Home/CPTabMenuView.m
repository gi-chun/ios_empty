//
//  CPTabMenuView.m
//  11st
//
//  Created by spearhead on 2014. 8. 28..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPTabMenuView.h"

@interface CPTabMenuView()
{
    NSArray *menuTitles;
    NSArray *menuContents;
    NSInteger currentItemIndex;
}

@end

@implementation CPTabMenuView

- (id)initWithFrame:(CGRect)frame menuTitleItems:(NSArray *)menuTitleItems menuContentsItems:(NSArray *)menuContentsItems
{
    self = [super initWithFrame:frame];
    if (self) {
        
        menuTitles = menuTitleItems;
        menuContents = menuContentsItems;
        
        [self setBackgroundColor:UIColorFromRGB(0xffffff)];
        
        for (NSInteger i = 0; i < menuTitles.count; i++) {
            NSDictionary *menu = menuTitles[i];
            
            CGFloat buttonWidth = kScreenBoundsWidth / menuTitles.count;
            CGFloat buttonHeight = kTabMenuHeight;
            
            CGRect kMenuButtonFrame = CGRectMake(0, 0, buttonWidth, buttonHeight);
            CGRect menuButtonFrame = CGRectMake(kMenuButtonFrame.origin.x + (buttonWidth * i),
                                                kMenuButtonFrame.origin.y,
                                                kMenuButtonFrame.size.width,
                                                kMenuButtonFrame.size.height);
            
            UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [menuButton setFrame:menuButtonFrame];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"gnb_tab_nor.png"] forState:UIControlStateNormal];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"gnb_tab_press.png"] forState:UIControlStateHighlighted];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"gnb_tab_press.png"] forState:UIControlStateSelected];
            [menuButton setTitle:menu[@"title"] forState:UIControlStateNormal];
            [menuButton setTag:i];
            [menuButton addTarget:self action:@selector(touchTabMenu:) forControlEvents:UIControlEventTouchUpInside];
            [menuButton setAccessibilityLabel:menu[@"title"] Hint:@""];
            [self setButtonProperties:menuButton];
            [self addSubview:menuButton];
            
            //new
            if (menu[@"isNew"]) {
                UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(menuButton.frame), 15)];
                [newLabel setFont:[UIFont systemFontOfSize:10]];
                [newLabel setText:@"new"];
                [newLabel setTextColor:UIColorFromRGB(0x52bbff)];
                [newLabel setTextAlignment:NSTextAlignmentCenter];
                [menuButton addSubview:newLabel];
            }
            
            CGRect kBarImageViewFrame = CGRectMake(0, CGRectGetHeight(frame)-3.1f, buttonWidth, 3);
            CGRect barImageViewFrame = CGRectMake(kBarImageViewFrame.origin.x + (buttonWidth * i),
                                                kBarImageViewFrame.origin.y,
                                                kBarImageViewFrame.size.width,
                                                kBarImageViewFrame.size.height);
            
            UIImageView *barIamgeView = [[UIImageView alloc] initWithFrame:barImageViewFrame];
            [barIamgeView setBackgroundColor:UIColorFromRGB(0xf62e3d)];
            [barIamgeView setHidden:YES];
            [barIamgeView setTag:i];
            [self addSubview:barIamgeView];
            
            if (i == 0) {
                [self setHighlightedButtonProperties:menuButton];
                [barIamgeView setHidden:NO];
            }
        }
        
//        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame)-1, CGRectGetWidth(frame), 1)];
//        [lineView setBackgroundColor:UIColorFromRGB(0x000000)];
//        [self addSubview:lineView];

    }
    return self;
}

#pragma mark - Public Methods

- (void)tabMenuCurrentItemIndexDidChange:(NSInteger)index
{
    currentItemIndex = index;
    
    if (!(menuTitles && menuTitles.count > 0)) {
        return;
    }
    
    if (!(menuContents && menuContents.count > 0)) {
        return;
    }
    
    for (UIView *subView in [self subviews]) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subView;

            NSDictionary *title = menuTitles[button.tag];
            NSDictionary *content = menuContents[index];
            
            if ([title[@"key"] isEqualToString:content[@"key"]] || [title[@"key"] isEqualToString:content[@"parent"]]) {
                [self setHighlightedButtonProperties:button];
            }
            else {
                [self setButtonProperties:button];
            }
        }
        
        if ([subView isKindOfClass:[UIImageView class]]) {
            UIImageView *barImageView = (UIImageView *)subView;
            
            NSDictionary *title = menuTitles[barImageView.tag];
            NSDictionary *content = menuContents[index];
            
            if ([title[@"key"] isEqualToString:content[@"key"]] || [title[@"key"] isEqualToString:content[@"parent"]]) {
                [barImageView setHidden:NO];
            }
            else {
                [barImageView setHidden:YES];
            }
        }
    }
}

#pragma mark - Button & Label Properties

- (void)setButtonProperties:(UIButton *)button
{
    [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    [button setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateHighlighted];
    [button setBackgroundColor:UIColorFromRGB(0xffffff)];
}

- (void)setHighlightedButtonProperties:(UIButton *)button
{
    [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    [button setTitleColor:UIColorFromRGB(0xf62e3d) forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateHighlighted];
    [button setBackgroundColor:UIColorFromRGB(0xffffff)];
}

#pragma mark - Selectors

- (void)touchTabMenu:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSInteger tabIndex = [self findTabMenu:button.tag];
    
    NSDictionary *menuContentInfo = menuContents[tabIndex];
    NSDictionary *currnetContentInfo = menuContents[currentItemIndex];
    
    if (menuTitles[button.tag][@"child"]) {
        
        NSDictionary *lastChild = [menuTitles[button.tag][@"child"] lastObject];
        NSInteger lastIndex = [self findTabMenuWithKey:lastChild[@"key"]];
        
//        NSLog(@"tabIndex: %i, currentItemIndex: %i, lastIndex: %i", tabIndex, currentItemIndex, lastIndex);
        if ([menuContentInfo[@"parent"] isEqualToString:currnetContentInfo[@"parent"]]) {
            if ([self.delegate respondsToSelector:@selector(didTouchTabMenuButton:)]) {
                
                if (currentItemIndex == lastIndex) {
                    [self.delegate didTouchTabMenuButton:tabIndex];
                }
                else {
                    [self.delegate didTouchTabMenuButton:currentItemIndex+1];
                }
            }
        }
        else {
            if ([self.delegate respondsToSelector:@selector(didTouchTabMenuButton:)]) {
                [self.delegate didTouchTabMenuButton:tabIndex];
            }
        }
    }
    else {
        if ([self.delegate respondsToSelector:@selector(didTouchTabMenuButton:)]) {
            [self.delegate didTouchTabMenuButton:tabIndex];
        }
    }
}

- (NSInteger)findTabMenu:(NSInteger)index
{
    NSInteger tabIndex = 0;
    NSString *menuTitleKey = menuTitles[index][@"key"];
    
    for (int i = 0; i < menuContents.count; i++) {
        NSDictionary *menuContentInfo = menuContents[i];
        if ([menuTitleKey isEqualToString:menuContentInfo[@"key"]] || [menuTitleKey isEqualToString:menuContentInfo[@"parent"]]) {
    
            tabIndex =  i;
            return tabIndex;
        }
    }
    
    return tabIndex;
}

- (NSInteger)findTabMenuWithKey:(NSString *)key
{
    NSInteger tabIndex = 0;
    
    
    for (int i = 0; i < menuContents.count; i++) {
        NSDictionary *menuContentInfo = menuContents[i];
        if ([key isEqualToString:menuContentInfo[@"key"]]) {
            
            tabIndex =  i;
            return tabIndex;
        }
    }
    
    return tabIndex;
}

@end
