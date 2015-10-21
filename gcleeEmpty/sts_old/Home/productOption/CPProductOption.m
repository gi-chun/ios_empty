#import "CPProductOption.h"
#import "SBJSON.h"
#import "CPProductOptionItem.h"
#import "CPProductOptionLoadingView.h"
#import "RegexKitLite.h"
#import "AccessLog.h"

#define INIT_SCRIPT		@"getAppInitOptionData"
#define OPEN_SCRIPT		@"openAppOptionContainer"
#define GET_SCRIPT		@"getAppOptionData"
#define SET_SCRIPT		@"getAppOptionData"
#define CLOSE_SCRIPT	@"closeAppOptionContainer"
#define ORDER_SCRIPT	@"goToForOrder"

#define POLL_INTERVAL			0.5f
#define MAX_RETRY_TIME			3.0f

#define TAG_PRODUCT_OPTION_VIEW			50000
#define TAG_CELL_DEFAULT_INPUTFIELD		1000000

typedef NS_ENUM(NSUInteger, ProductReturnCode)
{
	ProductReturnCodeSuccess = 200,
	ProductReturnCodeRetry = 449,
	ProductReturnCodeTooBig = 431,
	ProductReturnCodeError = 500
};

typedef NS_ENUM(NSUInteger, ProductOptionName)
{
	ProductOptionNameDeliveryTypeOptions = 0,
	ProductOptionNameDeliveryCharge,
	ProductOptionNameOptions,
	//	ProductOptionNameAddPrdOptions,
	ProductOptionNameSelectedOptions,
	ProductOptionNameSelectedAddPrdOptions,
	ProductOptionMax,
	ProductOptionUndefined = 98,
	ProductOptionUnknown = 99
};

typedef NS_ENUM(NSUInteger, ProductOrder)
{
	ProductOrderNow = 0,			// 구매하기
	ProductOrderInputBasket,		// 장바구니
	ProductOrderCartInsert			// 좋아요
};


@interface CPProductOption () <UIGestureRecognizerDelegate,
                               UITableViewDataSource,
                               UITableViewDelegate,
                               CPProductOptionItemDelegate,
                               UITextFieldDelegate>
{
	CGFloat _topButtonHeight;
	
	//총괄 레이아웃
	UIView *_optionView;
	UIButton *_drawerButton;
    UIButton *_optionBarButton;
	UIView *_productInfoView;
	UITableView *_optionTableView;
	
	//가이드뷰 설정
	BOOL isShowGuideView;
	UIImageView *_guideView;
	
	//keyboard Input View
	UIView *_inputKeyboardBgView;
	UIView *_inputKeyboardView;
	UITextField *_inputField;
	
	BOOL _isProductOptionOpen;

	//가격정보 레이아웃
	UIView *_priceView;
	UILabel *_priceLabel;
	UILabel *_priceCountLabel;
	
	//초기정보 저장
	CGFloat _openMinimumHeight;
	
	CGRect	_originalViewRect;
	CGRect	_originalBottomViewRect;
	
	CGRect _startFrame;
	CGRect _startBottomViewFrame;
	CGRect _prevBottomViewFrame;
	
	UIView *_bottomView;
	UIView *_parentView;
	
	//bottomview 가속도값
	CGFloat _scrollingKoef;
	
	//데이터 변수들
	NSArray *_jsonKeyString;
	NSMutableArray *_displayOptionDataArray;
	CGFloat _pollStartTime;

	//셀 선택 변수들
	NSInteger _selectRow;
	BOOL _isSelectInputKeyboard;
	CGFloat _keyboardHeight;
	NSString *_selectFindKey;
	UITextField *_writeTextField;
	CPProductOptionItem *_optionItemView;
    
    UIButton *cartButton;
    UIButton *purchaseButton;
    
    CPProductOptionLoadingView *loadingView;
}

@end

@implementation CPProductOption

- (void)dealloc
{
	if (_guideView) [_guideView removeFromSuperview], _guideView = nil;
	
	[self unFocusKeyboard];
	[self removeOptionItemView];

	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)removeFromSuperview
{
	if (_guideView) [_guideView removeFromSuperview], _guideView = nil;
	[self unFocusKeyboard];
	[self removeOptionItemView];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super removeFromSuperview];
}

- (id)initWithToolbarView:(UIView *)toolbarView parentView:(UIView *)parentView
{
	self = [super init];
	
	if (self) {
		_isProductOptionOpen = NO;
		_bottomView = toolbarView;
		_parentView = parentView;
		_openMinimumHeight = parentView.frame.size.height / 2;
		
		[self initLayout:toolbarView.frame];
		[self initData];
	}
	
	return self;
}

#pragma mark - layout method

- (void)initLayout:(CGRect)toolbarframe
{
	UIImage *imgOptionBarBtn = [UIImage imageNamed:@"option_bar_bg"];
	UIImage *imgOptionBarLine = [UIImage imageNamed:@"option_line_bg"];
	
	_topButtonHeight = imgOptionBarBtn.size.height + imgOptionBarLine.size.height;
	
	//self.view의 frame을 설정한다.
	CGRect frame = CGRectZero;
	frame.origin.x = toolbarframe.origin.x;
	frame.origin.y = toolbarframe.origin.y - _topButtonHeight;
	frame.size.width = toolbarframe.size.width;
	frame.size.height = toolbarframe.size.height + _topButtonHeight;
	[self setFrame:frame];

	_originalViewRect = frame;
	_originalBottomViewRect = toolbarframe;
	_scrollingKoef = _bottomView.frame.size.height / (_openMinimumHeight - _bottomView.frame.size.height - _topButtonHeight);
	
	//화면꾸미기
	UIImageView *optionBarImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width/2)-(imgOptionBarBtn.size.width/2),
																				0,
																				imgOptionBarBtn.size.width,
																				imgOptionBarBtn.size.height)];
    [optionBarImageView setImage:imgOptionBarBtn];
    [optionBarImageView setUserInteractionEnabled:YES];
	[self addSubview:optionBarImageView];
	
	UIImageView *optionBarLine = [[UIImageView alloc] initWithFrame:CGRectMake(0,
																			   CGRectGetMaxY(optionBarImageView.frame),
																			   self.frame.size.width,
																			   imgOptionBarLine.size.height)];
	optionBarLine.image = imgOptionBarLine;
	[self addSubview:optionBarLine];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, 0, 50, CGRectGetHeight(optionBarImageView.frame))];
	[titleLabel setText:@"옵션선택"];
	[titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
	[titleLabel setTextColor:UIColorFromRGB(0xffffff)];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[optionBarImageView addSubview:titleLabel];

	UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame)+8, 7.5f, 1, 13)];
	[lineView setBackgroundColor:UIColorFromRGB(0x758aef)];
	[optionBarImageView addSubview:lineView];
	
	lineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lineView.frame), 7.5f, 1, 13)];
	[lineView setBackgroundColor:UIColorFromRGB(0x4960d3)];
	[optionBarImageView addSubview:lineView];

	_drawerButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_drawerButton setImage:[UIImage imageNamed:@"option_up_nor.png"] forState:UIControlStateNormal];
	[_drawerButton setFrame:CGRectMake(CGRectGetMaxX(lineView.frame)+7, 7.5f, 19, 13)];
	[optionBarImageView addSubview:_drawerButton];
    
    _optionBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_optionBarButton setFrame:CGRectMake(0, 0, CGRectGetWidth(optionBarImageView.frame), CGRectGetHeight(optionBarImageView.frame))];
    [_optionBarButton addTarget:self action:@selector(openDrawer) forControlEvents:UIControlEventTouchUpInside];
    [_optionBarButton setAccessibilityLabel:@"주문옵션창열기" Hint:@"주문하기 옵션 창을 엽니다"];
    [optionBarImageView addSubview:_optionBarButton];

	//실제 옵션을 보여주는 뷰
	_optionView = [[UIView alloc] initWithFrame:CGRectMake(0,
														  _topButtonHeight,
														  self.frame.size.width,
														  self.frame.size.height - _topButtonHeight)];
	_optionView.backgroundColor = UIColorFromRGB(0xeeeeee);
	_optionView.clipsToBounds = YES;
	[self addSubview:_optionView];

	//뷰하단의 구매하기 정보 뷰
	_productInfoView = [self makeProductInfoView];
	[_optionView addSubview:_productInfoView];

	//옵션 테이블 뷰
	_optionTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(_optionView.frame)-20, 0)
													style:UITableViewStylePlain];
    [_optionTableView setDataSource:self];
    [_optionTableView setDelegate:self];
    [_optionTableView setClipsToBounds:YES];
	[_optionTableView setBackgroundColor:[UIColor clearColor]];
	[_optionTableView setScrollEnabled:NO];
    [_optionTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];;
    [_optionView insertSubview:_optionTableView belowSubview:_productInfoView];
    
	//인디케이터 설정
