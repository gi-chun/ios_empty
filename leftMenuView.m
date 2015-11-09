//
//  leftMenuView.m
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 5..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import "leftMenuView.h"
#import "leftMenuItemView.h"

const static CGFloat HEADER_HEIGHT =      40;
const static CGFloat LOGO_HEIGHT   =      40;
const static CGFloat LOGIN_HEIGHT  =      120;
const static CGFloat MENU_HEIGHT   =      40;
const static CGFloat AD_HEIGHT     =      40;

@interface leftMenuView ()
{
    //CPLoadingView *_loadingView;
    //CPErrorView *_errorView;
    //UIButton *_topScrollButton;
    
    //NSDictionary *_item;
    //NSMutableDictionary *_AreaItem;
    
    UIView *logoView;
    UIView *loginView;
    UIView *loginResultView;
    UIView *aDView;
}
@end

@implementation leftMenuView

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setBackgroundColor:UIColorFromRGB(0xe3e3e8)];
        
        [self showContents];
        
        //LoadingView
//        _loadingView = [[CPLoadingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2-40,
//                                                                       CGRectGetHeight(self.frame)/2-40,
//                                                                       80,
//                                                                       80)];
//        [self addSubview:_loadingView];
//        [self stopLoadingAnimation];
    }
    return self;
}

- (void)setInfo:(NSDictionary *)info
{
//    if (info) {
//        _item = [info copy];
//        
//        //1.5초후 통신하도록 한다.
//        [self performSelector:@selector(reloadData) withObject:nil afterDelay:2.5];
//    }
//    else {
//        [self showErrorView];
//    }
}

- (void)reloadData
{
    //[self performSelectorInBackground:@selector(requestItems:) withObject:@NO];
}

- (void)reloadDataWithIgnoreCache:(NSNumber *)delay
{
    //[self performSelector:@selector(requestItems:) withObject:@YES afterDelay:[delay floatValue]];
}

- (void)goToTopScroll
{
    //[_collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma showContents
- (void)showContents
{
    [self removeErrorView];
    [self removeContents];
    
    /*
    UIView *logoView;
    UIView *loginView;
    UIView *loginResultView;
    UIView *aDView;
     */
    //logoView
    logoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, LOGO_HEIGHT)];
    
//    UIButton* closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [closeButton setFrame:CGRectMake(kScreenBoundsWidth-50+10, 10, 50, 50)];
//    [closeButton setBackgroundColor:[UIColor clearColor]];
//    [closeButton setBackgroundImage:[UIImage imageNamed:@"btn_top.png"] forState:UIControlStateHighlighted];
//    [closeButton setImage:[UIImage imageNamed:@"btn_top.png"] forState:UIControlStateNormal];
//    [closeButton addTarget:self action:@selector(onCloseButton) forControlEvents:UIControlEventTouchUpInside];
//    [logoView addSubview:closeButton];
    /*
     UIButton *bannerButton = [UIButton buttonWithType:UIButtonTypeCustom];
     [bannerButton setFrame:CGRectMake(0, 0, kScreenBoundsWidth, 60)];
     [bannerButton setBackgroundColor:[UIColor clearColor]];
     [bannerButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x000000)] forState:UIControlStateHighlighted];
     [bannerButton setAlpha:0.3];
     [bannerButton addTarget:self action:@selector(touchBanner) forControlEvents:UIControlEventTouchUpInside];
     [self addSubview:bannerButton];
     
     lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 1)];
     [lineView setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
     [self addSubview:lineView];
     */
    CGFloat meWidth = self.frame.size.width;
    CGFloat meHeight = self.frame.size.height;
    
    //logo
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, meWidth, LOGO_HEIGHT)];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [logoImageView setImage:[UIImage imageNamed:@"icon_navi_home.png"]];
    [logoView addSubview:logoImageView];
    [self addSubview:logoView];
    
    //login view
    loginView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(logoView.frame)+10, meWidth, LOGIN_HEIGHT)];
    UILabel* loginDesc = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(loginView.frame)+10, CGRectGetMinY(loginView.frame)+10, kScreenBoundsWidth-20, LOGIN_HEIGHT/3)];
    [loginDesc setText:@"로그인을 하시면 Sunny Club의 다양한 서비스를 이용하실 수 있습니다."];
    [loginView addSubview:loginDesc];
    
    UIButton* loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton setFrame:CGRectMake(10, CGRectGetMaxY(loginDesc.frame), meWidth-20, 50)];
    [loginButton setBackgroundColor:[UIColor clearColor]];
    [loginButton setBackgroundImage:[UIImage imageNamed:@"btn_login_save.png"] forState:UIControlStateHighlighted];
    [loginButton setImage:[UIImage imageNamed:@"bg_notice_bar.png"] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(onLoginButton) forControlEvents:UIControlEventTouchUpInside];
    [loginView addSubview:loginButton];
    [self addSubview:loginView];
    
    leftMenuItemView *menuItemView1 = [[leftMenuItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(loginView.frame)+10, meWidth, MENU_HEIGHT) title:@"SUNNY CLUB"];
    [self addSubview:menuItemView1];
    
    leftMenuItemView *menuItemView2 = [[leftMenuItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(menuItemView1.frame)+10, meWidth, MENU_HEIGHT) title:@"SUNNY BANK"];
    [self addSubview:menuItemView2];
    
    leftMenuItemView *menuItemView3 = [[leftMenuItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(menuItemView2.frame)+10, meWidth, MENU_HEIGHT) title:@"SUNNY EVENT"];
    [self addSubview:menuItemView3];
    
    leftMenuItemView *menuItemView4 = [[leftMenuItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(menuItemView3.frame)+10, meWidth, MENU_HEIGHT) title:@"SETTING"];
    [self addSubview:menuItemView4];
    
    //ADView
    UIImageView *adImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, meHeight-AD_HEIGHT, meWidth, AD_HEIGHT)];
    adImageView.contentMode = UIViewContentModeScaleAspectFit;
    [adImageView setImage:[UIImage imageNamed:@"icon_navi_home.png"]];
    [logoView addSubview:adImageView];
    [self addSubview:logoView];


