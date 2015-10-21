//
//  CPTrendBannerCell.m
//  11st
//
//  Created by saintsd on 2015. 6. 15..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPTrendBannerCell.h"
#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "CPHomeViewController.h"
#import "CPTouchActionView.h"

@interface CPTrendBannerCell () < CPThumbnailViewDelegate >
{
	UIView *_contentView;
	UIView *_lineView;
	
	UIView *_headerView;
	UILabel *_titleLabel;
	UILabel *_countTextLabel;
	UILabel *_countLable;
	UILabel *_categoryLabel;
	UIImageView *_arrowView;
	UIButton *_categoryButton;
	
	CPThumbnailView *_thumbnailView;
	CPTouchActionView *_thumbnailButton;
	
	
	UIView *_actionCountView;
	UIImageView *_replyIconView;
	UILabel *_replyLabel;
	UIImageView *_likeIconView;
	UILabel *_likeLabel;
}

@end

@implementation CPTrendBannerCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])
	{
		[self initSubviews];
	}
	return self;
}

- (void)initSubviews
{
	_contentView = [[UIView alloc] init];
	_contentView.backgroundColor = [UIColor whiteColor];
	[self.contentView addSubview:_contentView];
	
	_headerView = [[UIView alloc] initWithFrame:CGRectZero];
	_headerView.backgroundColor = [UIColor whiteColor];
	[_contentView addSubview:_headerView];
	
	_titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_titleLabel.textAlignment = NSTextAlignmentLeft;
	_titleLabel.backgroundColor = [UIColor clearColor];
	_titleLabel.textColor = UIColorFromRGB(0x333333);
	_titleLabel.font = [UIFont systemFontOfSize:16];
	_titleLabel.numberOfLines = 1;
	[_headerView addSubview:_titleLabel];
	
	_countTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_countTextLabel.textAlignment = NSTextAlignmentLeft;
	_countTextLabel.backgroundColor = [UIColor clearColor];
	_countTextLabel.textColor = UIColorFromRGB(0x999999);
	_countTextLabel.font = [UIFont systemFontOfSize:13];
	[_headerView addSubview:_countTextLabel];

	_countLable = [[UILabel alloc] initWithFrame:CGRectZero];
	_countLable.textAlignment = NSTextAlignmentLeft;
	_countLable.backgroundColor = [UIColor clearColor];
	_countLable.textColor = UIColorFromRGB(0x999999);
	_countLable.font = [UIFont boldSystemFontOfSize:13];
	[_headerView addSubview:_countLable];
	
	_arrowView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[_headerView addSubview:_arrowView];
	
	_categoryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_categoryLabel.textAlignment = NSTextAlignmentLeft;
	_categoryLabel.backgroundColor = [UIColor clearColor];
	_categoryLabel.textColor = UIColorFromRGB(0x1795ea);
	_categoryLabel.font = [UIFont boldSystemFontOfSize:14];
	[_headerView addSubview:_categoryLabel];
	
	_categoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_categoryButton addTarget:self action:@selector(onTouchCategoryButton:) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:_categoryButton];

	_thumbnailView = [[CPThumbnailView alloc] initWithFrame:CGRectZero];
	_thumbnailView.isFirstShowAnimation = YES;
	[_contentView addSubview:_thumbnailView];
	
	_thumbnailButton = [[CPTouchActionView alloc] init];
	[_contentView addSubview:_thumbnailButton];
	
	_actionCountView = [[UIView alloc] initWithFrame:CGRectZero];
	_actionCountView.backgroundColor = UIColorFromRGBA(0x000000, 0.4);
	[_contentView addSubview:_actionCountView];
	
	_replyIconView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[_actionCountView addSubview:_replyIconView];
	
	_replyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_replyLabel.textAlignment = NSTextAlignmentLeft;
	_replyLabel.backgroundColor = [UIColor clearColor];
	_replyLabel.textColor = UIColorFromRGB(0xffffff);
	_replyLabel.font = [UIFont boldSystemFontOfSize:13];
	[_actionCountView addSubview:_replyLabel];

	_likeIconView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[_actionCountView addSubview:_likeIconView];
	
	_likeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_likeLabel.textAlignment = NSTextAlignmentLeft;
	_likeLabel.backgroundColor = [UIColor clearColor];
	_likeLabel.textColor = UIColorFromRGB(0xffffff);
	_likeLabel.font = [UIFont boldSystemFontOfSize:13];
	[_actionCountView addSubview:_likeLabel];

	_lineView = [[UIView alloc] init];
	_lineView.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.contentView addSubview:_lineView];
}