//	[_indicator stopAnimating];
    
    //LoadingView
    loadingView = [[CPProductOptionLoadingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_optionView.frame)/2-20,
                                                                               CGRectGetHeight(_optionView.frame)/2-20,
                                                                               40,
                                                                               40)];
	
	//제스쳐 등록
	UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
	[pan setDelegate:self];
	[self addGestureRecognizer:pan];
	
	//키보드 입력창
	_inputKeyboardBgView = [[UIView alloc] initWithFrame:CGRectZero];
	_inputKeyboardBgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7f];
	
	_inputKeyboardView = [[UIView alloc] initWithFrame:CGRectMake(0, 1000.f, self.frame.size.width, 50.f)];
	_inputKeyboardView.backgroundColor = UIColorFromRGB(0xe9e9e9);

	CGFloat itemHeight = 30.f;

	UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[confirmBtn setTitle:@"확인" forState:UIControlStateNormal];
	[confirmBtn.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
	[confirmBtn setTitleColor:UIColorFromRGB(0x5d5fd6) forState:UIControlStateNormal];
	[confirmBtn setBackgroundColor:[UIColor clearColor]];
	[confirmBtn setFrame:CGRectMake(self.frame.size.width - 5.f - 50.f - 5.f - 50.f, (50.f / 2) - (itemHeight / 2), 50.f, itemHeight)];
    [confirmBtn.layer setBorderColor:UIColorFromRGB(0xafb0c2).CGColor];
    [confirmBtn.layer setBorderWidth:1.0f];
	[confirmBtn addTarget:self action:@selector(onClickInputTextConfirm:) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn setAccessibilityLabel:@"확인" Hint:@"주문을 확인합니다"];
	[_inputKeyboardView addSubview:confirmBtn];

	UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[cancelBtn setTitle:@"취소" forState:UIControlStateNormal];
	[cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
	[cancelBtn setTitleColor:UIColorFromRGB(0x868ba8) forState:UIControlStateNormal];
	[cancelBtn setBackgroundColor:[UIColor clearColor]];
    [cancelBtn.layer setBorderColor:UIColorFromRGB(0xafb0c2).CGColor];
    [cancelBtn.layer setBorderWidth:1.0f];
	[cancelBtn setFrame:CGRectMake(self.frame.size.width - 5.f - 50.f, (50.f / 2) - (itemHeight / 2), 50.f, itemHeight)];
	[cancelBtn addTarget:self action:@selector(onClickInputTextCancel:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setAccessibilityLabel:@"취소" Hint:@"주문을 취소합니다"];
	[_inputKeyboardView addSubview:cancelBtn];

	_inputField = [[UITextField alloc] initWithFrame:CGRectMake(10.f,
																(50.f / 2) - (itemHeight / 2),
																self.frame.size.width - 20.f - (50.f * 2) - 5.f,
																itemHeight)];
    [_inputField.layer setBorderColor:UIColorFromRGB(0xafb0c2).CGColor];
    [_inputField.layer setBorderWidth:1.0f];
    [_inputField setDelegate:self];
    [_inputField setFont:[UIFont systemFontOfSize:13]];
    [_inputField setTextColor:UIColorFromRGB(0x868bab)];
    [_inputField setBorderStyle:UITextBorderStyleNone];
	[_inputKeyboardView addSubview:_inputField];

	[_inputKeyboardView setHidden:YES];
	[_inputKeyboardBgView addSubview:_inputKeyboardView];
}

- (UIView *)makeProductInfoView
{
	//뷰 생성
	UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, 3.f, self.frame.size.width, 96.f)];
	baseView.backgroundColor = UIColorFromRGB(0x2c2f41);

	//상품 가격 및 상품 갯수
	_priceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, baseView.frame.size.width, 40.f)];
	[_priceView setBackgroundColor:[UIColor clearColor]];
	[baseView addSubview:_priceView];
	
	UILabel *titleTotalPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 43, 40)];
	[titleTotalPriceLabel setText:@"총 금액"];
	[titleTotalPriceLabel setFont:[UIFont boldSystemFontOfSize:14]];
	[titleTotalPriceLabel setTextColor:UIColorFromRGB(0xffffff)];
	[titleTotalPriceLabel setBackgroundColor:[UIColor clearColor]];
	[_priceView addSubview:titleTotalPriceLabel];

	UILabel *titleCountPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleTotalPriceLabel.frame), 0, 40, 40)];
	[titleCountPriceLabel setText:@"(수량)"];
	[titleCountPriceLabel setFont:[UIFont systemFontOfSize:14]];
	[titleCountPriceLabel setTextColor:UIColorFromRGB(0xffffff)];
	[titleCountPriceLabel setBackgroundColor:[UIColor clearColor]];
	[_priceView addSubview:titleCountPriceLabel];

	_priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	[_priceLabel setNumberOfLines:1];
	[_priceLabel setMinimumScaleFactor:10];
	[_priceLabel setAdjustsFontSizeToFitWidth:YES];
	[_priceLabel setTextColor:UIColorFromRGB(0xe71818)];
	[_priceLabel setBackgroundColor:[UIColor clearColor]];
	[_priceLabel setFont:[UIFont boldSystemFontOfSize:22]];
	[_priceLabel setTextAlignment:NSTextAlignmentLeft];
	[_priceLabel setLineBreakMode:NSLineBreakByWordWrapping];
	[_priceView addSubview:_priceLabel];

	_priceCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	[_priceCountLabel setNumberOfLines:1];
	[_priceCountLabel setMinimumScaleFactor:8];
	[_priceCountLabel setAdjustsFontSizeToFitWidth:YES];
	[_priceCountLabel setTextColor:UIColorFromRGB(0xe71818)];
	[_priceCountLabel setBackgroundColor:[UIColor clearColor]];
	[_priceCountLabel setFont:[UIFont boldSystemFontOfSize:14]];
	[_priceCountLabel setTextAlignment:NSTextAlignmentLeft];
	[_priceCountLabel setLineBreakMode:NSLineBreakByWordWrapping];
	[_priceView addSubview:_priceCountLabel];

    // 장바구니
    UIImage *cartImageNormal = [UIImage imageNamed:@"option_btn_basket_nor.png"];
    UIImage *cartImageHighlighted = [UIImage imageNamed:@"option_btn_basket_pre.png"];
    
    cartImageNormal = [cartImageNormal resizableImageWithCapInsets:UIEdgeInsetsMake(cartImageNormal.size.height / 2,
                                                                                    cartImageNormal.size.width / 2,
                                                                                    cartImageNormal.size.height / 2,
                                                                                    cartImageNormal.size.width / 2)];
    cartImageHighlighted = [cartImageHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(cartImageHighlighted.size.height / 2,
                                                                                              cartImageHighlighted.size.width / 2,
                                                                                              cartImageHighlighted.size.height / 2,
                                                                                              cartImageHighlighted.size.width / 2)];
    
    cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cartButton setFrame:CGRectMake(10, CGRectGetHeight(baseView.frame)-50, CGRectGetWidth(baseView.frame)/2-15, 40)];
    [cartButton setBackgroundImage:cartImageNormal forState:UIControlStateNormal];
    [cartButton setBackgroundImage:cartImageHighlighted forState:UIControlStateHighlighted];
    [cartButton setTitle:@"장바구니" forState:UIControlStateNormal];
    [cartButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [cartButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [cartButton addTarget:self action:@selector(onClickCartButton:) forControlEvents:UIControlEventTouchUpInside];
    [cartButton setAccessibilityLabel:@"장바구니" Hint:@"장바구니에 담습니다"];
    [baseView addSubview:cartButton];
    
	//구매하기
	UIImage *purchaseImageNormal = [UIImage imageNamed:@"option_btn_buying_nor.png"];
	UIImage *purchaseImageHighlighted = [UIImage imageNamed:@"option_btn_buying_pre.png"];
	
	purchaseImageNormal = [purchaseImageNormal resizableImageWithCapInsets:UIEdgeInsetsMake(purchaseImageNormal.size.height / 2,
																							purchaseImageNormal.size.width / 2,
																							purchaseImageNormal.size.height / 2,
																							purchaseImageNormal.size.width / 2)];
	purchaseImageHighlighted = [purchaseImageHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(purchaseImageHighlighted.size.height / 2,
																									  purchaseImageHighlighted.size.width / 2,
																									  purchaseImageHighlighted.size.height / 2,
																									  purchaseImageHighlighted.size.width / 2)];
	purchaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [purchaseButton setFrame:CGRectMake(CGRectGetMaxX(cartButton.frame)+10, CGRectGetHeight(baseView.frame)-50, CGRectGetWidth(baseView.frame)/2-15, 40)];
	[purchaseButton setBackgroundImage:purchaseImageNormal forState:UIControlStateNormal];
	[purchaseButton setBackgroundImage:purchaseImageHighlighted forState:UIControlStateHighlighted];
	[purchaseButton setTitle:@"구매하기" forState:UIControlStateNormal];
	[purchaseButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
	[purchaseButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
	[purchaseButton addTarget:self action:@selector(onClickPurchasesButton:) forControlEvents:UIControlEventTouchUpInside];
	[purchaseButton setAccessibilityLabel:@"구매하기" Hint:@"주문결제를 실행합니다"];
	[baseView addSubview:purchaseButton];
    
	return baseView;
}

- (id)makeSelectAndInputWithDisplayType:(NSString *)type selectedText:(NSString *)text tag:(NSUInteger)tag
{
	CGFloat totalMargin = 30.0f, labelWidth = 80.0f, leftMargin = 5.0f;;
	
	if ([@"select" isEqualToString:type])
	{
		UIImage *optionBtnImageNor = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"option_select_normal" ofType:@"png"]];
		UIImage *optionBtnImageHil = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"option_select_selected" ofType:@"png"]];
		
		optionBtnImageNor = [optionBtnImageNor resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 30)];
		optionBtnImageHil = [optionBtnImageHil resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 30)];
		
		UIButton *selectProduct = [UIButton buttonWithType:UIButtonTypeCustom];
		
		[selectProduct setTag:tag];
		[selectProduct.titleLabel setNumberOfLines:1];
		[selectProduct.titleLabel setAdjustsFontSizeToFitWidth:YES];
		[selectProduct setTitle:text forState:UIControlStateNormal];
		[selectProduct.titleLabel setFont:[UIFont systemFontOfSize:11]];
		[selectProduct setContentEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 32)];
		[selectProduct setBackgroundImage:optionBtnImageNor forState:UIControlStateNormal];
		[selectProduct setBackgroundImage:optionBtnImageHil forState:UIControlStateHighlighted];
		[selectProduct.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
		[selectProduct setTitleColor:UIColorFromRGB(0x888888) forState:UIControlStateNormal];
		[selectProduct setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
		[selectProduct setFrame:CGRectMake(0, 0, self.frame.size.width - labelWidth - totalMargin, optionBtnImageNor.size.height)];
        [selectProduct setAccessibilityLabel:@"선택" Hint:@"옵션을 선택합니다"];
		
		if ([self respondsToSelector:@selector(onClickKindOfSelectOption:)]) {
			[selectProduct addTarget:self action:@selector(onClickKindOfSelectOption:) forControlEvents:UIControlEventTouchUpInside];
		}
		
		return selectProduct;
	}
	else if ([@"input" isEqualToString:type])
	{
		UIImage *optionInputImageNor = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"option_input" ofType:@"png"]];
		
		optionInputImageNor = [optionInputImageNor resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
		
		UIView *leftMarginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, leftMargin, optionInputImageNor.size.height)];
		
		[leftMarginView setBackgroundColor:[UIColor clearColor]];
		
		// 인풋형 리스트
		UITextField *inputField = [[UITextField alloc] initWithFrame:CGRectMake(0,
																				0,
																				self.frame.size.width - labelWidth - totalMargin,
																				optionInputImageNor.size.height)];
		
		[inputField setLeftViewMode:UITextFieldViewModeAlways];
		[inputField setLeftView:leftMarginView];
		[inputField setBackground:optionInputImageNor];
		[inputField setText:text];
		[inputField setReturnKeyType:UIReturnKeyDone];
		[inputField setTextAlignment:NSTextAlignmentLeft];
		[inputField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[inputField setTextColor:UIColorFromRGB(0x888888)];
		[inputField setFont:[UIFont systemFontOfSize:11]];
		[inputField setDelegate:nil];
		[inputField setTag:tag];
		
		UIButton *inputButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[inputButton setFrame:inputField.bounds];
		[inputButton setTag:tag + 1000];
		[inputButton setBackgroundColor:[UIColor clearColor]];
		[inputButton addTarget:self action:@selector(onClickInputStringTextButton:) forControlEvents:UIControlEventTouchUpInside];
        [inputButton setAccessibilityLabel:@"" Hint:@""];
		
		[inputField addSubview:inputButton];
		
		return inputField;
	}
	else if ([@"text" isEqualToString:type])
	{
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
		
		[label setText:text];
		[label setFont:[UIFont systemFontOfSize:11]];
		[label setTextColor:UIColorFromRGB(0x888888)];
		[label setTextAlignment:NSTextAlignmentLeft];
		[label setFrame:CGRectMake(0, 0, self.frame.size.width - labelWidth - totalMargin, 25.0f)];
		
		return label;
	}
	
	return nil;
}


