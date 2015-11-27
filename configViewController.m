//
//  configViewController.m
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 18..
//  Copyright © 2015년 gclee. All rights reserved.
//


#import "configViewController.h"
#import "personModifyViewController.h"
#import "myPickerViewController.h"
#import "LoginViewController.h"

@interface configViewController () <NavigationBarViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *needLabel;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIView *realMainView;
@property (weak, nonatomic) IBOutlet UIScrollView *realScrollView;
@property (weak, nonatomic) IBOutlet UILabel *langLabel;
@property (weak, nonatomic) IBOutlet UILabel *L_HELP_KO;
@property (weak, nonatomic) IBOutlet UILabel *L_TUTO_KO;
@property (weak, nonatomic) IBOutlet UILabel *L_NEW;
@property (weak, nonatomic) IBOutlet UILabel *L_ALRAM_SET_KO;
@property (weak, nonatomic) IBOutlet UILabel *LALRAM_ALLOW_KO;
@property (weak, nonatomic) IBOutlet UILabel *LALRAM_DES_KO;
@property (weak, nonatomic) IBOutlet UILabel *LPROGRAM_INFO_KO;
@property (weak, nonatomic) IBOutlet UILabel *LLANG_INFO_KO;
@property (weak, nonatomic) IBOutlet UILabel *LAPP_INFO_KO;
@property (weak, nonatomic) IBOutlet UILabel *LCURR_VER_KO;
@property (weak, nonatomic) IBOutlet UILabel *curVerLabel;
@property (weak, nonatomic) IBOutlet UILabel *LNEW_VER_KO;
@property (weak, nonatomic) IBOutlet UILabel *lastVerLabel;
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;
@property (weak, nonatomic) IBOutlet UISwitch *tutoBtn;
@property (weak, nonatomic) IBOutlet UISwitch *pushBtn;
@property (weak, nonatomic) IBOutlet UILabel *sunnyDescLabel;

@end

@implementation configViewController
- (IBAction)personalChange:(id)sender {
    
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:kLoginY];
    if(isLogin == YES){
        personModifyViewController *personController = [[personModifyViewController alloc] init];
        [personController setDelegate:self];
        [self.navigationController pushViewController:personController animated:YES];
    }else{
        LoginViewController *loginController = [[LoginViewController alloc] init];
        [loginController setLoginType];
        [loginController setDelegate:self];
        [self.navigationController pushViewController:loginController animated:YES];
    }
    
}
- (IBAction)langBtnClick:(id)sender {
    
    myPickerViewController *myPickerController = [[myPickerViewController alloc] init];
    [myPickerController setDelegate:self];
    
    [myPickerController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentViewController:myPickerController animated:YES completion:nil];
    
}
- (IBAction)newsViewClick:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(didTouchNewButton)]) {
        [self.delegate didTouchNewButton];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)tutoBtn:(id)sender {
    
    if ([_tutoBtn isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kTutoY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTutoY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}

- (IBAction)helpViewClick:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(didTouchHelpButton)]) {
        [self.delegate didTouchHelpButton];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didLoginAfter
{
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:kLoginY];
    if(isLogin == YES){
        
        NSString* temp;
        temp = [[NSUserDefaults standardUserDefaults] stringForKey:klang];
        if([temp isEqualToString:@"ko"]){
              [_needLabel setText:NEED_KO];
        }else if([temp isEqualToString:@"vi"]){
              [_needLabel setText:NEED_VI];
        }else{
              //[_needLabel setText:NEED_KO];
        }
        [_emailLabel setText:[[NSUserDefaults standardUserDefaults] stringForKey:kEmail]];
        
    }
}

- (IBAction)pushBtnClick:(id)sender {
    
    if ([_pushBtn isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPushY];
        [[NSUserDefaults standardUserDefaults] synchronize];
  
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kPushY];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (UIView *subView in [self.view subviews]) {
        [subView setBackgroundColor:UIColorFromRGB(0xffffff)];
    }
    
    [self.view setBackgroundColor:UIColorFromRGB(0xffffff)];
    
    NSString* temp;
    temp = [[NSUserDefaults standardUserDefaults] stringForKey:klang];
    if([temp isEqualToString:@"ko"]){
        [self initScreenView_ko];
    }else if([temp isEqualToString:@"vi"]){
        [self initScreenView_vi];
    }else{
        temp = @"EN";
    }

    
    
    
    [self resetNavigationBarView:1];
    
    _emailLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:kEmail];
    // Do any additional setup after loading the view from its nib.