- (void)layoutSubviews
{
	self.contentView.frame = self.bounds;
	_contentView.frame = CGRectMake(10, 0, self.contentView.frame.size.width-20.f, self.contentView.frame.size.height-11);
	
	//header
	NSString *dispObjNm = self.item[@"dispObjNm"];
	NSString *clickCnt = (self.item[@"clickCnt"] && [self.item[@"clickCnt"] length] > 0 ? self.item[@"clickCnt"] : @"0");
	NSString *tagNm = self.item[@"tagNm"];
	NSString *thumbnailUrl = self.item[@"lnkBnnrImgUrl"];
	NSString *brdCnt = (self.item[@"brdCnt"] && [self.item[@"brdCnt"] length] > 0 ? self.item[@"brdCnt"] : @"0");
	NSString *likeCnt = (self.item[@"likeCnt"] && [self.item[@"likeCnt"] length] > 0 ? self.item[@"likeCnt"] : @"0");
	
	_headerView.frame = CGRectMake(0, 0, _contentView.frame.size.width, 0);
	_titleLabel.frame = CGRectMake(16, 12, _headerView.frame.size.width-32, 0);
	_titleLabel.text = dispObjNm;
	[_titleLabel sizeToFitWithVersionHoldWidth];
	
	_countTextLabel.frame = CGRectMake(16, CGRectGetMaxY(_titleLabel.frame)+4, 0, 0);
	_countTextLabel.text = @"조회 : ";
	[_countTextLabel sizeToFitWithVersion];
	
	_countLable.frame = CGRectMake(CGRectGetMaxX(_countTextLabel.frame)+2.f, _countTextLabel.frame.origin.y, 0, _countTextLabel.frame.size.height);
	_countLable.text = clickCnt;
	[_countLable sizeToFitWithVersionHoldHeight];
	
	_headerView.frame = CGRectMake(_headerView.frame.origin.x,
								   _headerView.frame.origin.y,
								   _headerView.frame.size.width,
								   CGRectGetMaxY(_countTextLabel.frame)+10.f);
	
	UIImage *arrowIcon = [UIImage imageNamed:@"st_tab_blue_arrow.png"];
	_arrowView.image = arrowIcon;
	_arrowView.frame = CGRectMake(_headerView.frame.size.width-16-arrowIcon.size.width, _headerView.frame.size.height-10-arrowIcon.size.height,
								  arrowIcon.size.width, arrowIcon.size.height);
	
	_categoryLabel.text = tagNm;
	[_categoryLabel sizeToFitWithVersion];
	_categoryLabel.frame = CGRectMake(_arrowView.frame.origin.x-6-_categoryLabel.frame.size.width,
									  _arrowView.frame.origin.y,
									  _categoryLabel.frame.size.width,
									  _arrowView.frame.size.height);
	
	_categoryButton.frame = CGRectMake(_categoryLabel.frame.origin.x-3.f,
									   _arrowView.frame.origin.y-3.f,
									   _categoryLabel.frame.size.width+6+_arrowView.frame.size.width+6,
									   _arrowView.frame.size.height+6);
	[_categoryButton setImage:[UIImage imageWithColor:UIColorFromRGBA(0x000000, 0.3)
												width:_categoryButton.frame.size.width
											   height:_categoryButton.frame.size.height]
					 forState:UIControlStateHighlighted];
	
	[_categoryButton setAccessibilityLabel:tagNm Hint:@""];
	
	//thumbnail
	_thumbnailView.frame = CGRectMake(0, CGRectGetMaxY(_headerView.frame),
									  _contentView.frame.size.width,
									  _contentView.frame.size.height-_headerView.frame.size.height);
	_thumbnailView.delegate = self;
	[_thumbnailView.imageView sd_setImageWithURL:[NSURL URLWithString:thumbnailUrl]];
	
	
	_thumbnailButton.frame = _thumbnailView.frame;
	_thumbnailButton.actionType = CPButtonActionTypeOpenSubview;
	_thumbnailButton.actionItem = self.item[@"dispObjLnkUrl"];
	_thumbnailButton.wiseLogCode = @"MAH0200";
	[_thumbnailButton setAccessibilityLabel:dispObjNm Hint:@""];

	//show action count
	_actionCountView.frame = CGRectMake(16, _contentView.frame.size.height-16-24, 0, 24);
	
	UIImage *replyIcon = [UIImage imageNamed:@"st_tab_ic_reply.png"];
	_replyIconView.frame = CGRectMake(6, (_actionCountView.frame.size.height/2)-(replyIcon.size.height/2),
									  replyIcon.size.width, replyIcon.size.height);
	_replyIconView.image = replyIcon;
	
	_replyLabel.text = brdCnt;
	[_replyLabel sizeToFitWithVersion];
	_replyLabel.frame = CGRectMake(CGRectGetMaxX(_replyIconView.frame)+4, (_actionCountView.frame.size.height/2)-(_replyLabel.frame.size.height/2),
								   _replyLabel.frame.size.width, _replyLabel.frame.size.height);
	
	UIImage *likeIcon = [UIImage imageNamed:@"st_tab_ic_like.png"];
	_likeIconView.frame = CGRectMake(CGRectGetMaxX(_replyLabel.frame)+12, _replyIconView.frame.origin.y,
									 likeIcon.size.width, likeIcon.size.height);
	_likeIconView.image = likeIcon;
	
	_likeLabel.text = likeCnt;
	[_likeLabel sizeToFitWithVersion];
	_likeLabel.frame = CGRectMake(CGRectGetMaxX(_likeIconView.frame)+4, (_actionCountView.frame.size.height/2)-(_likeLabel.frame.size.height/2),
								   _likeLabel.frame.size.width, _likeLabel.frame.size.height);
	
	_actionCountView.frame = CGRectMake(16, _contentView.frame.size.height-16-24, CGRectGetMaxX(_likeLabel.frame)+6, 24);
    
    //댓글과 좋아요 카운트가 0일 경우 비노출, 조회수 0일 경우 비노출
    if (([brdCnt isEqualToString:@"0"] && [likeCnt isEqualToString:@"0"]) || [clickCnt isEqualToString:@"0"]) {
        [_actionCountView setHidden:YES];
    }
    else {
        [_actionCountView setHidden:NO];
    }
	
	//line
	[_lineView setFrame:CGRectMake(_contentView.frame.origin.x,
								   CGRectGetMaxY(_contentView.frame),
								   _contentView.frame.size.width,
								   1)];
}

- (void)onTouchCategoryButton:(id)sender
{
	NSString *url = self.item[@"tagLink"];
	
	if (url && [[url trim] length] > 0) {
		AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		CPHomeViewController *homeViewController = app.homeViewController;
		
		if ([homeViewController respondsToSelector:@selector(didTouchButtonWithUrl:)]) {
			[homeViewController didTouchButtonWithUrl:url];
		}
	}
}

- (void)CPThumbnailView:(CPThumbnailView *)view didFinishedDownloadImage:(UIImage *)image
{
	view.delegate = nil;
	
	NSString *thumbnailUrl = self.item[@"lnkBnnrImgUrl"];
	NSString *imageHeight = [NSString stringWithFormat:@"%ld", (long)[Modules getRatioHeight:CGSizeMake(image.size.width, image.size.height)
																				 screebWidth:view.frame.size.width]];

	if (self.delegate && [self.delegate respondsToSelector:@selector(setTrendBannerCellImageHeightWithInfo:)]) {
		
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  thumbnailUrl, @"imageUrl",
							  imageHeight, @"imageHeight",
							  self.indexPath, @"indexPath",
							  nil];
		
		[self.delegate setTrendBannerCellImageHeightWithInfo:dict];
	}
}

@end