#pragma mark - javascript get / set methods

- (void)initData
{
	_displayOptionDataArray = [[NSMutableArray alloc] init];
	
	_jsonKeyString = [[NSArray alloc] initWithObjects:@"deliveryTypeOptions", @"deliveryChargeOptions", @"options", @"selectedOptions", @"selectedAddPrdOptions", nil];
}

- (NSString *)executeScript:(NSString *)script
{
	return [self.executeWebView execute:script];
}

- (void)poll:(NSString *)startScript
{
	if (startScript) {
		//인디케이터 보여주기
//		[_indicator startAnimating];
		
		_pollStartTime = CACurrentMediaTime();
	}
	
    if (CACurrentMediaTime() - _pollStartTime >= MAX_RETRY_TIME) {
        return [self poll:INIT_SCRIPT];
    }
	
	SBJSON *json = [[SBJSON alloc] init];
	NSString *jsonString = [self executeScript:[(startScript ? startScript : GET_SCRIPT) stringByAppendingString:@"()"]];
	NSDictionary *jsonData = jsonString ? [json objectWithString:jsonString] : nil;
	
	if (jsonData) {
		NSNumber *code = [jsonData objectForKey:@"code"];
		
		if ([code intValue] == ProductReturnCodeRetry || !code) {
			[self performSelector:@selector(poll:) withObject:nil afterDelay:POLL_INTERVAL];
			return;
		}
		
		[self setProductOptionRawData:jsonData];
        
        if ([code intValue] == ProductReturnCodeSuccess) {
            [self performSelector:@selector(drawOptions) withObject:nil];
        }
	}
}

- (void)pollFromOptionItem:(NSString *)startScript
{
    if (startScript) {
        _pollStartTime = CACurrentMediaTime();
    }
    
    if (CACurrentMediaTime() - _pollStartTime >= MAX_RETRY_TIME) {
        return [self pollFromOptionItem:INIT_SCRIPT];
    }
    
    SBJSON *json = [[SBJSON alloc] init];
    NSString *jsonString = [self executeScript:[(startScript ? startScript : GET_SCRIPT) stringByAppendingString:@"()"]];
    NSDictionary *jsonData = jsonString ? [json objectWithString:jsonString] : nil;
    
    if (jsonData) {
        NSNumber *code = [jsonData objectForKey:@"code"];
        
        if ([code intValue] == ProductReturnCodeRetry || !code) {
            [self performSelector:@selector(pollFromOptionItem:) withObject:nil afterDelay:POLL_INTERVAL];
            return;
        }
        
        [self setProductOptionRawData:jsonData];
        
        if ([code intValue] == ProductReturnCodeSuccess) {
            [self performSelector:@selector(drawOptions) withObject:nil];
        }
        
        [_optionItemView reloadOptionItemView:jsonData];
    }
}

- (void)drawOptions
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(poll:) object:nil];
	
	//인디케이터 숨기기
//	[_indicator stopAnimating];
    [self stopLoadingAnimation];

	//상품 정보 저장
	[_displayOptionDataArray removeAllObjects];
	
	NSMutableArray *deliveryOptions = [[NSMutableArray alloc] init];
	NSArray *optionsArray = [_productOptionRawData objectForKey:[_jsonKeyString objectAtIndex:ProductOptionNameDeliveryTypeOptions]];
	
	for (NSDictionary *dic in optionsArray)
	{
		NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
		
		[tempDic setObject:@"배송 방법" forKey:@"label"];
		[tempDic setObject:[dic objectForKey:@"dispType"] ? [dic objectForKey:@"dispType"] : @"" forKey:@"dispType"];
		[tempDic setObject:[dic objectForKey:@"selectedText"] ? [dic objectForKey:@"selectedText"] : @"" forKey:@"selectedText"];
		[tempDic setObject:[dic objectForKey:@"selectedValue"] ? [dic objectForKey:@"selectedValue"] : @"" forKey:@"selectedValue"];
		[tempDic setObject:[_jsonKeyString objectAtIndex:ProductOptionNameDeliveryTypeOptions] ? [_jsonKeyString objectAtIndex:ProductOptionNameDeliveryTypeOptions] : @"" forKey:@"findKey"];
		
		[deliveryOptions addObject:tempDic];
	}
	
	optionsArray = [_productOptionRawData objectForKey:[_jsonKeyString objectAtIndex:ProductOptionNameDeliveryCharge]];
	
	for (NSDictionary *dic in optionsArray)
	{
		NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
		NSString *displayType = [dic objectForKey:@"dispType"];
		
		if ([@"text" isEqualToString:displayType])
		{
			[tempDic setObject:[dic objectForKey:@"value"] ? [dic objectForKey:@"value"] : @"" forKey:@"selectedText"];
		}
		else
		{
			[tempDic setObject:[dic objectForKey:@"selectedText"] ? [dic objectForKey:@"selectedText"] : @"" forKey:@"selectedText"];
			[tempDic setObject:[dic objectForKey:@"selectedValue"] ? [dic objectForKey:@"selectedValue"] : @"" forKey:@"selectedValue"];
		}
		
		[tempDic setObject:@"배송비 결제" forKey:@"label"];
		[tempDic setObject:displayType ? displayType : @"" forKey:@"dispType"];
		[tempDic setObject:[_jsonKeyString objectAtIndex:ProductOptionNameDeliveryCharge] ? [_jsonKeyString objectAtIndex:ProductOptionNameDeliveryCharge] : @"" forKey:@"findKey"];
		
		[deliveryOptions addObject:tempDic];
	}
	
	if (deliveryOptions && [deliveryOptions count] > 0)
	{
		NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
		
		[dataDic setObject:@"delivery" forKey:@"findKey"];
		[dataDic setObject:[NSNumber numberWithUnsignedInteger:[deliveryOptions count]] forKey:@"count"];
		[dataDic setObject:deliveryOptions forKey:@"optionData"];
		
		[_displayOptionDataArray addObject:dataDic];
	}
	
	optionsArray = [_productOptionRawData objectForKey:[_jsonKeyString objectAtIndex:ProductOptionNameOptions]];
	
	for (NSDictionary *dic in optionsArray)
	{
		NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
		
		for (NSString *key in dic) [tempDic setObject:[dic objectForKey:key] ? [dic objectForKey:key] : @"" forKey:key];
		
		[tempDic setObject:[_jsonKeyString objectAtIndex:ProductOptionNameOptions] ? [_jsonKeyString objectAtIndex:ProductOptionNameOptions] : @"" forKey:@"findKey"];
		
		[_displayOptionDataArray addObject:tempDic];
	}
	
	if ([_productOptionRawData objectForKey:@"optionCnt"])
	{
		NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
		
		[tempDic setObject:[_productOptionRawData objectForKey:@"prdName"] ? [_productOptionRawData objectForKey:@"prdName"] : @"" forKey:@"title"];
		[tempDic setObject:[_productOptionRawData objectForKey:@"optionCnt"] ? [_productOptionRawData objectForKey:@"optionCnt"] : @"" forKey:@"cnt"];
		
		[_displayOptionDataArray addObject:tempDic];
	}
	
	for (NSUInteger index = ProductOptionNameSelectedOptions; index < ProductOptionMax; index++)
	{
		optionsArray = [_productOptionRawData objectForKey:[_jsonKeyString objectAtIndex:index]];
		
		for (NSDictionary *dic in optionsArray)
		{
			NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
			
			for (NSString *key in dic) [temp setObject:[dic objectForKey:key] ? [dic objectForKey:key] : @"" forKey:key];
			
			[temp setObject:[_jsonKeyString objectAtIndex:index] ? [_jsonKeyString objectAtIndex:index] : @"" forKey:@"findKey"];
			
			[_displayOptionDataArray addObject:temp];
		}
	}
	
	//상품 구매 수량 / 가격 보여주기
	[_priceLabel setText:[NSString stringWithFormat:@"%@", [Modules numberFormatComma:[self.productOptionRawData objectForKey:@"totalPrice"] appendUnit:@""]]];
	[_priceCountLabel setText:[NSString stringWithFormat:@"원(%@)", [Modules numberFormatComma:[self.productOptionRawData objectForKey:@"totalCnt"] appendUnit:@"개"]]];
	[_priceLabel sizeToFit];
	[_priceCountLabel sizeToFit];
	
	CGFloat _priceOffsetX = _priceView.frame.size.width - (_priceLabel.frame.size.width + _priceCountLabel.frame.size.width + 10.f);
	
	[_priceLabel setFrame:CGRectMake(_priceOffsetX, 0, _priceLabel.frame.size.width, _priceView.frame.size.height)];
	[_priceCountLabel setFrame:CGRectMake(CGRectGetMaxX(_priceLabel.frame), 0, _priceCountLabel.frame.size.width, _priceView.frame.size.height)];
    
    //구매하기 버튼 프레임 재설정 - isBasketDisableType이 "Y" 일 경우 장바구니 버튼 비노출
    NSString *isBasketDisableType = self.productOptionRawData[@"isBasketDisableType"];
    if ([@"Y" isEqualToString:isBasketDisableType]) {
        [purchaseButton setFrame:CGRectMake(10, CGRectGetMinY(purchaseButton.frame), CGRectGetWidth(self.frame)-20, 40)];
    }
	
	//테이블뷰 셋팅
	[_optionTableView reloadData];
	[_optionTableView setScrollEnabled:_optionTableView.frame.size.height < _optionTableView.contentSize.height];
}

#pragma mark - class Methods