//    self.
//    for (UIView *subView in self.view) {
//        
//        if ([subView isKindOfClass:[NavigationBarView class]]) {
//            [subView removeFromSuperview];
//        }
//    }

//    CGFloat marginY = (kScreenBoundsWidth > 320)?100:0;
//    [self.mainView setFrame:CGRectMake(0+marginY, 0+marginY, kScreenBoundsWidth, kScreenBoundsHeight-marginY)];
////    [self.myScrollView setFrame:CGRectMake(0,0+marginY,kScreenBoundsWidth, kScreenBoundsHeight-marginY)];
//    
//    [self.myScrollView addSubview:self.contentView];
//    self.myScrollView.contentSize = self.contentView.frame.size;
//    self.myScrollView.contentSize = CGSizeMake(self.contentView.frame.size.width, self.contentView.frame.size.height+100);
//    //((UIScrollView *)self.view).contentSize = self.contentView.frame.size;
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
    CGFloat marginX = (kScreenBoundsWidth > 320)?25:0;
    CGFloat marginY = (kScreenBoundsWidth > 320)?70:0;
    
    if(kScreenBoundsWidth > 320){
        
        [self.realScrollView addSubview:self.contentView];
        self.realScrollView.contentSize = self.contentView.frame.size;
        self.realScrollView.contentSize = CGSizeMake(self.contentView.frame.size.width, self.contentView.frame.size.height);
        
        [self.realMainView addSubview:self.realScrollView];
        
        [self.mainView addSubview:self.realMainView];
        [self.realMainView setFrame:CGRectMake(0+marginX, 0+marginY, kScreenBoundsWidth, kScreenBoundsHeight-marginY)];
        
        for (UIView *subView in [self.view subviews]) {
            [subView setBackgroundColor:UIColorFromRGB(0xffffff)];
        }
        
        [self.view setBackgroundColor:UIColorFromRGB(0xffffff)];

    }else{
        
        //CGFloat marginY = (kScreenBoundsWidth > 320)?100:0;
        //[self.mainView setFrame:CGRectMake(0+marginY, 0+marginY, kScreenBoundsWidth, kScreenBoundsHeight-marginY)];
        //    [self.myScrollView setFrame:CGRectMake(0,0+marginY,kScreenBoundsWidth, kScreenBoundsHeight-marginY)];
        [self.myScrollView setBounces:false];
        [self.myScrollView addSubview:self.contentView];
        self.myScrollView.contentSize = CGSizeMake(kScreenBoundsWidth, self.contentView.frame.size.height+150);
//        self.myScrollView.contentSize = CGSizeMake(self.contentView.frame.size.width, self.contentView.frame.size.height+150);
        //((UIScrollView *)self.view).contentSize = self.contentView.frame.size;
        
    }
    
    [self resetNavigationBarView:1];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    /*
     - (void)viewDidLoad {
     [super viewDidLoad];
     [self.view addSubview:self.contentView];
     ((UIScrollView *)self.view).contentSize = self.contentView.frame.size;
     }

     - (void)viewDidUnload {
     self.contentView = nil;
     [super viewDidUnload];
     }
     
     */
}

