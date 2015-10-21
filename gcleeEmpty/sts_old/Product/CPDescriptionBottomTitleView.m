#import "CPDescriptionBottomTitleView.h"
#import "CPString+Formatter.h"
#import "AccessLog.h"

@interface CPDescriptionBottomTitleView ()
{
	NSString *_title;
    NSString *_totalCount;
	MoveTabType _type;
	
	UIView *_topLineView;
	UILabel *_titleLabel;
    UILabel *_totalCountLabel;
	UILabel *_moreLabel;
	UIImageView *_arrowView;
	UIView *_bottomLineView;
	UIButton *_moreButton;
	
	UIColor *_bgColor;
	UIColor *_titleColor;
    UIColor *_topLineColor;
	BOOL _isLine;
}

@end

@implementation CPDescriptionBottomTitleView

- (id)initWithFrame:(CGRect)frame
			  title:(NSString *)titleStr
         totalCount:(NSString *)totalCount
			   type:(MoveTabType)typeIndex
			bgColor:(UIColor *)bgColor
		 titleColor:(UIColor *)titleColor
       topLineColor:(UIColor *)topLineColor
       isBottomLine:(BOOL)isLine
{
	if (self = [super initWithFrame:frame])
	{
		if (titleStr) {
			_title = titleStr;
		}
        
        if (totalCount) {
            _totalCount = totalCount;
        }
		
		if (typeIndex) {
			_type = typeIndex;
		}
		
		if (bgColor) {
			_bgColor = bgColor;
		}
		
		if (titleColor) {
			_titleColor = titleColor;
		}
        
        if (topLineColor) {
            _topLineColor = topLineColor;
        }
		
		_isLine = isLine;
		
		[self initLayout];
	}
	return self;
}

- (void)initLayout
{
	self.backgroundColor = _bgColor;
	
	_topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
    _topLineView.backgroundColor = _topLineColor?_topLineColor:UIColorFromRGB(0xededed);
	[self addSubview:_topLineView];
	
	_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 1, 0, self.frame.size.height-1)];
	_titleLabel.backgroundColor = [UIColor clearColor];
	_titleLabel.font = [UIFont boldSystemFontOfSize:15.f];
	_titleLabel.textColor = _titleColor;
	_titleLabel.textAlignment = NSTextAlignmentLeft;
	_titleLabel.text = _title;
	[self addSubview:_titleLabel];
	
	[_titleLabel sizeToFitWithVersionHoldHeight];
    
    if (_totalCount != nil && _totalCount.length > 0) {
        NSString *totalCountStr = [NSString stringWithFormat:@"%@건", [_totalCount formatThousandComma]];
        if ([_totalCount integerValue] > 99999) totalCountStr = @"99,999+";
        
        CGSize totalCountStrSize = [totalCountStr sizeWithFont:[UIFont boldSystemFontOfSize:14]];
        
        _totalCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_titleLabel.frame)+6, 2, totalCountStrSize.width, self.frame.size.height-1)];
        _totalCountLabel.backgroundColor = [UIColor clearColor];
        _totalCountLabel.font = [UIFont boldSystemFontOfSize:14.f];
        _totalCountLabel.textColor = UIColorFromRGB(0x5460de);
        _totalCountLabel.textAlignment = NSTextAlignmentLeft;
        _totalCountLabel.text = totalCountStr;
        [self addSubview:_totalCountLabel];
    }

    if (_type != MoveTabTypeNone) {
        
        UIImage *imgArrow = [UIImage imageNamed:@"ic_pd_arrow_right_02.png"];
        _arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-10.f-imgArrow.size.width,
                                                                   (self.frame.size.height/2)-(imgArrow.size.height/2),
                                                                   imgArrow.size.width,
                                                                   imgArrow.size.height)];
        _arrowView.image = imgArrow;
        [self addSubview:_arrowView];
        
        _moreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _moreLabel.backgroundColor = [UIColor clearColor];
        _moreLabel.font = [UIFont systemFontOfSize:13.f];
        _moreLabel.textColor = UIColorFromRGB(0x283593);
        _moreLabel.textAlignment = NSTextAlignmentLeft;
        _moreLabel.text = @"더보기";
        [self addSubview:_moreLabel];
        
        [_moreLabel sizeToFitWithFloor];
        _moreLabel.frame = CGRectMake(_arrowView.frame.origin.x-5.f-_moreLabel.frame.size.width,
                                      (self.frame.size.height/2)-(_moreLabel.frame.size.height/2),
                                      _moreLabel.frame.size.width,
                                      _moreLabel.frame.size.height);
        
        CGFloat moreButtonWidth = _moreLabel.frame.size.width+5.f+5.f+_arrowView.frame.size.width+5.f;
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreButton.frame = CGRectMake(_moreLabel.frame.origin.x-5.f,
                                       _arrowView.center.y-15.f,
                                       moreButtonWidth,
                                       30.f);
        [_moreButton addTarget:self action:@selector(pressedMoreButton:) forControlEvents:UIControlEventTouchUpInside];
        //	[_moreButton setImage:[SHCommonLibrary imageWithColor:UIColorFromRGB(0x000000)
        //													width:moreButtonWidth
        //												   height:30.f]
        //				 forState:UIControlStateHighlighted];
        [self addSubview:_moreButton];
    }
	
	if (_isLine)
	{
		_bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1)];
		_bottomLineView.backgroundColor = UIColorFromRGB(0xededed);
		[self addSubview:_bottomLineView];
	}
}

#pragma mark - Selectors

- (void)pressedMoreButton:(id)sender
{
    if (_type != MoveTabTypeNone) {
        if ([self.delegate respondsToSelector:@selector(didTouchTabMove:moveTab:)]) {
            [self.delegate didTouchTabMove:1 moveTab:_type];
        }
    }
    
    //AccessLog
    if (_type == MoveTabTypeReview) {
        //AccessLog - 리뷰 더보기
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPJ10"];
    }
    else if (_type == MoveTabTypePost) {
        //AccessLog - 후기 더보기
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPJ12"];
    }
}

@end