- (void)setGuideView:(UIImageView *)guideView
{
	isShowGuideView = YES;
	
	_guideView = guideView;
	
	//에니메이션
	[UIView animateWithDuration:0.5f animations:^{
		_guideView.alpha = 1.f;
	} completion:^(BOOL finished) {
		[self performSelector:@selector(destoryProductOptionGuideView:) withObject:_guideView afterDelay:30.f];
	}];
}

- (void)destoryProductOptionGuideView:(UIImageView *)guideView
{
	isShowGuideView = NO;
	
	[UIView animateWithDuration:1.0f animations:^{
		guideView.alpha = 0.f;
	} completion:^(BOOL finished) {
		[guideView removeFromSuperview];
	}];
}

- (void)order:(ProductOrder)orderType
{
	NSString *orderString = nil;
	
	switch (orderType)
	{
		case ProductOrderNow:
			orderString = @"'OrderNow'";
			break;
		case ProductOrderInputBasket:
			orderString = @"'InputBasket'";
			break;
		case ProductOrderCartInsert:
			orderString = @"'interestCartInsert'";
			break;
		default:
			break;
	}
	
	if (orderString) {
		[self executeScript:[ORDER_SCRIPT stringByAppendingString:[NSString stringWithFormat:@"(%@)", orderString]]];

		//팝업브라우저일경우 화면을 닫아준다.
		if (self.isPopupBrowser) {
			if(self.delegate && [self.delegate respondsToSelector:@selector(productOptionOnClickPurchasesItem)]) {
				[self.delegate productOptionOnClickPurchasesItem];
			}
		}
	}
}

- (void)setSelectedRowFindKey:(NSString *)findKey
{
	if (_selectFindKey) _selectFindKey = nil;
	_selectFindKey = [[NSString alloc] initWithString:findKey];
}

- (void)unFocusKeyboard
{
	//키보드 내리기
	[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)removeOptionItemView
{
	if (_optionItemView) {
		[_optionItemView removeFromSuperview];
		_optionItemView = nil;
	}
}

- (void)customAlertSelectedProductOption:(NSDictionary *)selectedOption
{
	if ([[_jsonKeyString objectAtIndex:ProductOptionNameDeliveryCharge] isEqualToString:_selectFindKey]) {
		[self selectDeliveryOptions:selectedOption type:ProductOptionNameDeliveryCharge];
	}
	else if ([[_jsonKeyString objectAtIndex:ProductOptionNameDeliveryTypeOptions] isEqualToString:_selectFindKey]) {
		[self selectDeliveryOptions:selectedOption type:ProductOptionNameDeliveryTypeOptions];
	}
	else if ([[_jsonKeyString objectAtIndex:ProductOptionNameOptions] isEqualToString:_selectFindKey]) {
		[self selectOptions:selectedOption];
	}
	
	[self pollFromOptionItem:GET_SCRIPT];
}

- (void)selectDeliveryOptions:(NSDictionary *)selectedOption type:(ProductOptionName)deliveryType
{
	SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
	
	NSString *jsonKey = deliveryType == ProductOptionNameDeliveryCharge ? @"selectDeliveryChargeOptions" : @"selectDeliveryTypeOptions";
	NSMutableDictionary *option = [[NSMutableDictionary alloc] init];
	NSDictionary *sendOptionDic;
	
	[option setObject:[selectedOption objectForKey:@"value"] ? [selectedOption objectForKey:@"value"] : @"" forKey:@"value"];
	
	sendOptionDic = [NSDictionary dictionaryWithObjectsAndKeys:
					 [APP_VERSION stringByReplacingOccurrencesOfString:@"." withString:@""], @"version",
					 option, jsonKey, nil];
	
	[self executeScript:[SET_SCRIPT stringByAppendingFormat:@"(%@)", [jsonWriter stringWithObject:sendOptionDic]]];
}

- (void)selectOptions:(NSDictionary *)selectedOption
{
	SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
	
	NSArray *sendOptionArray;
	NSDictionary *sendOptionDic;
	NSMutableDictionary *option = [[NSMutableDictionary alloc] init];
	
	[option setObject:[selectedOption objectForKey:@"value"] ? [selectedOption objectForKey:@"value"] : @"" forKey:@"value"];
	[option setObject:[[_displayOptionDataArray objectAtIndex:_selectRow] objectForKey:@"idx"] ? [[_displayOptionDataArray objectAtIndex:_selectRow] objectForKey:@"idx"] : @"" forKey:@"idx"];
	[option setObject:[[_displayOptionDataArray objectAtIndex:_selectRow] objectForKey:@"dispType"] ? [[_displayOptionDataArray objectAtIndex:_selectRow] objectForKey:@"dispType"] : @"" forKey:@"dispType"];
	
	sendOptionArray = [NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[NSArray arrayWithObject:option] forKey:@"option"]];
	sendOptionDic = [NSDictionary dictionaryWithObjectsAndKeys:[APP_VERSION stringByReplacingOccurrencesOfString:@"." withString:@""], @"version", sendOptionArray, @"selectOptions", nil];
	
	[self executeScript:[SET_SCRIPT stringByAppendingFormat:@"(%@)", [jsonWriter stringWithObject:sendOptionDic]]];
}

- (void)openKeyboard:(UITextField *)textField
{
	_isSelectInputKeyboard = YES;
	
	_inputField.keyboardType = textField.keyboardType;
	_inputField.text = textField.text;
	
	if (_inputField.keyboardType != UIKeyboardTypeNumberPad)
	{
//		_inputField.text = @"";
		_inputField.returnKeyType = UIReturnKeyDone;
	}
	
	_writeTextField = textField;
	
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	_inputKeyboardBgView.frame = app.window.bounds;
	[app.window addSubview:_inputKeyboardBgView];
	
	[_inputField becomeFirstResponder];
}

#pragma mark - pressed Button Methods

- (void)onClickPurchasesButton:(id)sender
{
	[self order:ProductOrderNow];
    
    //AccessLog - 옵션서랍 - 구매하기
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"MPG0107"];
}

- (void)onClickCartButton:(id)sender
{
	[self order:ProductOrderInputBasket];
    
    //AccessLog - 옵션서랍 - 장바구니
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"MPG0106"];
}

- (void)onClickKindOfSelectOption:(id)sender
{
	NSMutableArray *productOptions = [[NSMutableArray alloc] init];
	
	_selectRow = [(UIButton *)sender tag];
    
    if ([[_displayOptionDataArray objectAtIndex:_selectRow] objectForKey:@"findKey"]) {
        [self setSelectedRowFindKey:[[_displayOptionDataArray objectAtIndex:_selectRow] objectForKey:@"findKey"]];
    }
    else {
        return;
    }
	
	if ([@"delivery" isEqualToString:_selectFindKey])
	{
		NSArray *option = [[_displayOptionDataArray objectAtIndex:_selectRow] objectForKey:@"optionData"];
		for (NSDictionary *dic in option)
		{
			NSString *findKey = [dic objectForKey:@"findKey"];
			
			if ([findKey isEqualToString:[_jsonKeyString objectAtIndex:[((UIButton *)sender) tag]]])
			{
				[self setSelectedRowFindKey:findKey];
				break;
			}
		}
	}
	
	if ([[_jsonKeyString objectAtIndex:ProductOptionNameDeliveryCharge] isEqualToString:_selectFindKey]
		|| [[_jsonKeyString objectAtIndex:ProductOptionNameDeliveryTypeOptions] isEqualToString:_selectFindKey])
	{
		[productOptions setArray:[[[_productOptionRawData objectForKey:_selectFindKey] objectAtIndex:0] objectForKey:@"option"]];
	}
	else
	{
		NSUInteger index = [[[_displayOptionDataArray objectAtIndex:_selectRow] objectForKey:@"idx"] intValue];
		NSArray *options = [_productOptionRawData objectForKey:_selectFindKey];
		
		if (options != nil && [options count] > 0)
		{
			for (NSDictionary *dic in options)
			{
				if ([[dic objectForKey:@"dispType"] isEqualToString:@"select"] && [[dic objectForKey:@"idx"] intValue] == index)
				{
					[productOptions setArray:[dic objectForKey:@"option"]];
					
					if ([productOptions count] > 0) [productOptions removeObjectAtIndex:0];
					
					break;
				}
			}
		}
	}
	
	_optionItemView = [[CPProductOptionItem alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) productOptionRawData:_productOptionRawData];
	[_optionItemView setDelegate:self];
	[_optionItemView setAlpha:0.0f];
	[self addSubview:_optionItemView];
	
	[UIView animateWithDuration:0.3f animations:^{
		[_optionItemView setAlpha:1.0f];
	}];
}

- (void)onClickProductChangedCount:(id)sender
{
	NSInteger senderTag = [sender tag];
	
	NSInteger buttonTag = buttonTag = senderTag % 100;
	NSInteger indexPathRow = (senderTag - TAG_CELL_DEFAULT_INPUTFIELD - buttonTag) / 10000;
	NSInteger textFieldTag = TAG_CELL_DEFAULT_INPUTFIELD + (indexPathRow * 10000);
	
	UITextField *textField = (UITextField *)[[sender superview] viewWithTag:textFieldTag];
	
	if (textField) {
		int itemCount = [textField.text intValue];
		
		if (buttonTag == 1) {
			itemCount--;
		} else {
			itemCount++;
		}
		
        if (itemCount == 0 || itemCount > 999) {
            return;
        }
		
        [self startLoadingAnimation];
        
		NSString *findKey = nil;
		NSArray *sendOptionArray = nil;
		NSMutableDictionary *option = [[NSMutableDictionary alloc] init];
		NSDictionary *sendOptionDic = nil;
		
		if ((findKey = [[_displayOptionDataArray objectAtIndex:indexPathRow] objectForKey:@"findKey"]))
		{
			[option setObject:[NSNumber numberWithInt:itemCount] forKey:@"cnt"];
			[option setObject:[[_displayOptionDataArray objectAtIndex:indexPathRow] objectForKey:@"idx"] ? [[_displayOptionDataArray objectAtIndex:indexPathRow] objectForKey:@"idx"] : @"" forKey:@"idx"];
			
			sendOptionArray = [NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[NSArray arrayWithObject:option] forKey:@"option"]];
			sendOptionDic = [NSDictionary dictionaryWithObjectsAndKeys:[APP_VERSION stringByReplacingOccurrencesOfString:@"." withString:@""], @"version", sendOptionArray, findKey, nil];
		}
		else
		{
			[option setObject:[NSNumber numberWithInt:itemCount] forKey:@"optionCnt"];
			[option setObject:[APP_VERSION stringByReplacingOccurrencesOfString:@"." withString:@""] forKey:@"version"];
		}
		
		SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
		[self executeScript:[SET_SCRIPT stringByAppendingFormat:@"(%@)", [jsonWriter stringWithObject:findKey ? sendOptionDic : option]]];
		[self poll:GET_SCRIPT];
        
        //AccessLog - 옵션서랍 - 수량증가/감소
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"MPG0104"];
	}
}

