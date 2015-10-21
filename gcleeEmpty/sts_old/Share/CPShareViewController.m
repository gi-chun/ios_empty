//
//  CPShareViewController.m
//  11st
//
//  Created by spearhead on 2014. 9. 11..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPShareViewController.h"
#import "CPNavigationBarView.h"
#import "KakaoLinkCenter.h"
#import <Social/Social.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>

@interface CPShareViewController() <UITableViewDelegate,
                                    UITableViewDataSource,
                                    UITextFieldDelegate>
{
    UITableView *shareTableView;
    
    NSArray *shareListArray;
}

@end

@implementation CPShareViewController

- (id)init
{
    if ((self = [super init])) {
        shareListArray = [NSArray arrayWithObjects:
                          [NSDictionary dictionaryWithObjectsAndKeys:@"icon_twitter.png", @"image", @"트위터", @"text", @"Twitter", @"type", nil],
                          [NSDictionary dictionaryWithObjectsAndKeys:@"icon_facebook.png", @"image", @"페이스북", @"text", @"Facebook", @"type", nil],
                          [NSDictionary dictionaryWithObjectsAndKeys:@"icon_kakaotalk.png", @"image", @"카카오톡", @"text", @"KakaoTalk", @"type", nil],
                          [NSDictionary dictionaryWithObjectsAndKeys:@"icon_kakaostory.png", @"image", @"카카오스토리", @"text", @"KakaoStory", @"type", nil],
                          nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self initNavigationBar];
    
    [self.view setBackgroundColor:UIColorFromRGB(TABLE_BG_COLOR)];
    
    shareTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsHeight-64) style:UITableViewStyleGrouped];
    [shareTableView setDelegate:self];
    [shareTableView setDataSource:self];
    
    if ([SYSTEM_VERSION intValue] >= 7) {
        [shareTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    }
    else {
        [shareTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    
    [shareTableView setBackgroundColor:[UIColor clearColor]];
    [shareTableView setBackgroundView:nil];
    [shareTableView setRowHeight:45];
    [self.view addSubview:shareTableView];
}

- (void)initNavigationBar
{
    // iOS7 Layout
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    [self setTitle:NSLocalizedString(@"SharePage", nil)];
    
    for (UIView *subView in self.navigationController.navigationBar.subviews) {
        if ([subView isKindOfClass:[CPNavigationBarView class]]) {
            [subView removeFromSuperview];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 
    [self initNavigationBar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - User Functions

- (void)clearTitleText:(id)sender
{
    UIButton *button = (UIButton *)sender;
    UITextField *textField = (UITextField *)[Modules findViewByClass:[UITextField class] view:button.superview];
    
    [textField setText:nil];
    [textField becomeFirstResponder];
    [button setHidden:YES];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 1 : [shareListArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.rowHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section == 0 ? @"공유 제목" : @"공유할 서비스 선택";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ShareControllerCell";
    
    CGFloat leftOffset = 10.0f;
    CGFloat rightMargin = [SYSTEM_VERSION intValue] >= 7 ? 17.0f : 0.0f;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    for (UIView *view in cell.contentView.subviews) [view removeFromSuperview];
    
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.textLabel setTextColor:UIColorFromRGB(0x444444)];
    [cell.textLabel setFont:[UIFont systemFontOfSize:16.0f]];
    [cell setAccessoryView:nil];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        UIImage *clearBtnImg = [UIImage imageNamed:@"btn_cell_txt_delete.png"];
        
        CGFloat clearBtnOffsetX = 0.0f;
        clearBtnOffsetX = CGRectGetWidth(tableView.frame)-clearBtnImg.size.width-rightMargin;
        
        if ([SYSTEM_VERSION intValue] <= 6) {
            if (IS_IPAD)	clearBtnOffsetX = clearBtnOffsetX - 100.f;
            else			clearBtnOffsetX = clearBtnOffsetX - 30.f;
        }
        
        UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [clearBtn setBackgroundImage:clearBtnImg forState:UIControlStateNormal];
        [clearBtn addTarget:self action:@selector(clearTitleText:) forControlEvents:UIControlEventTouchUpInside];
        [clearBtn setFrame:CGRectMake(clearBtnOffsetX,
                                      (tableView.rowHeight - clearBtnImg.size.height) / 2,
                                      clearBtnImg.size.width,
                                      clearBtnImg.size.height)];
        [clearBtn setAccessibilityLabel:@"삭제" Hint:@"삭제합니다"];
        [cell.contentView addSubview:clearBtn];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
        [textField setTag:100];
        [textField setDelegate:self];
        [textField setText:self.shareTitle];
        [textField setReturnKeyType:UIReturnKeyDone];
        [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [textField setFrame:CGRectMake(leftOffset, 0, clearBtn.frame.origin.x - leftOffset, tableView.rowHeight)];
        [cell.contentView addSubview:textField];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    if (indexPath.section == 1) {
        NSDictionary *itemDic = [shareListArray objectAtIndex:indexPath.row];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[itemDic objectForKey:@"image"]]];
        UILabel *textLabel = [[UILabel alloc] initWithFrame:cell.frame];
        
        [imageView setFrame:CGRectMake(leftOffset, 2.5f, 40, 40)];
        
        [textLabel setText:[itemDic objectForKey:@"text"]];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setFrame:CGRectMake(CGRectGetMaxX(imageView.frame)+10, 0, textLabel.frame.size.width - imageView.frame.origin.x + imageView.frame.size.width + 10, textLabel.frame.size.height)];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setAccessoryView:nil];
        
        [cell.contentView addSubview:imageView];
        [cell.contentView addSubview:textLabel];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    
    if (indexPath.section == 0) {
        return;
    }
    
    NSMutableDictionary *item = [shareListArray objectAtIndex:indexPath.row];
    
    if ([[item objectForKey:@"type"] isEqualToString:@"Twitter"]) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            
//            tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
//                switch(result) {
//                    case SLComposeViewControllerResultCancelled:
//                        break;
//                    case SLComposeViewControllerResultDone:
//                        [Modules alert:@"페이지 공유" message:@"트위터 공유를 완료했습니다."];
//                        break;
//                }
//            };
            
            [tweetSheet setInitialText:self.shareTitle];
            [tweetSheet addURL:[NSURL URLWithString:self.shareUrl]];
            
            [self presentViewController:tweetSheet animated:YES completion:nil];
        }
        else {
            [Modules alert:@"페이지 공유" message:@"설정에서 트위터 로그인 후 이용해주세요."];
        }
    }
    else if ([[item objectForKey:@"type"] isEqualToString:@"Facebook"]) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            SLComposeViewController *facebookSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
//            facebookSheet.completionHandler = ^(SLComposeViewControllerResult result) {
//                switch(result) {
//                    case SLComposeViewControllerResultCancelled:
//                        break;
//                    case SLComposeViewControllerResultDone:
//                        [Modules alert:@"페이지 공유" message:@"페이스북 공유를 완료했습니다."];
//                        break;
//                }
//            };
            
            [facebookSheet setInitialText:self.shareTitle];
            [facebookSheet addURL:[NSURL URLWithString:self.shareUrl]];
            
            [self presentViewController:facebookSheet animated:YES completion:nil];
        }
        else {
            [Modules alert:@"페이지 공유" message:@"설정에서 페이스북 로그인 후 이용해주세요."];
        }
    }
    else if ([[item objectForKey:@"type"] isEqualToString:@"KakaoTalk"]) {
        if (![KOAppCall canOpenKakaoTalkAppLink]) {
            [Modules alert:@"페이지 공유" message:@"카카오톡을 설치하고 이용해주세요."];
            
            return;
        }
        
        NSString *labelString = [NSString stringWithFormat:@"[11번가]\n\n%@\n%@", self.shareTitle, self.shareUrl];

        KakaoTalkLinkObject *label = [KakaoTalkLinkObject createLabel:labelString];
        
        
        KakaoTalkLinkAction *androidAppAction = [KakaoTalkLinkAction createAppAction:KakaoTalkLinkActionOSPlatformAndroid
                                                                          devicetype:KakaoTalkLinkActionDeviceTypePhone
                                                                           execparam:@{@"executeurl":self.shareUrl}];
        KakaoTalkLinkAction *iphoneAppAction = [KakaoTalkLinkAction createAppAction:KakaoTalkLinkActionOSPlatformIOS
                                                                         devicetype:KakaoTalkLinkActionDeviceTypePhone
                                                                          execparam:@{@"executeurl":self.shareAppScheme}];
        KakaoTalkLinkObject *buttonObj = [KakaoTalkLinkObject createAppButton:@"앱으로 연결"
                                                                      actions:@[androidAppAction, iphoneAppAction]];
        
        
        NSMutableDictionary *kakaoTalkLinkObjects = [@{@"label":label, @"button":buttonObj} mutableCopy];
        
        [KOAppCall openKakaoTalkAppLink:[kakaoTalkLinkObjects allValues]];
    }
    else if ([[item objectForKey:@"type"] isEqualToString:@"KakaoStory"]) {
        if (![KakaoLinkCenter canOpenStoryLink]) {
            [Modules alert:@"페이지 공유" message:@"카카오스토리를 설치하고 이용해주세요."];
            
            return;
        }
        
        [KakaoLinkCenter openStoryLinkWithPost:[NSString stringWithFormat:@"[11번가]%@ %@", self.shareTitle, self.shareUrl]
                                   appBundleID:[[NSBundle mainBundle] bundleIdentifier]
                                    appVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
                                       appName:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"] urlInfo:nil];
    }
}

#pragma mark - UITextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *textFieldString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    UIButton *deleteButton = (UIButton *)[Modules findViewByClass:[UIButton class] view:textField.superview];
    
    [deleteButton setHidden:YES];
    
    if (textFieldString && [[textFieldString trim] length] > 0) {
        [deleteButton setHidden:NO];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textfield
{
    [textfield resignFirstResponder];
    
    return NO;
}

@end