- (void)resetNavigationBarView:(NSInteger) type
{
    [self.navigationItem setHidesBackButton:YES];
    
    for (UIView *subView in self.navigationController.navigationBar.subviews) {
        if ([subView isKindOfClass:[NavigationBarView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    [self.navigationController.navigationBar addSubview:[self navigationBarView:1]];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    
}

- (NavigationBarView *)navigationBarView:(NSInteger)navigationType
{
    NSString* temp;
    temp = [[NSUserDefaults standardUserDefaults] stringForKey:klang];
    if([temp isEqualToString:@"ko"]){
        _navigationBarView = [[NavigationBarView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kNavigationHeight) type:navigationType title:CONFIG_KO];
        [_navigationBarView setDelegate:self];
    }else if([temp isEqualToString:@"vi"]){
        _navigationBarView = [[NavigationBarView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kNavigationHeight) type:navigationType title:CONFIG_VI];
        [_navigationBarView setDelegate:self];
    }else{
        temp = @"EN";
    }
    
    return _navigationBarView;
}

#pragma mark - CPNavigationBarViewDelegate

- (void)didTouchBackButton
{
    [self.navigationController popViewControllerAnimated:YES];
    
    if ([self.delegate respondsToSelector:@selector(didTouchBackButton)]) {
        [self.delegate didTouchBackButton];
    }
}

#pragma mark - delegate button
- (void)didTouchHelpButton
{
    
}

- (void)didTouchNewButton
{
   
    
}

#pragma mark -initScreenView
-(void)initScreenView_ko{
    
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:kLoginY];
    if(isLogin == YES){
        [_needLabel setText:NEED_KO];
        [_emailLabel setText:[[NSUserDefaults standardUserDefaults] stringForKey:kEmail]];
    }else{
        [_needLabel setText:NEED_LOGIN_KO];
        [_emailLabel setText:@""];
    }
    
    [_L_HELP_KO setText:HELP_KO];
    [_L_TUTO_KO setText:TUTO_KO];
    BOOL isTuto = [[NSUserDefaults standardUserDefaults] boolForKey:kTutoY];
    if(isTuto == YES){
        [_tutoBtn setOn:true];
    }else{
        [_tutoBtn setOn:false];
    }
    
    [_L_NEW setText:NEWS_KO];
    [_L_ALRAM_SET_KO setText:ALRAM_SET_KO];
    [_LALRAM_ALLOW_KO setText:ALRAM_ALLOW_KO];
    [_LALRAM_DES_KO setText:ALRAM_DES_KO];
    
    BOOL isAlram = [[NSUserDefaults standardUserDefaults] boolForKey:kPushY];
    if(isAlram == YES){
        [_pushBtn setOn:true];
    }else{
        [_pushBtn setOn:false];
    }
    
    [_LPROGRAM_INFO_KO setText:PROGRAM_INFO_KO];
    [_LLANG_INFO_KO setText:LANG_INFO_KO];
    
    NSString* temp;
    temp = [[NSUserDefaults standardUserDefaults] stringForKey:klang];
    if([temp isEqualToString:@"ko"]){
        temp = @"KOREA";
    }else if([temp isEqualToString:@"vi"]){
        temp = @"VIETNAMESE";
    }else{
        temp = @"EN";
    }
    [_langLabel setText:temp];
    
    [_LAPP_INFO_KO setText:APP_INFO_KO];
    [_LCURR_VER_KO setText:CURR_VER_KO];
    [_LNEW_VER_KO setText:NEW_VER_KO];
    
    temp = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentVersion];
    [_curVerLabel setText:temp];
    temp = [temp stringByReplacingOccurrencesOfString:@"." withString:@""];
    int nCurVer, nUpVer;
    nCurVer = [temp intValue];
    
    temp = [[NSUserDefaults standardUserDefaults] stringForKey:kUpdateVersion];
    [_lastVerLabel setText:temp];
    temp = [temp stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    nUpVer = [temp intValue];
   
    if(nCurVer >= nUpVer){
        [_updateBtn setEnabled:false];
        [_updateBtn setBackgroundImage:[UIImage imageNamed:@"search_btn.png"] forState:UIControlStateNormal];
        [_updateBtn setTitle:LAST_VER_KO forState:UIControlStateNormal];
        
    }else{
        [_updateBtn setEnabled:true];
        [_updateBtn setBackgroundImage:[UIImage imageNamed:@"home_btn.png"] forState:UIControlStateNormal];
        [_updateBtn setTitle:LAST_VER_UP_KO forState:UIControlStateNormal];
    }
    
    [_sunnyDescLabel setText:SUNNY_DES_KO];
    [self resetNavigationBarView:1];
    
}

-(void)initScreenView_vi{
    
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:kLoginY];
    if(isLogin == YES){
        [_needLabel setText:NEED_VI];
        [_emailLabel setText:[[NSUserDefaults standardUserDefaults] stringForKey:kEmail]];
    }else{
        [_needLabel setText:NEED_LOGIN_VI];
        [_emailLabel setText:@""];
    }
    
    [_L_HELP_KO setText:HELP_VI];
    [_L_TUTO_KO setText:TUTO_VI];
    BOOL isTuto = [[NSUserDefaults standardUserDefaults] boolForKey:kTutoY];
    if(isTuto == YES){
        [_tutoBtn setOn:true];
    }else{
        [_tutoBtn setOn:false];
    }
    
    [_L_NEW setText:NEWS_VI];
    [_L_ALRAM_SET_KO setText:ALRAM_SET_VI];
    [_LALRAM_ALLOW_KO setText:ALRAM_ALLOW_VI];
    [_LALRAM_DES_KO setText:ALRAM_DES_VI];
    
    BOOL isAlram = [[NSUserDefaults standardUserDefaults] boolForKey:kPushY];
    if(isAlram == YES){
        [_pushBtn setOn:true];
    }else{
        [_pushBtn setOn:false];
    }
    
    [_LPROGRAM_INFO_KO setText:PROGRAM_INFO_VI];
    [_LLANG_INFO_KO setText:LANG_INFO_VI];
    
    NSString* temp;
    temp = [[NSUserDefaults standardUserDefaults] stringForKey:klang];
    if([temp isEqualToString:@"ko"]){
        temp = @"KOREA";
    }else if([temp isEqualToString:@"vi"]){
        temp = @"VIETNAMESE";
    }else{
        temp = @"EN";
    }
    [_langLabel setText:temp];
    
    [_LAPP_INFO_KO setText:APP_INFO_VI];
    [_LCURR_VER_KO setText:CURR_VER_VI];
    [_LNEW_VER_KO setText:NEW_VER_VI];
    
    temp = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentVersion];
    [_curVerLabel setText:temp];
    temp = [temp stringByReplacingOccurrencesOfString:@"." withString:@""];
    int nCurVer, nUpVer;
    nCurVer = [temp intValue];
    
    temp = [[NSUserDefaults standardUserDefaults] stringForKey:kUpdateVersion];
    [_lastVerLabel setText:temp];
    temp = [temp stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    nUpVer = [temp intValue];
    
    if(nCurVer >= nUpVer){
        [_updateBtn setEnabled:false];
        [_updateBtn setBackgroundImage:[UIImage imageNamed:@"search_btn.png"] forState:UIControlStateNormal];
        [_updateBtn setTitle:LAST_VER_VI forState:UIControlStateNormal];
        
    }else{
        [_updateBtn setEnabled:true];
        [_updateBtn setBackgroundImage:[UIImage imageNamed:@"home_btn.png"] forState:UIControlStateNormal];
        [_updateBtn setTitle:LAST_VER_UP_VI forState:UIControlStateNormal];
    }
    
    [_sunnyDescLabel setText:SUNNY_DES_VI];
    self.navigationBarView.title = CONFIG_VI;
    
    [self resetNavigationBarView:1];
    
    
}


#pragma mark -picker
- (void)didTouchPicker{
    NSInteger nKind;
    NSString* temp;
    temp = [[NSUserDefaults standardUserDefaults] stringForKey:klang];
    
    if([temp isEqualToString:@"ko"]){
        temp = @"KOREA";
        nKind = 0;
    }else if([temp isEqualToString:@"vi"]){
        temp = @"VIETNAMESE";
        nKind = 1;
    }else{
        nKind = 2;
        temp = @"EN";
    }
    
    [_langLabel setText:temp];
    
    if(![_preLang isEqualToString:temp]){
        if( nKind == 0){
             [self initScreenView_ko];
        }else{
            [self initScreenView_vi];
        }
    }
    _preLang = temp;
    
    
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