- (void)onClickDeleteOptions:(id)sender
{
	NSArray *sendOptionArray;
	NSDictionary *sendOptionDic;
	NSMutableDictionary *option = [[NSMutableDictionary alloc] init];
	
	[option setObject:[[_displayOptionDataArray objectAtIndex:[(UIButton *)sender tag]] objectForKey:@"idx"] ? [[_displayOptionDataArray objectAtIndex:[(UIButton *)sender tag]] objectForKey:@"idx"] : @"" forKey:@"idx"];
	
	sendOptionArray = [NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[NSArray arrayWithObject:option] forKey:@"option"]];
	sendOptionDic = [NSDictionary dictionaryWithObjectsAndKeys:[APP_VERSION stringByReplacingOccurrencesOfString:@"." withString:@""], @"version", sendOptionArray, @"deleteOptions", nil];
	
	SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
	[self executeScript:[SET_SCRIPT stringByAppendingFormat:@"(%@)", [jsonWriter stringWithObject:sendOptionDic]]];
	[self poll:GET_SCRIPT];
    
    //AccessLog - 옵션서랍 - 옵션삭제
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"MPG0105"];
}

- (void)onClickDeleteAddPrdOptions:(id)sender
{
	NSArray *sendOptionArray;
	NSDictionary *sendOptionDic;
	NSMutableDictionary *option = [[NSMutableDictionary alloc] init];
	
	[option setObject:[[_displayOptionDataArray objectAtIndex:[(UIButton *)sender tag]] objectForKey:@"idx"] ? [[_displayOptionDataArray objectAtIndex:[(UIButton *)sender tag]] objectForKey:@"idx"] : @"" forKey:@"idx"];
	
	sendOptionArray = [NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[NSArray arrayWithObject:option] forKey:@"option"]];
	sendOptionDic = [NSDictionary dictionaryWithObjectsAndKeys:[APP_VERSION stringByReplacingOccurrencesOfString:@"." withString:@""], @"version", sendOptionArray, @"deleteAddPrdOptions", nil];
	
	SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
	[self executeScript:[SET_SCRIPT stringByAppendingFormat:@"(%@)", [jsonWriter stringWithObject:sendOptionDic]]];
	[self poll:GET_SCRIPT];
    
    //AccessLog - 옵션서랍 - 옵션삭제
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"MPG0105"];
}

- (void)onClickInputStringTextButton:(id)sender
{
	UIButton *btn = (UIButton *)sender;
	NSInteger tag = [btn tag] - 1000;
	
	UITextField *textField = (UITextField *)[btn.superview viewWithTag:tag];

    if (textField) {
        [self openKeyboard:textField];
    }
}

- (void)onClickInputNumberTextButton:(id)sender
{
	UIButton *btn = (UIButton *)sender;
	NSInteger senderTag = [sender tag];
	
	NSInteger buttonTag = buttonTag = senderTag % 100;
	NSInteger indexPathRow = (senderTag - TAG_CELL_DEFAULT_INPUTFIELD - buttonTag) / 10000;
	NSInteger textFieldTag = TAG_CELL_DEFAULT_INPUTFIELD + (indexPathRow * 10000);

	UITextField *textField = (UITextField *)[btn.superview viewWithTag:textFieldTag];
	if (textField) [self openKeyboard:textField];
}

- (void)onClickInputTextConfirm:(id)sender
{
	if (_writeTextField) {
		SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
		NSMutableDictionary *option = [[NSMutableDictionary alloc] init];
		NSDictionary *sendOptionDic = nil, *optionCount = nil;
		NSArray *optionArray = nil, *sendOptionArray = nil;
		NSString *jsonSendString = nil;

		if (_writeTextField && _writeTextField.keyboardType != UIKeyboardTypeNumberPad)
		{
			_writeTextField.text = _inputField.text;
			
			NSInteger indexPathRow = _writeTextField.tag;
			
			[option setObject:[[_displayOptionDataArray objectAtIndex:indexPathRow] objectForKey:@"idx"] forKey:@"idx"];
			[option setObject:[[_displayOptionDataArray objectAtIndex:indexPathRow] objectForKey:@"dispType"] forKey:@"dispType"];
			[option setObject:[_writeTextField.text trim] forKey:@"value"];
			
			optionArray = [NSArray arrayWithObject:option];
			NSDictionary *optionText = [NSDictionary dictionaryWithObject:optionArray forKey:@"option"];
			sendOptionArray = [NSArray arrayWithObject:optionText];
			
			sendOptionDic = [NSDictionary dictionaryWithObject:sendOptionArray forKey:@"selectOptions"];
			
			jsonSendString = [jsonWriter stringWithObject:sendOptionDic];
		}
		else if (_writeTextField && _writeTextField.keyboardType == UIKeyboardTypeNumberPad)
		{
			_writeTextField.text = _inputField.text;
			if ([_writeTextField.text length] == 0 || [_writeTextField.text intValue] == 0)
			{
				_writeTextField.text = @"1";
			}
			
			NSInteger indexPathRow = ((_writeTextField.tag - TAG_CELL_DEFAULT_INPUTFIELD) / 10000);
			NSString *findKey = [[_displayOptionDataArray objectAtIndex:indexPathRow] objectForKey:@"findKey"];
			if (findKey)
			{
				[option setObject:[[_displayOptionDataArray objectAtIndex:indexPathRow] objectForKey:@"idx"] forKey:@"idx"];
				[option setObject:_writeTextField.text forKey:@"cnt"];
				
				optionArray = [NSArray arrayWithObject:option];
				optionCount = [NSDictionary dictionaryWithObject:optionArray forKey:@"option"];
				sendOptionArray = [NSArray arrayWithObject:optionCount];
				sendOptionDic = [NSDictionary dictionaryWithObjectsAndKeys:[APP_VERSION stringByReplacingOccurrencesOfString:@"." withString:@""], @"version", sendOptionArray, findKey, nil];
			}
			else
			{
				[option setObject:[NSNumber numberWithInt:[_writeTextField.text intValue]] forKey:@"optionCnt"];
				[option setObject:[APP_VERSION stringByReplacingOccurrencesOfString:@"." withString:@""] forKey:@"version"];
			}
			
			jsonSendString = [jsonWriter stringWithObject:findKey ? sendOptionDic : option];
		}
		
		[self executeScript:[SET_SCRIPT stringByAppendingFormat:@"(%@)", jsonSendString]];
		[self poll:GET_SCRIPT];
	}
	
	[self onClickInputTextCancel:nil];
}

- (void)onClickInputTextCancel:(id)sender
{
	[_inputField resignFirstResponder];
}

#pragma mark - open & close

- (void)openDrawer
{
	CGRect bottomViewFrame = CGRectZero, viewFrame = CGRectZero;
	CGRect optionViewFrame = CGRectZero, productInfoFrame = CGRectZero;
	CGRect optionTableViewFrame = CGRectZero;

	[_drawerButton setImage:[UIImage imageNamed:@"option_down_nor.png"] forState:UIControlStateNormal];
    [_optionBarButton addTarget:self action:@selector(closeDrawer) forControlEvents:UIControlEventTouchUpInside];
	
	_startFrame = self.frame;
	_startBottomViewFrame = _bottomView.frame;
	
	CGFloat navigationHeight = [[UIScreen mainScreen] bounds].size.height - CGRectGetMaxY(_originalBottomViewRect);
	CGFloat viewFrameOffset = _openMinimumHeight - _topButtonHeight - navigationHeight;
	
	bottomViewFrame = CGRectMake(_bottomView.frame.origin.x,
								 CGRectGetMaxY(self.frame),
								 _bottomView.frame.size.width,
								 _bottomView.frame.size.height);
	
	viewFrame = CGRectMake(0,
						   viewFrameOffset,
						   self.frame.size.width,
						   _openMinimumHeight + _topButtonHeight + navigationHeight);
	
	optionViewFrame = CGRectMake(_optionView.frame.origin.x,
								 _topButtonHeight,
								 _optionView.frame.size.width,
								 viewFrame.size.height - _topButtonHeight);
	
	productInfoFrame = CGRectMake(_productInfoView.frame.origin.x,
								  optionViewFrame.size.height - _productInfoView.frame.size.height,
								  _productInfoView.frame.size.width,
								  _productInfoView.frame.size.height);
	
	optionTableViewFrame = CGRectMake(_optionTableView.frame.origin.x,
									  _optionTableView.frame.origin.y,
									  _optionTableView.frame.size.width,
									  productInfoFrame.origin.y-10);
	
	if (!CGRectEqualToRect(bottomViewFrame, CGRectZero) && !CGRectEqualToRect(viewFrame, CGRectZero))
	{
		[UIView animateWithDuration:0.3f animations:^{
			[_bottomView setFrame:bottomViewFrame];
			[self setFrame:viewFrame];
			[_optionView setFrame:optionViewFrame];
			[_productInfoView setFrame:productInfoFrame];
			[_optionTableView setFrame:optionTableViewFrame];
			[_optionTableView setScrollEnabled:(_optionTableView.frame.size.height < _optionTableView.contentSize.height ? YES : NO)];
		} completion:^(BOOL finished) {
			_isProductOptionOpen = YES;
			
			//bottomView frame조정 (화면을 내릴때 바텀뷰가 올라오게 되는데, 이때 내리는 속도에 맞춰 정확히 올려줘야하기때문에 재조정해준다.)
			CGFloat distance = self.frame.origin.y - _originalViewRect.origin.y;
			
			CGFloat bottomViewOffset = _originalBottomViewRect.origin.y - (distance * _scrollingKoef);
			_bottomView.frame = CGRectMake(_bottomView.frame.origin.x,
										   bottomViewOffset,
										   _bottomView.frame.size.width,
										   _bottomView.frame.size.height);

			
			[self executeScript:[NSString stringWithFormat:@"%@()", OPEN_SCRIPT]];
			[self performSelector:@selector(poll:) withObject:INIT_SCRIPT afterDelay:ANIMATION_DURATION];
		}];
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if (!_isProductOptionOpen) {
        //AccessLog - 옵션서랍 열기/닫기
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"MPG0000"];
    }
    
}

