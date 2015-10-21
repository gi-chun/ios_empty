//
//  CPHomePopularKeywordView.h
//  11st
//
//  Created by saintsd on 2015. 6. 25..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPHomePopularKeywordViewDelegate;

@interface CPHomePopularKeywordView : UIView

@property (nonatomic, weak) id <CPHomePopularKeywordViewDelegate> delegate;

+ (CGSize)viewSizeWithData:(CGFloat)width items:(NSArray *)items isOpen:(BOOL)isOpen;
- (id)initWithFrame:(CGRect)frame items:(NSArray *)items isOpen:(BOOL)isOpen;

@end

@protocol CPHomePopularKeywordViewDelegate <NSObject>
@optional
- (void)homePopularKeywordView:(CPHomePopularKeywordView *)view openYn:(BOOL)isOpen;
@end