//    self.PanelDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLeftRightMargins, runningYOffset, frame.size.width - 2*kLeftRightMargins, panelDescriptionHeight)];
//    self.PanelDescriptionLabel.numberOfLines = 0;
//    self.PanelDescriptionLabel.text = self.PanelDescription;
//    self.PanelDescriptionLabel.font = kDescriptionFont;
//    self.PanelDescriptionLabel.textColor = kDescriptionTextColor;
//    self.PanelDescriptionLabel.alpha = 0;
//    self.PanelDescriptionLabel.backgroundColor = [UIColor clearColor];
//    [self addSubview:self.PanelDescriptionLabel];
    
    
    //topScrollButton
//    CGFloat buttonWidth = kScreenBoundsWidth / 7;
//    CGFloat buttonHeight = kToolBarHeight;
    
//    _topScrollButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_topScrollButton setFrame:CGRectMake(kScreenBoundsWidth-buttonWidth, CGRectGetHeight(self.frame)-buttonHeight, buttonWidth, buttonHeight)];
//    [_topScrollButton setImage:[UIImage imageNamed:@"btn_top.png"] forState:UIControlStateNormal];
//    [_topScrollButton addTarget:self action:@selector(onTouchTopScroll) forControlEvents:UIControlEventTouchUpInside];
//    [_topScrollButton setAccessibilityLabel:@"위로" Hint:@"화면을 위로 이동합니다"];
//    [_topScrollButton setHidden:YES];
//    [self addSubview:_topScrollButton];
    
    
    //[logoView addSubview:_headerMenuView];
}

- (void)removeContents
{
//    if (_collectionView) {
//        for (UIView *subview in [_collectionView subviews]) {
//            [subview removeFromSuperview];
//        }
//        
//        [_collectionView removeFromSuperview];
//        _collectionView.dataSource = nil;
//        _collectionView.delegate = nil;
//    }
    
//    if (_topScrollButton) {
//        if (!_topScrollButton.hidden)	[_topScrollButton removeFromSuperview];
//        _topScrollButton = nil;
//    }
}

#pragma mark - click
- (void)onCloseButton
{
    
}

- (void)onLoginButton
{
    
}

#pragma mark - UICollectionViewDataSource

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //[_topScrollButton setHidden:0 < scrollView.contentOffset.y ? NO : YES];
}

//메뉴 클릭
- (void)onTouchMenuClicked:(id)sender
{
    //    NSInteger tag = [sender tag];
    //
    //    NSArray *tapItems = _topBrandAreaItem[@"topBrandArea"];
    //    NSString *linkUrl = tapItems[tag][@"linkUrl"];
    //
    //    if (linkUrl && [[linkUrl trim] length] > 0) {
    //        if ([self.delegate respondsToSelector:@selector(didTouchButtonWithUrl:)]) {
    //            [self.delegate didTouchButtonWithUrl:linkUrl];
    //        }
    //    }
    //
    //    if (tag == 0)       [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAP0101"];
    //    else if (tag == 1)  [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAP0102"];
    //    else if (tag == 2)  [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAP0103"];
    //    else if (tag == 3)  [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAP0104"];
}

#pragma mark - Error View
- (void)showErrorView
{
    //    [self removeErrorView];
    //    [self removeContents];
    //
    //    _errorView = [[CPErrorView alloc] initWithFrame:self.frame];
    //    [_errorView setDelegate:self];
    //    [self addSubview:_errorView];
}

- (void)removeErrorView
{
    //    if (_errorView) {
    //        [_errorView removeFromSuperview];
    //        _errorView.delegate = nil;
    //        _errorView = nil;
    //    }
}

- (void)didTouchRetryButton
{
    //    if (_item) {
    //        [self removeErrorView];
    //        [self performSelectorInBackground:@selector(requestItems:) withObject:@YES];
    //    }
    //    else {
    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitle", nil)
    //                                                            message:NSLocalizedString(@"NetworkTemporaryErrMsg", nil)
    //                                                           delegate:nil
    //                                                  cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
    //                                                  otherButtonTitles:nil, nil];
    //
    //        [alertView show];
    //    }
}

#pragma mark - top button
- (void)onTouchTopScroll
{
    [self onTouchTopScroll:YES];
}

- (void)onTouchTopScroll:(BOOL)animation
{
    //[_collectionView setContentOffset:CGPointZero animated:animation];
}

#pragma mark - CPLoadingView
- (void)startLoadingAnimation
{
    //    if (_loadingView.hidden == YES) {
    //        [_loadingView setHidden:NO];
    //        [_loadingView startAnimation];
    //
    //        [self bringSubviewToFront:_loadingView];
    //    }
}

- (void)stopLoadingAnimation
{
    //    if (_loadingView.hidden == NO) {
    //        [_loadingView stopAnimation];
    //        [_loadingView setHidden:YES];
    //    }
}

@end