- (void)closeDrawer
{
	CGRect bottomViewFrame = CGRectZero, viewFrame = CGRectZero;
	CGRect optionViewFrame = CGRectZero, productInfoFrame = CGRectZero;
	CGRect optionTableViewFrame = CGRectZero;
	
	[_drawerButton setImage:[UIImage imageNamed:@"option_up_nor.png"] forState:UIControlStateNormal];
    [_optionBarButton addTarget:self action:@selector(openDrawer) forControlEvents:UIControlEventTouchUpInside];

	bottomViewFrame = _originalBottomViewRect;
	viewFrame = _originalViewRect;
	optionViewFrame = CGRectMake(_optionView.frame.origin.x,
								 _topButtonHeight,
								 _optionView.frame.size.width,
								 viewFrame.size.height - _topButtonHeight);
	
	productInfoFrame = CGRectMake(_productInfoView.frame.origin.x,
								  3.f,
								  _productInfoView.frame.size.width,
								  _productInfoView.frame.size.height);
	
	optionTableViewFrame = CGRectMake(_optionTableView.frame.origin.x,
									  _optionTableView.frame.origin.y,
									  _optionTableView.frame.size.width,
									  0.f);

	if (!CGRectEqualToRect(bottomViewFrame, CGRectZero) && !CGRectEqualToRect(viewFrame, CGRectZero))
	{
		[UIView animateWithDuration:0.3f animations:^{
			[_bottomView setFrame:bottomViewFrame];
			[self setFrame:viewFrame];
			[_optionView setFrame:optionViewFrame];
			[_productInfoView setFrame:productInfoFrame];
			[_optionTableView setFrame:optionTableViewFrame];
		} completion:^(BOOL finished) {
			_isProductOptionOpen = NO;
			
			[NSObject cancelPreviousPerformRequestsWithTarget:self];
			[self executeScript:[NSString stringWithFormat:@"%@()", CLOSE_SCRIPT]];
			
//			[_indicator stopAnimating];
            [self stopLoadingAnimation];
		}];
	}

	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_isProductOptionOpen) {
        //AccessLog - 옵션서랍 열기/닫기
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"MPG0000"];
    }
}

#pragma mark - UIPanGestureRecognizer

