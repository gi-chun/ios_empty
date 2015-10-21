//
//  CPMartServiceAreaView.m
//  11st
//
//  Created by saintsd on 2015. 6. 19..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPMartServiceAreaView.h"
#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"
#import "CPTouchActionView.h"

@interface CPMartServiceAreaView ()
{
	NSArray *_items;
}

@end

@implementation CPMartServiceAreaView

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items
{
	if (self = [super initWithFrame:frame]) {
		
		if (items) _items = [[NSArray alloc] initWithArray:items];
		
		[self initSubviews];
	}
	
	return self;
}

- (void)initSubviews
{
	self.backgroundColor = UIColorFromRGB(0xf1f1f1);
	
	CGFloat buttonWidth = (self.frame.size.width-([_items count]-1)) / [_items count];
	CGFloat offsetX = 0.f;
	
	for (NSInteger i=0; i<[_items count]; i++) {
		
		if ([_items count]-1 == i) {
			buttonWidth = self.frame.size.width - offsetX;
		}
		
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(offsetX, 0, (NSInteger)buttonWidth, self.frame.size.height)];
		view.backgroundColor = [UIColor whiteColor];
		[self addSubview:view];
		
        NSString *wiseLogCode = @"";
        NSString *labelText = @"";
		NSString *type = _items[i][@"type"];
		if ([type isEqualToString:@"image"])
		{
			NSString *imageUrl = _items[i][@"imageUrl"];

			CGFloat imageHeight = (IS_IPAD ? 48 : (kScreenBoundsWidth == 320 ? 33.f : 36.f));
			CGFloat imageWidth = (IS_IPAD ? 110 : (kScreenBoundsWidth == 320 ? 60.f : 82.f));
			
			CGRect imageRt = CGRectZero;
			imageRt.origin.x = (view.frame.size.width/2) - (imageWidth/2);
			imageRt.origin.y = (view.frame.size.height/2) - (imageHeight/2);
			imageRt.size.width = imageWidth;
			imageRt.size.height = imageHeight;
			
            if (i == 0)         wiseLogCode = @"MAP0401";
            else if (i == 1)    wiseLogCode = @"MAP0402";
            else if (i == 2)    wiseLogCode = @"MAP0403";
            else if (i == 3)    wiseLogCode = @"MAP0404";
            
            if (i == 0)         labelText = @"홈플러스";
            else if (i == 1)    labelText = @"GS슈퍼마켓";
            else if (i == 2)    labelText = @"롯데닷컴";
            else if (i == 3)    labelText = @"현대H몰";
            
			CPThumbnailView *iconView = [[CPThumbnailView alloc] initWithFrame:imageRt];
			[iconView.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
			[view addSubview:iconView];
		}
		else if ([type isEqualToString:@"text"])
		{
            if (i == 0)         wiseLogCode = @"MAP0502";
            else if (i == 1)    wiseLogCode = @"MAP0503";
            else if (i == 2)    wiseLogCode = @"MAP0504";
            else if (i == 3)    wiseLogCode = @"MAP0505";
            
			NSString *text = _items[i][@"title"];
			
			UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
			label.backgroundColor = [UIColor clearColor];
			label.textColor = UIColorFromRGB(0x000000);
			label.font = [UIFont boldSystemFontOfSize:14.f];
			label.textAlignment = NSTextAlignmentCenter;
			label.text = text;
			[view addSubview:label];
		}
		
		NSString *linkUrl = _items[i][@"linkUrl"];
		
		CPTouchActionView *actionView = [[CPTouchActionView alloc] initWithFrame:view.frame];
		actionView.actionType = CPButtonActionTypeOpenSubview;
		actionView.actionItem = linkUrl;
        actionView.wiseLogCode = wiseLogCode;
        [actionView setAccessibilityLabel:labelText Hint:@""];
		[self addSubview:actionView];
		
		offsetX = offsetX + (NSInteger)buttonWidth + 1;
	}
}

@end
