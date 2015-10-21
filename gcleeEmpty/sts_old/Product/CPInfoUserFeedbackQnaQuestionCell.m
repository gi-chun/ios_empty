#import "CPInfoUserFeedbackQnaQuestionCell.h"

@interface CPInfoUserFeedbackQnaQuestionCell ()
{
	UIImageView *_iconView;
	UILabel *_textLabel;
	UIButton *_modifyButton;
	UIButton *_deleteButton;
	UIView *_bottomLineView;
}

@end

@implementation CPInfoUserFeedbackQnaQuestionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
		[self initLayout];
	}
	return self;
}

- (void)initLayout
{
	self.backgroundColor = UIColorFromRGB(0xf2f2f2);
	
	_iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[self addSubview:_iconView];
	
	_textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_textLabel.backgroundColor = [UIColor clearColor];
	_textLabel.textColor = UIColorFromRGB(0x525252);
	_textLabel.font = [UIFont systemFontOfSize:13.f];
	_textLabel.numberOfLines = 100;
	_textLabel.textAlignment = NSTextAlignmentLeft;
	[self addSubview:_textLabel];
	
	_modifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_modifyButton addTarget:self action:@selector(pressedModifyButton:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_modifyButton];
	
	_deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_deleteButton addTarget:self action:@selector(pressedDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_deleteButton];
	
	_bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
	_bottomLineView.backgroundColor = UIColorFromRGB(0xe4e4e4);
	[self addSubview:_bottomLineView];
}

- (void)layoutSubviews
{
	UIImage *imgIcon = [UIImage imageNamed:@"ic_pd_question.png"];
	_iconView.image = imgIcon;
	_iconView.frame = CGRectMake(10.f, 14.f, imgIcon.size.width, imgIcon.size.height);
	
	NSString *text = self.dict[@"text"];
	
	CGFloat textWidth = self.frame.size.width-(CGRectGetMaxX(_iconView.frame)+11.f+10.f);
	_textLabel.text = text;
    _textLabel.frame = CGRectMake(CGRectGetMaxX(_iconView.frame)+11.f, 16.f, textWidth, 0);
	[_textLabel sizeToFitWithVersionHoldWidth];
	
	NSString *mineYn = self.dict[@"mineYn"];
	
	if ([mineYn isEqualToString:@"Y"])
	{
		CGFloat btnOriginY = 0.f;
		if (CGRectGetMaxY(_textLabel.frame)+10.f < CGRectGetMaxY(_iconView.frame)+10.f)
		{
			btnOriginY = CGRectGetMaxY(_iconView.frame)+9.f;
		}
		else
		{
			btnOriginY = CGRectGetMaxY(_textLabel.frame)+9.f;
		}
		
		UIImage *imgModifyBg = [UIImage imageNamed:@"bt_pd_modify.png"];
		
//		[_modifyButton setTitle:@"수정" forState:UIControlStateNormal];
//		[_modifyButton.titleLabel setFont:[UIFont systemFontOfSize:13.f]];
//		[_modifyButton setTitleColor:UIColorFromRGB(0x636566) forState:UIControlStateNormal];
		[_modifyButton setBackgroundImage:imgModifyBg forState:UIControlStateNormal];
		_modifyButton.frame = CGRectMake(CGRectGetMaxX(_iconView.frame)+11.f,
										 btnOriginY,
										 imgModifyBg.size.width,
										 imgModifyBg.size.height);
		
		UIImage *imgDeleteBg = [UIImage imageNamed:@"bt_pd_delete.png"];

//		[_deleteButton setTitle:@"삭제" forState:UIControlStateNormal];
//		[_deleteButton.titleLabel setFont:[UIFont systemFontOfSize:13.f]];
//		[_deleteButton setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
		[_deleteButton setBackgroundImage:imgDeleteBg forState:UIControlStateNormal];
		_deleteButton.frame = CGRectMake(CGRectGetMaxX(_modifyButton.frame)+5.f,
										 btnOriginY,
										 imgDeleteBg.size.width,
										 imgDeleteBg.size.height);
		
		_modifyButton.hidden = self.existAnswer;
		_deleteButton.hidden = self.existAnswer;
        
        if (self.existAnswer) {
            _modifyButton.frame = CGRectZero;
            _deleteButton.frame = CGRectZero;
        }
	}
	else
	{
		_modifyButton.frame = CGRectZero;
		_deleteButton.frame = CGRectZero;
		
		_modifyButton.hidden = YES;
		_deleteButton.hidden = YES;
	}
	
	_bottomLineView.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
}

- (void)pressedModifyButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(CPInfoUserFeedbackQnaQuestionCell:onClickModifyButton:)]) {
        [self.delegate CPInfoUserFeedbackQnaQuestionCell:self.dict onClickModifyButton:self.indexPath];
    }
}

- (void)pressedDeleteButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(CPInfoUserFeedbackQnaQuestionCell:onClickDeleteButton:)]) {
        [self.delegate CPInfoUserFeedbackQnaQuestionCell:self.dict onClickDeleteButton:self.indexPath];
    }
}

@end
