//
//  CPMartServiceAreaListView.m
//  11st
//
//  Created by saintsd on 2015. 6. 22..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPMartServiceAreaListView.h"
#import "CPTouchActionView.h"
#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"

#define TOP_MARGIN 0
#define ICON_HEIGHT	85

@interface CPMartServiceAreaListView ()
{
	NSArray *_items;
	NSInteger _columnCount;
}

@end

@implementation CPMartServiceAreaListView

+ (CGSize)viewSizeWithData:(NSArray *)items columnCount:(NSInteger)columnCount
{
	NSInteger weight = 0.f;
	
	for (NSInteger i=0; i<[items count]; i++)
	{
		NSInteger itemWeight = [items[i][@"weight"] integerValue];
		weight += itemWeight;
	}
	
	//짝수로 만들어준다.
	if (weight % 2 != 0) weight = weight + 1;
	
	NSInteger lineNumber = weight / columnCount;
	
	return CGSizeMake(kScreenBoundsWidth-20, TOP_MARGIN+(ICON_HEIGHT*lineNumber));
}

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items columnCount:(NSInteger)columnCount
{
	if (self = [super initWithFrame:frame]) {
		if (items) _items = [[NSArray alloc] initWithArray:items];
		
		_columnCount = columnCount;
		
		[self initSubviews];
	}
	return self;
}

- (void)initSubviews
{
	self.backgroundColor = [UIColor clearColor];
	
	CGFloat itemWidth = (NSInteger)((self.frame.size.width / _columnCount)-1);
	NSInteger lineWeight = 0;
	NSInteger lineNumber = 1;
	
	CGFloat offsetX = 0.f;
	CGFloat offsetY = 0.f;
	for (NSInteger i=0; i<[_items count]; i++) {

		if (lineWeight >= (_columnCount)) {
			offsetX = 0.f;
			offsetY += ICON_HEIGHT;
			lineNumber++;
			lineWeight = lineWeight - (_columnCount);
		}

		NSInteger weight = [_items[i][@"weight"] integerValue];
		NSString *type = _items[i][@"type"];
		CGFloat addHeight = 0.f;
		
		if ([@"localImage" isEqualToString:type]) addHeight += TOP_MARGIN;

		CGRect itemFrame = CGRectMake((NSInteger)offsetX, offsetY, (NSInteger)(itemWidth*weight)-1, (ICON_HEIGHT+addHeight)-1);
		
        NSString *wiseLogCode = @"";
        NSString *labelText = @"";
		if (![@"localImage" isEqualToString:type]) {

            itemFrame.size.width = (NSInteger)((self.frame.size.width / _columnCount-1))-1;
            
            if (IS_IPAD && (i == 4 || i == 10)) itemFrame.size.width = (NSInteger)(self.frame.size.width - itemFrame.origin.x);
            if (!IS_IPAD && ( i == 2 || i == 6 || i == 10)) itemFrame.size.width = (NSInteger)(self.frame.size.width - itemFrame.origin.x);

			if ([@"webImage" isEqualToString:type]) {
				UIView *bgView = [[UIView alloc] initWithFrame:itemFrame];
				bgView.backgroundColor = UIColorFromRGB(0xffffff);
				[self addSubview:bgView];
				
				CGFloat imageHeight = [Modules getRatioHeight:CGSizeMake(130, 110) screebWidth:70];
				
				NSString *imageUrl = _items[i][@"lnkBnnrImgUrl"];
				CPThumbnailView *iconView = [[CPThumbnailView alloc] initWithFrame:CGRectMake((bgView.frame.size.width/2)-35.f,
																							  (bgView.frame.size.height/2)-(imageHeight/2),
																							  70, imageHeight)];
				[iconView.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
				[bgView addSubview:iconView];
                
                wiseLogCode = @"MAP0601";
                labelText = _items[i][@"dispObjNm"];
			}
			else if ([@"totalPage" isEqualToString:type]) {
				UIView *bgView = [[UIView alloc] initWithFrame:itemFrame];
				bgView.backgroundColor = UIColorFromRGB(0xffffff);
				[self addSubview:bgView];

				UIImage *arrowImage = [UIImage imageNamed:@"bt_home_hot_arrow.png"];
				UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectZero];
				arrowView.image = arrowImage;
				[bgView addSubview:arrowView];
				
				UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
				label.backgroundColor = [UIColor clearColor];
				label.textColor = UIColorFromRGB(0x333333);
				label.font = [UIFont systemFontOfSize:14.f];
				label.text = @"전체보기";
				[label sizeToFitWithVersion];
				[bgView addSubview:label];
				
				label.frame = CGRectMake((bgView.frame.size.width/2)-((label.frame.size.width+3+arrowImage.size.width)/2),
										 (bgView.frame.size.height/2)-(label.frame.size.height/2),
										 label.frame.size.width, label.frame.size.height);
				
				arrowView.frame = CGRectMake(CGRectGetMaxX(label.frame)+3, label.frame.origin.y+2, arrowImage.size.width, arrowImage.size.height);
                
                wiseLogCode = @"MAP0602";
                labelText = @"전체보기";
			}
			
			//dispObjLnkUrl
			NSString *dispObjLnkUrl = _items[i][@"dispObjLnkUrl"];
			CPTouchActionView *actionView = [[CPTouchActionView alloc] initWithFrame:CGRectMake(offsetX, offsetY, itemFrame.size.width, ICON_HEIGHT+addHeight)];
			actionView.actionType = CPButtonActionTypeOpenSubview;
			actionView.actionItem = dispObjLnkUrl;
            actionView.wiseLogCode = wiseLogCode;
            [actionView setAccessibilityLabel:labelText Hint:@""];
			[self addSubview:actionView];
		}
		else {
            CGRect bgFrame = itemFrame;
			UIView *bgView = [[UIView alloc] initWithFrame:bgFrame];
			bgView.backgroundColor = UIColorFromRGB(0xfff36e);
			[self addSubview:bgView];
			
			UIImageView *imageViewL = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bgView.frame.size.height, bgView.frame.size.height)];
			imageViewL.image = [UIImage imageNamed:@"img_home_hot1.png"];
			[self addSubview:imageViewL];

			UIImageView *imageViewR = [[UIImageView alloc] initWithFrame:CGRectMake(bgView.frame.size.width-bgView.frame.size.height, 0,
																					bgView.frame.size.height, bgView.frame.size.height)];
			imageViewR.image = [UIImage imageNamed:@"img_home_hot2.png"];
			[self addSubview:imageViewR];
		}

		//위치 조정
		offsetX += (itemWidth*weight);
		lineWeight += weight;
		offsetY += addHeight;
	}
}

@end
