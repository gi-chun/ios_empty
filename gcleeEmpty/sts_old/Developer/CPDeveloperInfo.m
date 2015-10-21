#import "CPDeveloperInfo.h"
#import "CPDeveloperViewController.h"

@interface CPDeveloperInfo () <CPDeveloperViewControllerDelegate>
{
	int	_developerMode;
	int _developerOpenMode;
	UILongPressGestureRecognizer	*_longPressedDeveloper;
	
	UIView							*_developerDialogView;
	UITextField						*_developerDialogTextField;
}

@end

@implementation CPDeveloperInfo

- (id)init
{
	self = [super init];
	
	if (self) {
		_developerMode = developerModeNone;
		_developerOpenMode = developerviewClose;
	}
	
	return self;
}

- (BOOL)checkActiveDeveloper
{
	if (_developerMode == developerModeYes) return YES;
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"elevenstDeveloperTeam"])
	{
		_developerMode = developerModeYes;
		return YES;
	}
	
#if DEBUG
	_developerMode = developerModeYes;
	return YES;
#endif
	
	return NO;
}

- (BOOL)checkOpenDeveloper
{
	if (_developerMode == developerModeNone || _developerMode == developerModeNo)	return YES;
	
	return NO;
}

- (void)addLongPressedGestureInButtonItem:(UIButton *)viewItem
{
	CGFloat pressDuration = [self checkActiveDeveloper] ? 2.f : 5.f;
	
	_longPressedDeveloper = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedGesture:)];
	_longPressedDeveloper.minimumPressDuration = pressDuration;
	[viewItem addGestureRecognizer:_longPressedDeveloper];
}

- (void)longPressedGesture:(id)sender
{
	if ([self checkActiveDeveloper]) {
		//developerViewController 호출
		[self openDeveloperContents];
		return;
	}
	
	if ([self checkOpenDeveloper]) {
		//developer 인증
		[self openDeveloperLogin];
		return;
	}
}

#pragma -mark open Developer Views..

- (void)openDeveloperLogin
{
	_developerMode = developerModeInputReady;
	[self createDeveloperPasswordView];
}

- (void)openDeveloperContents
{
	if (_developerOpenMode == developerviewOpen) return;
	_developerOpenMode = developerviewOpen;

	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if ([app initAssistiveTouchView]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"개발자포인터"
                                                        message:@"<----- 개발자화면이 변경되었습니다."
                                                       delegate:nil
                                              cancelButtonTitle:@"확인"
                                              otherButtonTitles:nil, nil];
        [alert show];
        
        _developerOpenMode = developerviewClose;
    }
    else {
        CPDeveloperViewController *controller = [[CPDeveloperViewController alloc] init];
        if ([controller respondsToSelector:@selector(setWantsFullScreenLayout:)]) {
            [controller setWantsFullScreenLayout:YES];
        }
        
        controller.delegate = self;
        [(UIViewController *)app.homeViewController presentViewController:controller animated:YES completion:nil];
    }
}