- (void)didPan:(UIPanGestureRecognizer *)recognizer
{
	//아이템 옵션창이 열려있으면 리턴.
    if (_optionItemView) {
        return;
    }
	
	if ([recognizer state] == UIGestureRecognizerStateChanged || [recognizer state] == UIGestureRecognizerStateBegan)
	{
		if ([recognizer state] == UIGestureRecognizerStateBegan)
		{
			if (isShowGuideView) {
				[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(destoryProductOptionGuideView:) object:_guideView];
				[self destoryProductOptionGuideView:_guideView];
			}
			
			_startFrame = self.frame;
			_startBottomViewFrame = _bottomView.frame;
		}

		//변경되는 높이값 계산
		CGPoint currentPoint = [recognizer translationInView:self];
		CGFloat y = currentPoint.y;

		//변화되는 높이에 따른 뷰 프레임 수정
		[_bottomView setFrame:CGRectMake(_startBottomViewFrame.origin.x,
										 _startBottomViewFrame.origin.y - (y * _scrollingKoef),
										 _startBottomViewFrame.size.width,
										 _startBottomViewFrame.size.height)];
		
		[self setFrame:CGRectMake(_startFrame.origin.x,
								  _startFrame.origin.y + y,
								  _startFrame.size.width,
								  _startFrame.size.height - y)];

		[_optionView setFrame:CGRectMake(_optionView.frame.origin.x,
										 _optionView.frame.origin.y,
										 _optionView.frame.size.width,
										 self.frame.size.height - _optionView.frame.origin.y)];
		
		//_productInfoView 처리
		if (self.frame.size.height - _topButtonHeight - 3.f > _productInfoView.frame.size.height) {
			[_productInfoView setFrame:CGRectMake(_productInfoView.frame.origin.x,
												  self.frame.size.height - _productInfoView.frame.size.height - _topButtonHeight,
												  _productInfoView.frame.size.width,
												  _productInfoView.frame.size.height)];
		} else {
			[_productInfoView setFrame:CGRectMake(_productInfoView.frame.origin.x,
												  3.f,
												  _productInfoView.frame.size.width,
												  _productInfoView.frame.size.height)];
		}
		
		[_optionTableView setFrame:CGRectMake(_optionTableView.frame.origin.x,
											  _optionTableView.frame.origin.y,
											  _optionTableView.frame.size.width,
											  _productInfoView.frame.origin.y-2)];
		[_optionTableView setScrollEnabled:(_optionTableView.frame.size.height < _optionTableView.contentSize.height ? YES : NO)];
		
		//_parentView의 높이보다 높게 올라갈경 우 처리.
		if (self.frame.origin.y < 0)
		{
			if (CGRectEqualToRect(_prevBottomViewFrame, CGRectZero)) _prevBottomViewFrame = _bottomView.frame;
			
			[_bottomView setFrame:CGRectMake(_bottomView.frame.origin.x,
											 _prevBottomViewFrame.origin.y,
											 _bottomView.frame.size.width,
											 _bottomView.frame.size.height)];
			
			[self setFrame:CGRectMake(self.frame.origin.x,
									  0,
									  self.frame.size.width,
									  _parentView.frame.size.height)];
			
			[_optionView setFrame:CGRectMake(_optionView.frame.origin.x,
											 _optionView.frame.origin.y,
											 _optionView.frame.size.width,
											 self.frame.size.height - _optionView.frame.origin.y)];
			
			[_productInfoView setFrame:CGRectMake(_productInfoView.frame.origin.x,
												  self.frame.size.height - _productInfoView.frame.size.height - _topButtonHeight,
												  _productInfoView.frame.size.width,
												  _productInfoView.frame.size.height)];
			
			[_optionTableView setFrame:CGRectMake(_optionTableView.frame.origin.x,
												  _optionTableView.frame.origin.y,
												  _optionTableView.frame.size.width,
												  _productInfoView.frame.origin.y-2.f)];
			[_optionTableView setScrollEnabled:(_optionTableView.frame.size.height < _optionTableView.contentSize.height ? YES : NO)];
			return;
		}

		_prevBottomViewFrame = CGRectZero;
		
		//_bottomView Y가 maximum Y 값보다 높을 때의 처리 || bottomView Y보다 아래로 내려갈때의 처리
		if (_bottomView.frame.origin.y < _originalBottomViewRect.origin.y ||
			self.frame.origin.y + _topButtonHeight > _originalBottomViewRect.origin.y)
		{
			[_bottomView setFrame:_originalBottomViewRect];
			[self setFrame:_originalViewRect];
			[_optionView setFrame:CGRectMake(_optionView.frame.origin.x,
											 _topButtonHeight,
											 _optionView.frame.size.width,
											 self.frame.size.height - _topButtonHeight)];
			
			[_optionTableView setFrame:CGRectMake(_optionTableView.frame.origin.x,
												  _optionTableView.frame.origin.y,
												  _optionTableView.frame.size.width,
												  0.f)];
		}
	}
	
	if ([recognizer state] == UIGestureRecognizerStateEnded || [recognizer state] == UIGestureRecognizerStateCancelled)
	{
		_startFrame = self.frame;
		_startBottomViewFrame = _bottomView.frame;
		
		if (_startFrame.size.height > (_openMinimumHeight / 2) && !_isProductOptionOpen)
		{
			[self openDrawer];
            
			return;
		}
		
		if (_startFrame.size.height < _openMinimumHeight)
		{
			[self closeDrawer];
		}
	}
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _displayOptionDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat topBottomMargin = 10.0f;
	
	NSDictionary *options = [_displayOptionDataArray objectAtIndex:indexPath.row];
	NSString *findKey = [options objectForKey:@"findKey"];
	NSString *title = [[_displayOptionDataArray objectAtIndex:indexPath.row] objectForKey:@"title"];
	NSString *displayType = [[_displayOptionDataArray objectAtIndex:indexPath.row] objectForKey:@"dispType"];
    NSInteger idx = [[[_displayOptionDataArray objectAtIndex:indexPath.row] objectForKey:@"idx"] integerValue];
    
    CGFloat rowHeight = 35;
    CGFloat extraHeight = 0;
    
    // 입력형은 비노출
    if ([@"input" isEqualToString:displayType]) {
        extraHeight = 23;
    }
    else {
        if ([@"select" isEqualToString:displayType]) {
            //선택형 옵션중 첫번째만 노출
            if (idx > 0) {
                rowHeight = 0;
            }
        }
        else if ([@"delivery" isEqualToString:findKey]) {
            rowHeight = 0;
        }
        else {
            if (findKey) {
                title = [NSString stringWithFormat:@"%@", [[_displayOptionDataArray objectAtIndex:indexPath.row] objectForKey:@"title"]];
            }
            
            CGSize labelSize = [Modules calculateStringAreaWithText:title font:[UIFont systemFontOfSize:13] lineBreakMode:NSLineBreakByWordWrapping width:tableView.frame.size.width - topBottomMargin * 2.0f height:0.0f];
            
            rowHeight += labelSize.height+15;
        }
    }
//    NSLog(@"heightForRowAtIndexPath: %i : %f", indexPath.row, rowHeight);
    return rowHeight + extraHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"productOptionCell";
	
//	NSString *findKey = [[_displayOptionDataArray objectAtIndex:indexPath.row] objectForKey:@"findKey"];
	NSString *displayType = [[_displayOptionDataArray objectAtIndex:indexPath.row] objectForKey:@"dispType"];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		[cell setAccessoryView:nil];
	}
	
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }

	if ([@"select" isEqualToString:displayType]) { //선택형
        //선택형 옵션중 첫번째만 노출
        NSInteger idx = [[[_displayOptionDataArray objectAtIndex:indexPath.row] objectForKey:@"idx"] integerValue];
        
        if (idx == 0) {
            [cell.contentView setBackgroundColor:UIColorFromRGB(0xeeeeee)];
            
            UIView *selectView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_optionTableView.frame)-31.5f, 32)];
            [selectView setBackgroundColor:UIColorFromRGB(0xffffff)];
            [selectView.layer setBorderWidth:1];
            [selectView.layer setBorderColor:UIColorFromRGB(0xafb0c2).CGColor];
            [cell.contentView addSubview:selectView];
            
            NSMutableArray *selectedTextArray = [NSMutableArray array];
            for (NSDictionary *option in _displayOptionDataArray) {
                if ([@"select" isEqualToString:option[@"dispType"]] && !nilCheck(option[@"selectedText"])) {
                    [selectedTextArray addObject:option[@"selectedText"]];
                }
            }
            
            NSString *selectedText = nil;
            if (selectedTextArray.count > 0) {
                selectedText = [selectedTextArray componentsJoinedByString:@" / "];
            }
            
            UILabel *selectLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(_optionTableView.frame)-52, 32)];
            [selectLabel setText:(nilCheck(selectedText) ? @"옵션을 선택해 주세요" : selectedText)];
            [selectLabel setTextColor:UIColorFromRGB(0x868ba8)];
            [selectLabel setFont:[UIFont systemFontOfSize:13]];
            [selectView addSubview:selectLabel];
            
            UIButton *arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [arrowButton setFrame:CGRectMake(CGRectGetWidth(_optionTableView.frame)-32, 0, 32, 32)];
            [arrowButton setImage:[UIImage imageNamed:@"option_btn_select_off.png"] forState:UIControlStateNormal];
            [arrowButton addTarget:self action:@selector(onClickKindOfSelectOption:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:arrowButton];
            
            UIButton *blankButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [blankButton setFrame:selectView.frame];
            [blankButton setBackgroundColor:[UIColor clearColor]];
            [blankButton addTarget:self action:@selector(onClickKindOfSelectOption:) forControlEvents:UIControlEventTouchUpInside];
            [blankButton setTag:0];
            [cell.contentView addSubview:blankButton];
        }
	}
    else if ([@"input" isEqualToString:displayType]) { //입력형
        [cell.contentView setBackgroundColor:UIColorFromRGB(0xeeeeee)];
        
        //옵션 타이틀
        NSString *name = _displayOptionDataArray[indexPath.row][@"label"];
        
        CGSize nameSize = [name sizeWithFont:[UIFont systemFontOfSize:14]];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, nameSize.width, 20)];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setFont:[UIFont systemFontOfSize:14]];
        [nameLabel setText:name];
        [nameLabel setTextColor:UIColorFromRGB(0x333333)];
        [cell.contentView addSubview:nameLabel];
        
        NSString *value = _displayOptionDataArray[indexPath.row][@"value"];
        
        UIView *leftInsetView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 32)];
        [leftInsetView setBackgroundColor:[UIColor clearColor]];
        
        NSAttributedString *placeholderAttribute = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"ProductOptionInputHint", nil)
                                                                                   attributes:@{
                                                                                                NSForegroundColorAttributeName: UIColorFromRGB(0x868ba8), NSFontAttributeName: [UIFont systemFontOfSize:13] }];
        
        UITextField *inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(_optionTableView.frame), 32)];
        [inputTextField setDelegate:self];
        [inputTextField setLeftView:leftInsetView];
        [inputTextField setReturnKeyType:UIReturnKeyDone];
        [inputTextField setBorderStyle:UITextBorderStyleNone];
        [inputTextField setTextColor:UIColorFromRGB(0x868bab)];
        [inputTextField setFont:[UIFont systemFontOfSize:13]];
        [inputTextField setBackgroundColor:[UIColor whiteColor]];
        [inputTextField setLeftViewMode:UITextFieldViewModeAlways];
        [inputTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [inputTextField.layer setBorderColor:UIColorFromRGB(0xafb0c2).CGColor];
        [inputTextField.layer setBorderWidth:1.0f];
        [inputTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [inputTextField setAttributedPlaceholder:placeholderAttribute];
        [inputTextField setText:value];
        [inputTextField setTag:indexPath.row];
        [cell.contentView addSubview:inputTextField];
        
        UIButton *inputButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [inputButton setFrame:inputTextField.bounds];
        [inputButton setTag:indexPath.row + 1000];
        [inputButton setBackgroundColor:[UIColor clearColor]];
        [inputButton addTarget:self action:@selector(onClickInputStringTextButton:) forControlEvents:UIControlEventTouchUpInside];
        [inputButton setAccessibilityLabel:@"" Hint:@""];
        [inputTextField addSubview:inputButton];
	}
	else {
        [cell.contentView setBackgroundColor:UIColorFromRGB(0xf7f8fb)];
        
        NSString *findKey = [[_displayOptionDataArray objectAtIndex:indexPath.row] objectForKey:@"findKey"];
        NSString *title = nil;
		NSString *price = [Modules numberFormatComma:[[_displayOptionDataArray objectAtIndex:indexPath.row] objectForKey:@"price"] appendUnit:@"원"];
		
        if (findKey) {
            title = [NSString stringWithFormat:@"%@", [[_displayOptionDataArray objectAtIndex:indexPath.row] objectForKey:@"title"]];
        }
        else {
            title = [[_displayOptionDataArray objectAtIndex:indexPath.row] objectForKey:@"title"];
        }
		
        CGFloat buttonMargin = 5.0f;
        CGFloat margin = 10.0f;

        //라인
		UIImage *separatorLine = [UIImage imageNamed:@"option_table_line_b.png"];
        UIView *separatorLineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, separatorLine.size.height)];
		[separatorLineView setBackgroundColor:[UIColor colorWithPatternImage:separatorLine]];
		[separatorLineView setOpaque:NO];
		[separatorLineView setHidden:YES];
        [cell.contentView addSubview:separatorLineView];
		
        //선택된 옵션
        CGSize labelSize = [Modules calculateStringAreaWithText:title font:[UIFont systemFontOfSize:13] lineBreakMode:NSLineBreakByWordWrapping width:tableView.frame.size.width - margin * 2.0f height:0.0f];
        NSLog(@"labelSize: %@", NSStringFromCGSize(labelSize));
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(margin, 5.0f, tableView.frame.size.width - margin * 2.0f, labelSize.height)];
		[label setFont:[UIFont systemFontOfSize:13]];
        [label setBackgroundColor:[UIColor clearColor]];
		[label setTextColor:UIColorFromRGB(0x5d5fd6)];
		[label setText:title];
		[label setNumberOfLines:0];
        [cell.contentView addSubview:label];
		
		NSInteger tagWithRow = TAG_CELL_DEFAULT_INPUTFIELD + (indexPath.row * 10000);
		
        //마이너스
        UIImage *minusImageNor = [UIImage imageNamed:@"option_btn_minus_nor.png"];
        UIImage *minusImageHil = [UIImage imageNamed:@"option_btn_minus_pre.png"];
        
        UIButton *minusButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[minusButton setImage:minusImageNor forState:UIControlStateNormal];
		[minusButton setImage:minusImageHil forState:UIControlStateHighlighted];
		[minusButton setFrame:CGRectMake(margin,
										 label.frame.origin.y + label.frame.size.height + buttonMargin,
										 minusImageNor.size.width,
										 minusImageNor.size.height)];
		[minusButton addTarget:self action:@selector(onClickProductChangedCount:) forControlEvents:UIControlEventTouchUpInside];
		[minusButton setTag:tagWithRow + 1];
		[minusButton setAccessibilityLabel:@"수량감소" Hint:@"수량을 한개 뺍니다"];
        [cell.contentView addSubview:minusButton];
		
        //수량
        UIImage *optionInputImageNor = [UIImage imageNamed:@"option_img_count_bg.png"];
        UITextField *inputField = [[UITextField alloc] initWithFrame:CGRectZero];
		[inputField setBackground:optionInputImageNor];
		[inputField setText:[[_displayOptionDataArray objectAtIndex:indexPath.row] objectForKey:@"cnt"]];
		[inputField setKeyboardType:UIKeyboardTypeNumberPad];
		[inputField setTextAlignment:NSTextAlignmentCenter];
		[inputField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[inputField setTextColor:UIColorFromRGB(0x333333)];
		[inputField setFont:[UIFont systemFontOfSize:17]];
		[inputField setFrame:CGRectMake(CGRectGetMaxX(minusButton.frame),
										label.frame.origin.y + label.frame.size.height + buttonMargin,
										optionInputImageNor.size.width,
										optionInputImageNor.size.height)];
		[inputField setDelegate:nil];
		[inputField setEnabled:YES];
		[inputField setTag:tagWithRow];
		[inputField setUserInteractionEnabled:NO];
        [cell.contentView addSubview:inputField];
		
        UIButton *inputButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[inputButton setFrame:inputField.frame];
		[inputButton setBackgroundColor:[UIColor clearColor]];
		[inputButton setTag:tagWithRow + 3];
		[inputButton addTarget:self action:@selector(onClickInputNumberTextButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:inputButton];
		
        //플러스
        UIImage *plusImageNor = [UIImage imageNamed:@"option_btn_plus_nor.png"];
        UIImage *plusImageHil = [UIImage imageNamed:@"option_btn_plus_pre.png"];
        
        UIButton *plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[plusButton setImage:plusImageNor forState:UIControlStateNormal];
		[plusButton setImage:plusImageHil forState:UIControlStateHighlighted];
		[plusButton setFrame:CGRectMake(CGRectGetMaxX(inputField.frame),
										label.frame.origin.y + label.frame.size.height + buttonMargin,
										plusImageNor.size.width,
										plusImageNor.size.height)];
		[plusButton addTarget:self action:@selector(onClickProductChangedCount:) forControlEvents:UIControlEventTouchUpInside];
		[plusButton setTag:tagWithRow + 2];
		[plusButton setAccessibilityLabel:@"수량추가" Hint:@"수량을 한개 더합니다"];
        [cell.contentView addSubview:plusButton];
        
        UIImage *deleteImageNor = [UIImage imageNamed:@"option_btn_delete_nor.png"];
        UIImage *deleteImageHil = [UIImage imageNamed:@"option_btn_delete_pre.png"];
        
        //가격
		UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[priceLabel setFont:[UIFont systemFontOfSize:20]];
		[priceLabel setTextColor:UIColorFromRGB(0x333333)];
		[priceLabel setText:price];
		[priceLabel setBackgroundColor:[UIColor clearColor]];
		[priceLabel setNumberOfLines:1];
		[priceLabel sizeToFit];
		[priceLabel setFrame:CGRectMake(tableView.frame.size.width - deleteImageNor.size.width - buttonMargin - margin - priceLabel.frame.size.width,
										label.frame.origin.y + label.frame.size.height + buttonMargin,
										priceLabel.frame.size.width,
										plusButton.frame.size.height)];
		[priceLabel setHidden:YES];
        [cell.contentView addSubview:priceLabel];
		
		if (findKey) {

            UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[deleteButton setImage:deleteImageNor forState:UIControlStateNormal];
			[deleteButton setImage:deleteImageHil forState:UIControlStateHighlighted];
			[deleteButton setFrame:CGRectMake(priceLabel.frame.origin.x + priceLabel.frame.size.width + buttonMargin,
											  label.frame.origin.y + label.frame.size.height + buttonMargin,
											  deleteImageNor.size.width, 
											  deleteImageNor.size.height)];
			[deleteButton setTag:indexPath.row];
			[deleteButton setAccessibilityLabel:@"옵션삭제" Hint:@"선택한 옵션을 삭제합니다"];
            [cell.contentView addSubview:deleteButton];
			
			if ([findKey isEqualToString:[_jsonKeyString objectAtIndex:ProductOptionNameSelectedOptions]]) {
				if ([self respondsToSelector:@selector(onClickDeleteOptions:)]) {
					[deleteButton addTarget:self action:@selector(onClickDeleteOptions:) forControlEvents:UIControlEventTouchUpInside];
				}
			}
			
			if ([findKey isEqualToString:[_jsonKeyString objectAtIndex:ProductOptionNameSelectedAddPrdOptions]])
			{
				if ([self respondsToSelector:@selector(onClickDeleteAddPrdOptions:)]) {
					[deleteButton addTarget:self action:@selector(onClickDeleteAddPrdOptions:) forControlEvents:UIControlEventTouchUpInside];
				}
			}
			
			[separatorLineView setOpaque:NO];
			[separatorLineView setHidden:NO];
			[priceLabel setHidden:NO];
			
            if ([findKey isEqualToString:[_jsonKeyString objectAtIndex:ProductOptionNameSelectedAddPrdOptions]]) {
                [label setTextColor:[UIColor blackColor]];
            }
		}
	}
	
	return cell;
}

