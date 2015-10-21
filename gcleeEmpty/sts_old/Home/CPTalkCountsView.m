//
//  CPTalkCountsView.m
//  11st
//
//  Created by saintsd on 2015. 6. 4..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPTalkCountsView.h"

@interface CPTalkCountsView ()
{
	NSInteger _replyCount;
	NSInteger _loveCount;
	
	UIImageView *_replyIconView;
	UIImageView *_loveIconView;
	
	UILabel *_replyCountLabel;
	UILabel *_loveCountLabel;
}

@end


@implementation CPTalkCountsView

- (id)initWithReplyCount:(NSInteger)replyCount loveCount:(NSInteger)loveCount
{
	if (self = [super init]) {
		_replyCount = replyCount;
		_loveCount = loveCount;
		
		[self initSubviews];
	}
	return self;
}

- (void)initSubviews
{
	CGFloat middleMargin = (kScreenBoundsWidth == 320 ? 5 : 12);
	
	UIImage *replyIcon = [UIImage imageNamed:@"sp_talk_ic_reply.png"];
	UIImage *loveIcon = [UIImage imageNamed:@"sp_talk_ic_like.png"];
	
	_replyIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, replyIcon.size.width, replyIcon.size.height)];
	_replyIconView.image = replyIcon;
	[self addSubview:_replyIconView];
	
	_replyCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_replyIconView.frame)+4, 0, 0, _replyIconView.frame.size.height)];
	_replyCountLabel.backgroundColor = [UIColor clearColor];
	_replyCountLabel.font = [UIFont systemFontOfSize:13];
	_replyCountLabel.textColor = UIColorFromRGB(0x5D6A80);
	_replyCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_replyCount];
	[self addSubview:_replyCountLabel];
	[_replyCountLabel sizeToFitWithVersionHoldHeight];
	
	_loveIconView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_replyCountLabel.frame)+middleMargin, 0,
																  loveIcon.size.width, loveIcon.size.height)];
	_loveIconView.image = loveIcon;
	[self addSubview:_loveIconView];
	
	_loveCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_loveIconView.frame)+4, 0, 0, _loveIconView.frame.size.height)];
	_loveCountLabel.backgroundColor = [UIColor clearColor];
	_loveCountLabel.font = [UIFont systemFontOfSize:13];
	_loveCountLabel.textColor = UIColorFromRGB(0x5D6A80);
	_loveCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_loveCount];
	[self addSubview:_loveCountLabel];
	[_loveCountLabel sizeToFitWithVersionHoldHeight];

	self.frame = CGRectMake(0, 0, CGRectGetMaxX(_loveCountLabel.frame), _loveCountLabel.frame.size.height);
}

@end