#pragma -mark developer Login View
- (void)createDeveloperPasswordView
{
	_developerDialogView = [[UIView alloc] initWithFrame:CGRectMake(10, 20 + 55, 300, 100)];
	UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
	UIToolbar *dialogMenu = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 5, _developerDialogView.frame.size.width, 45)];
	_developerDialogTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, _developerDialogView.frame.size.width - 20, _developerDialogView.frame.size.height - 20 - dialogMenu.frame.origin.y - dialogMenu.frame.size.height)];
	UIBarButtonItem *moveBtn, *cancelBtn;
	NSMutableArray *barButtons = [NSMutableArray array];
	
	moveBtn = [[UIBarButtonItem alloc] initWithTitle:@"확인" style:UIBarButtonItemStyleDone target:self action:@selector(confirmDeveloperInput:)];
	cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"취소" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelDeveloperInput:)];
	
	[barButtons addObject:cancelBtn];
	[barButtons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
	[barButtons addObject:moveBtn];
	
	[_developerDialogView setBackgroundColor:[UIColor lightGrayColor]];
	[_developerDialogView setAutoresizesSubviews:YES];
	[_developerDialogView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin];
	
	[dialogMenu setFrame:CGRectMake(_developerDialogTextField.frame.origin.x, _developerDialogTextField.frame.origin.y + _developerDialogTextField.frame.size.height + 5, dialogMenu.frame.size.width - _developerDialogTextField.frame.origin.x * 2, dialogMenu.frame.size.height)];
	[dialogMenu setItems:barButtons];
	[dialogMenu setBarStyle:UIBarStyleBlackOpaque];
	[dialogMenu setAutoresizesSubviews:YES];
	[dialogMenu setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
	
	[_developerDialogTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	[_developerDialogTextField setBackgroundColor:[UIColor whiteColor]];
	[_developerDialogTextField setEnablesReturnKeyAutomatically:YES];
	[_developerDialogTextField setAutoresizesSubviews:YES];
	[_developerDialogTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[_developerDialogTextField setLeftView:leftView];
	[_developerDialogTextField setLeftViewMode:UITextFieldViewModeAlways];
	[_developerDialogTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
	[_developerDialogTextField setReturnKeyType:UIReturnKeyDone];
	[_developerDialogTextField setPlaceholder:@"패스워드를 입력해주세요."];
	
	[[_developerDialogTextField layer] setMasksToBounds:YES];
	[[_developerDialogTextField layer] setBorderColor:[[UIColor blackColor] CGColor]];
	[[_developerDialogTextField layer] setBorderWidth:0.5];
	[[_developerDialogTextField layer] setCornerRadius:4];
	
	[[dialogMenu layer] setMasksToBounds:YES];
	[[dialogMenu layer] setBorderColor:[[UIColor blackColor] CGColor]];
	[[dialogMenu layer] setBorderWidth:0.5];
	[[dialogMenu layer] setCornerRadius:4];
	
	[[_developerDialogView layer] setMasksToBounds:YES];
	[[_developerDialogView layer] setBorderColor:[[UIColor darkGrayColor] CGColor]];
	[[_developerDialogView layer] setBorderWidth:0.5];
	[[_developerDialogView layer] setCornerRadius:4];
	
	[_developerDialogView addSubview:_developerDialogTextField];
	[_developerDialogView addSubview:dialogMenu];
	
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[app.window addSubview:_developerDialogView];
}

- (void)confirmDeveloperInput:(id)sender
{
	NSString *inputText = _developerDialogTextField.text;
	
	if ([@"11번가큐레이션" isEqualToString:inputText] || [@"베스트오픈마켓" isEqualToString:inputText])
	{
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"useDeveloperMode"];
		
		UIAlertView *pAlert = [[UIAlertView alloc] initWithTitle:@"개발자모드"
														 message:@"개발자 모드가 활성화 되었습니다."
														delegate:nil
											   cancelButtonTitle:@"확인"
											   otherButtonTitles:nil, nil];
		[pAlert show];
		
		[self releaseDeveloperInput];
		[self activeDeveloperView];
	}
	else
	{
		UIAlertView *pAlert = [[UIAlertView alloc] initWithTitle:@"개발자모드"
														 message:@"패스워드가 틀렸습니다."
														delegate:nil
											   cancelButtonTitle:@"확인"
											   otherButtonTitles:nil, nil];
		[pAlert show];
	}
}

- (void)cancelDeveloperInput:(id)sender
{
	_developerMode = developerModeNo;
	[self releaseDeveloperInput];
}

- (void)releaseDeveloperInput
{
	if (_developerDialogTextField)
	{
		[_developerDialogTextField resignFirstResponder];
		[_developerDialogTextField removeFromSuperview];
		_developerDialogTextField = nil;
	}
	
	if (_developerDialogView)
	{
		[_developerDialogView removeFromSuperview];
		_developerDialogView = nil;
	}
}

- (void)activeDeveloperView
{
	if (_developerMode == developerModeYes) return;
	
	_developerMode = developerModeYes;
	_longPressedDeveloper.minimumPressDuration = 2.f;
	
	//개발자 모드 저장
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"elevenstDeveloperTeam"];
}

#pragma -mark developerViewController Delegate Methods..
- (void)developerViewControllerClose
{
	_developerOpenMode = developerviewClose;
}

@end