#pragma mark - CPProductOptionItem Delegate

- (void)optionItem:(CPProductOptionItem *)optionItem textFieldShouldBeginEditing:(BOOL)isEdit
{
	//keyboard가 나타나려고하면 optionItemView를 app.window로 붙여준다.
	CGRect screenFrame = [[UIScreen mainScreen] bounds];
	
	if (_optionItemView) {
		[_optionItemView removeFromSuperview];
		
		_optionItemView.frame = CGRectMake(_optionItemView.frame.origin.x,
										   screenFrame.size.height - _optionItemView.frame.size.height,
										   _optionItemView.frame.size.width,
										   _optionItemView.frame.size.height);
        
		AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		[app.window addSubview:_optionItemView];
	}
}

- (void)optionItem:(CPProductOptionItem *)optionItem didSelectOptionItem:(NSDictionary *)items selectedRow:(NSInteger)selectedRow isConfirm:(BOOL)isConfirm
{
    _selectRow = selectedRow;
    
	[self customAlertSelectedProductOption:items];
    
    if (isConfirm) {
        [self optionItemDidCancel:optionItem];
    }
}

- (void)optionItem:(CPProductOptionItem *)optionItem textFieldShouldReturn:(NSString *)text selectedRow:(NSInteger)selectedRow
{
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    NSMutableDictionary *option = [[NSMutableDictionary alloc] init];
    NSDictionary *sendOptionDic = nil;
//    NSDictionary *optionCount = nil;
    NSArray *optionArray = nil;
    NSArray *sendOptionArray = nil;
    NSString *jsonSendString = nil;
    
    if (text) {
        NSInteger indexPathRow = selectedRow;
        
        [option setObject:[[_displayOptionDataArray objectAtIndex:indexPathRow] objectForKey:@"idx"] forKey:@"idx"];
        [option setObject:[[_displayOptionDataArray objectAtIndex:indexPathRow] objectForKey:@"dispType"] forKey:@"dispType"];
        [option setObject:text forKey:@"value"];
        
        optionArray = [NSArray arrayWithObject:option];
        NSDictionary *optionText = [NSDictionary dictionaryWithObject:optionArray forKey:@"option"];
        sendOptionArray = [NSArray arrayWithObject:optionText];
        
        sendOptionDic = [NSDictionary dictionaryWithObject:sendOptionArray forKey:@"selectOptions"];
        
        jsonSendString = [jsonWriter stringWithObject:sendOptionDic];
    }
//    else if (_writeTextField && _writeTextField.keyboardType == UIKeyboardTypeNumberPad)
//    {
//        _writeTextField.text = _inputField.text;
//        if ([_writeTextField.text length] == 0 || [_writeTextField.text intValue] == 0)
//        {
//            _writeTextField.text = @"1";
//        }
//        
//        int indexPathRow = ((_writeTextField.tag - TAG_CELL_DEFAULT_INPUTFIELD) / 10000);
//        NSString *findKey = [[_displayOptionDataArray objectAtIndex:indexPathRow] objectForKey:@"findKey"];
//        if (findKey)
//        {
//            [option setObject:[[_displayOptionDataArray objectAtIndex:indexPathRow] objectForKey:@"idx"] forKey:@"idx"];
//            [option setObject:_writeTextField.text forKey:@"cnt"];
//            
//            optionArray = [NSArray arrayWithObject:option];
//            optionCount = [NSDictionary dictionaryWithObject:optionArray forKey:@"option"];
//            sendOptionArray = [NSArray arrayWithObject:optionCount];
//            sendOptionDic = [NSDictionary dictionaryWithObjectsAndKeys:[APP_VERSION stringByReplacingOccurrencesOfString:@"." withString:@""], @"version", sendOptionArray, findKey, nil];
//        }
//        else
//        {
//            [option setObject:[NSNumber numberWithInt:[_writeTextField.text intValue]] forKey:@"optionCnt"];
//            [option setObject:[APP_VERSION stringByReplacingOccurrencesOfString:@"." withString:@""] forKey:@"version"];
//        }
//        
//        jsonSendString = [jsonWriter stringWithObject:findKey ? sendOptionDic : option];
//    }
    
    [self executeScript:[SET_SCRIPT stringByAppendingFormat:@"(%@)", jsonSendString]];
//    [self poll:GET_SCRIPT];
    [self pollFromOptionItem:GET_SCRIPT];
    
    //AccessLog - 옵션서랍 - 옵션선택(입력형)
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"MPG0102"];
}

- (void)optionItemDidCancel:(CPProductOptionItem *)optionItem
{
	if (optionItem) {
		[UIView animateWithDuration:0.3f animations:^{
			[optionItem setAlpha:0.0f];
		} completion:^(BOOL finished) {
			[self removeOptionItemView];
		}];
	}
}

- (void)didTouchCloseDrawerButton
{
    [self removeOptionItemView];
    
    [self closeDrawer];
}

- (void)didTouchOpenDrawerButton
{
    [self openDrawer];
}

#pragma mark - keyboard notification mothods..

- (void)keyboardWillShow:(NSNotification *)noti
{
	CGRect keyboardFrame = [[[noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	CGRect screenFrame = [[UIScreen mainScreen] bounds];
	CGFloat statusbarHeight = 20.f;
	CGRect optionItemViewFrame = CGRectZero;
	
	_keyboardHeight = keyboardFrame.size.height;

	if (_optionItemView) {
		optionItemViewFrame = CGRectMake(_optionItemView.frame.origin.x,
										 statusbarHeight,
										 _optionItemView.frame.size.width,
										 screenFrame.size.height - statusbarHeight - keyboardFrame.size.height);
	}
	
	[UIView animateWithDuration:0.25f animations:^(void) {
		if (_optionItemView) {
			[_optionItemView setFrame:optionItemViewFrame];
            [_optionItemView redrawTableContainerFrame:optionItemViewFrame];
		}
		
		if (_isSelectInputKeyboard) {
			CGRect keyboardViewFrame = _inputKeyboardView.frame;
			keyboardViewFrame.origin.y = _inputKeyboardBgView.frame.size.height - _keyboardHeight - _inputKeyboardView.frame.size.height;
			_inputKeyboardView.frame = keyboardViewFrame;
			
			[_inputKeyboardView setHidden:NO];
		}
	} completion:^(BOOL finished) {
		if (_optionItemView) {
			
		}
	}];
}

- (void)keyboardWillHide:(NSNotification *)noti {
	CGRect screenFrame = [[UIScreen mainScreen] bounds];
	CGRect optionItemViewFrame = CGRectZero;
	
	if (_optionItemView) {
		optionItemViewFrame = CGRectMake(_optionItemView.frame.origin.x,
										 (screenFrame.size.height - self.frame.size.height),
										 _optionItemView.frame.size.width,
										 self.frame.size.height);
	}
	
	[UIView animateWithDuration:0.25f animations:^(void) {
		if (_optionItemView) {
			[_optionItemView setFrame:optionItemViewFrame];
            [_optionItemView redrawTableContainerFrame:optionItemViewFrame];
		}
	} completion:^(BOOL finished) {
		if (_optionItemView) {
			//윈도우에서 옵션을 지워버리고, 셀프에 다시 붙인다.
			[_optionItemView removeFromSuperview];
			[_optionItemView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
			[self addSubview:_optionItemView];
		}
	}];
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	//
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (textField == _inputField) {
		_inputField.text = @"";
		[_inputKeyboardBgView removeFromSuperview];
		
		CGRect keyboardViewFrame = _inputKeyboardView.frame;
		keyboardViewFrame.origin.y = 1000.f;
		_inputKeyboardView.frame = keyboardViewFrame;
		
		[_inputKeyboardView setHidden:YES];
		
		_writeTextField = nil;
		_isSelectInputKeyboard = NO;
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSString *textFieldString = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
	if ([textField keyboardType] == UIKeyboardTypeNumberPad && ![textFieldString isMatchedByRegex:@"^[0-9]*$"])
	{
		if (textField.text.length > 0) [textField setText:[textField.text substringToIndex:textField.text.length - 1]];
		
		return NO;
	}
	
	if ([textFieldString isMatchedByRegex:@"[<>///!]"]) return NO;
	if (([textFieldString intValue] > [[_productOptionRawData objectForKey:@"maxCnt"] intValue]) && [textField keyboardType] == UIKeyboardTypeNumberPad) return NO;
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self onClickInputTextConfirm:nil];
	
	return YES;
}

#pragma mark - CPLoadingView

- (void)startLoadingAnimation
{
    [_optionView addSubview:loadingView];
    [loadingView setCenter:CGPointMake(_optionView.center.x, _optionView.center.y - 70.f)];
    [loadingView startAnimation];
}

- (void)stopLoadingAnimation
{
    [loadingView stopAnimation];
    [loadingView removeFromSuperview];
}

@end
