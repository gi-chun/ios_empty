//
//  CPPriceDetailHeaderView.m
//  11st
//
//  Created by 김응학 on 2015. 7. 7..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPPriceDetailHeaderView.h"
#import "AccessLog.h"

@interface CPPriceDetailHeaderView ()
{
    UILabel *_titleLabel;
    UILabel *_subLabel;
    UIButton *_rightButton;
    UIView *_underLine;
    
    //검색셀렉트
    UIView *_dlvFilterView;
    UIView *_sortFilterView;
    
    //리뷰 탭박스
    UIView *_reviewTabView;
}

@end

@implementation CPPriceDetailHeaderView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    self.backgroundColor = [UIColor whiteColor];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = UIColorFromRGB(0x333333);
    _titleLabel.font = [UIFont boldSystemFontOfSize:15];
    _titleLabel.numberOfLines = 1;
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_titleLabel];
    
    _subLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _subLabel.backgroundColor = [UIColor clearColor];
    _subLabel.textColor = UIColorFromRGB(0x5460de);
    _subLabel.font = [UIFont boldSystemFontOfSize:14];
    _subLabel.numberOfLines = 1;
    _subLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_subLabel];
    
    _underLine = [[UIView alloc] initWithFrame:CGRectZero];
    _underLine.backgroundColor = UIColorFromRGB(0xededed);
    [self addSubview:_underLine];
    
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightButton addTarget:self action:@selector(onTouchRightButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rightButton];
    
    _dlvFilterView = [[UIView alloc] initWithFrame:CGRectZero];
    _dlvFilterView.layer.borderWidth = 1;
    _dlvFilterView.layer.borderColor = UIColorFromRGB(0xd6d6d8).CGColor;
    _dlvFilterView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_dlvFilterView];

    _sortFilterView = [[UIView alloc] initWithFrame:CGRectZero];
    _sortFilterView.layer.borderWidth = 1;
    _sortFilterView.layer.borderColor = UIColorFromRGB(0xd6d6d8).CGColor;
    _sortFilterView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_sortFilterView];

    _reviewTabView = [[UIView alloc] initWithFrame:CGRectZero];
    _reviewTabView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_reviewTabView];
    
    _titleLabel.hidden = YES;
    _subLabel.hidden = YES;
    _rightButton.hidden = YES;
    _underLine.hidden = YES;
    _dlvFilterView.hidden = YES;
    _sortFilterView.hidden = YES;
    _reviewTabView.hidden = YES;
}

- (void)layoutSubviews
{
    if (self.type == CPPriceDetailHeaderTypeNone)                   self.backgroundColor = [UIColor clearColor];
    else if (self.type == CPPriceDetailHeaderTypeRelatedModels)         [self setRelatedModels];
    else if (self.type == CPPriceDetailHeaderTypeSpec)                  [self setSpec];
    else if (self.type == CPPriceDetailHeaderTypeCompPrcList)           [self setCompPrcList];
    else if (self.type == CPPriceDetailHeaderTypeReviewList)            [self setReviewList];
    else if (self.type == CPPriceDetailHeaderTypeSatisfyScore)          [self setSatisfyScore];
    else if (self.type == CPPriceDetailHeaderTypeSaleGraph)             [self setSaleGraph];
    else if (self.type == CPPriceDetailHeaderTypeSameCategoryModels)    [self setSameCategoryModels];
    else if (self.type == CPPriceDetailHeaderTypeSameBrandModels)       [self setSameBrandModels];
    else if (self.type == CPPriceDetailHeaderTypeBestProducts)          [self setBestProducts];
    
}

- (void)setRelatedModels
{
    _titleLabel.text = _item[@"title"];
    [_titleLabel sizeToFitWithVersion];
    _titleLabel.frame = CGRectMake(10,
                                   (self.frame.size.height/2)-(_titleLabel.frame.size.height/2),
                                   _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    
    
    NSString *subText = [Modules numberFormat:[_item[@"totalCount"] integerValue]];
    _subLabel.text = [NSString stringWithFormat:@"%@개", subText];
    _subLabel.font = [UIFont boldSystemFontOfSize:14];
    [_subLabel sizeToFitWithVersion];
    _subLabel.frame = CGRectMake(CGRectGetMaxX(_titleLabel.frame)+6,
                                 (self.frame.size.height/2)-(_subLabel.frame.size.height/2),
                                 _subLabel.frame.size.width, _subLabel.frame.size.height);
    
    NSString *openYn = _item[@"selected"];
    UIImage *btnImg = ([openYn isEqualToString:@"N"] ? [UIImage imageNamed:@"ic_pd_arrow_down.png"] : [UIImage imageNamed:@"ic_pd_arrow_up_01.png"]);
    
    [_rightButton setImage:btnImg forState:UIControlStateNormal];
    [_rightButton setFrame:CGRectMake(self.frame.size.width-self.frame.size.height, 0, self.frame.size.height, self.frame.size.height)];
    [_rightButton setAccessibilityLabel:([openYn isEqualToString:@"N"] ? @"자세히 보기" : @"닫기") Hint:@""];
    [_rightButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(0xe5e5e5, 0.3)
                                                       width:_rightButton.frame.size.width
                                                      height:_rightButton.frame.size.height]
                            forState:UIControlStateHighlighted];
    
    if ([openYn isEqual:@"N"])  _underLine.backgroundColor = UIColorFromRGB(0xd7d7d7);
    else                        _underLine.backgroundColor = UIColorFromRGB(0xededed);

    _underLine.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
    
    
    _titleLabel.hidden = NO;
    _subLabel.hidden = NO;
    _rightButton.hidden = NO;
    _underLine.hidden = NO;
}

- (void)setSpec
{
    _titleLabel.text = _item[@"title"];
    [_titleLabel sizeToFitWithVersion];
    _titleLabel.frame = CGRectMake(10,
                                   (self.frame.size.height/2)-(_titleLabel.frame.size.height/2),
                                   _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    
    NSString *openYn = _item[@"selected"];
    UIImage *btnImg = ([openYn isEqualToString:@"N"] ? [UIImage imageNamed:@"ic_pd_arrow_down.png"] : [UIImage imageNamed:@"ic_pd_arrow_up_01.png"]);
    
    [_rightButton setImage:btnImg forState:UIControlStateNormal];
    [_rightButton setFrame:CGRectMake(self.frame.size.width-self.frame.size.height, 0, self.frame.size.height, self.frame.size.height)];
    [_rightButton setAccessibilityLabel:([openYn isEqualToString:@"N"] ? @"자세히 보기" : @"닫기") Hint:@""];
    [_rightButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(0xe5e5e5, 0.3)
                                                       width:_rightButton.frame.size.width
                                                      height:_rightButton.frame.size.height]
                            forState:UIControlStateHighlighted];
    
    if ([openYn isEqual:@"N"])  _underLine.backgroundColor = UIColorFromRGB(0xd7d7d7);
    else                        _underLine.backgroundColor = UIColorFromRGB(0xededed);
    
    _underLine.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
    
    _titleLabel.hidden = NO;
    _rightButton.hidden = NO;
    _underLine.hidden = NO;
}

- (void)setCompPrcList
{
    _titleLabel.text = _item[@"title"];
    [_titleLabel sizeToFitWithVersion];
    _titleLabel.frame = CGRectMake(10,
                                   20-(_titleLabel.frame.size.height/2),
                                   _titleLabel.frame.size.width, _titleLabel.frame.size.height);

    NSString *subText = [Modules numberFormat:[_item[@"totalCount"] integerValue]];
    _subLabel.text = [NSString stringWithFormat:@"%@개", subText];
    _subLabel.font = [UIFont boldSystemFontOfSize:14];
    [_subLabel sizeToFitWithVersion];
    _subLabel.frame = CGRectMake(CGRectGetMaxX(_titleLabel.frame)+6,
                                 (20)-(_subLabel.frame.size.height/2),
                                 _subLabel.frame.size.width, _subLabel.frame.size.height);
    
    _underLine.frame = CGRectMake(0, 39, self.frame.size.width, 1);
    

    _dlvFilterView.frame = CGRectMake(10, 49, (self.frame.size.width-8-20)/2, 32);
    _sortFilterView.frame = CGRectMake(CGRectGetMaxX(_dlvFilterView.frame)+8, 49, _dlvFilterView.frame.size.width, 32);
    
    for (UIView *subview in _dlvFilterView.subviews) {
        [subview removeFromSuperview];
    }
    for (UIView *subview in _sortFilterView.subviews) {
        [subview removeFromSuperview];
    }
    
    UIImage *dropDownImg = [UIImage imageNamed:@"bt_s_arrow_down_02.png"];
    
    //딜리버리 셀렉트 설정
    UIImageView *dlvDropView = [[UIImageView alloc] initWithFrame:CGRectMake(_dlvFilterView.frame.size.width-8-dropDownImg.size.width,
                                                                             (_dlvFilterView.frame.size.height/2)-(dropDownImg.size.height/2),
                                                                             dropDownImg.size.width, dropDownImg.size.height)];
    dlvDropView.image = dropDownImg;
    [_dlvFilterView addSubview:dlvDropView];
    
    NSString *dlvTitle = @"";
    NSArray *dlvArray = _item[@"dlvTypes"];
    
    for (NSInteger i=0; i<[dlvArray count]; i++) {
        NSString *selectedYn = dlvArray[i][@"selected"];
        
        if ([@"Y" isEqualToString:selectedYn]) {
            dlvTitle = dlvArray[i][@"title"];
            break;
        }
    }
    
    UILabel *dlvTitleLable = [[UILabel alloc] initWithFrame:CGRectZero];
    dlvTitleLable.backgroundColor = [UIColor clearColor];
    dlvTitleLable.textColor = UIColorFromRGB(0x4d4d4d);
    dlvTitleLable.font = [UIFont systemFontOfSize:14];
    dlvTitleLable.text = dlvTitle;
    [dlvTitleLable sizeToFitWithVersion];
    [_dlvFilterView addSubview:dlvTitleLable];
    
    dlvTitleLable.frame = CGRectMake(7, (_dlvFilterView.frame.size.height/2)-(dlvTitleLable.frame.size.height/2),
                                     dlvTitleLable.frame.size.width, dlvTitleLable.frame.size.height);
    
    UIButton *dlvButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dlvButton.frame = _dlvFilterView.bounds;
    [dlvButton setAccessibilityLabel:[NSString stringWithFormat:@"%@ 보기", dlvTitle] Hint:@""];
    [dlvButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(0xe5e5e5, 0.3)
                                                   width:dlvButton.frame.size.width
                                                  height:dlvButton.frame.size.height]
                         forState:UIControlStateHighlighted];
    [dlvButton addTarget:self action:@selector(onTouchDlvFilterButton:) forControlEvents:UIControlEventTouchUpInside];
    [_dlvFilterView addSubview:dlvButton];
    
    //검색우선순위 설정
    UIImageView *sortDropView = [[UIImageView alloc] initWithFrame:CGRectMake(_dlvFilterView.frame.size.width-8-dropDownImg.size.width,
                                                                             (_dlvFilterView.frame.size.height/2)-(dropDownImg.size.height/2),
                                                                             dropDownImg.size.width, dropDownImg.size.height)];
    sortDropView.image = dropDownImg;
    [_sortFilterView addSubview:sortDropView];
    
    NSString *sortTitle = @"";
    NSArray *sortArray = _item[@"sortCds"];
    
    for (NSInteger i=0; i<[sortArray count]; i++) {
        NSString *selectedYn = sortArray[i][@"selected"];
        
        if ([@"Y" isEqualToString:selectedYn]) {
            sortTitle = sortArray[i][@"title"];
            break;
        }
    }
    
    UILabel *sortTitleLable = [[UILabel alloc] initWithFrame:CGRectZero];
    sortTitleLable.backgroundColor = [UIColor clearColor];
    sortTitleLable.textColor = UIColorFromRGB(0x4d4d4d);
    sortTitleLable.font = [UIFont systemFontOfSize:14];
    sortTitleLable.text = sortTitle;
    [sortTitleLable sizeToFitWithVersion];
    [_sortFilterView addSubview:sortTitleLable];
    
    sortTitleLable.frame = CGRectMake(7, (_sortFilterView.frame.size.height/2)-(sortTitleLable.frame.size.height/2),
                                      sortTitleLable.frame.size.width, sortTitleLable.frame.size.height);
    
    UIButton *sortButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sortButton.frame = _sortFilterView.bounds;
    [sortButton setAccessibilityLabel:[NSString stringWithFormat:@"%@ 보기", sortTitle] Hint:@""];
    [sortButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(0xe5e5e5, 0.3)
                                                     width:sortButton.frame.size.width
                                                    height:sortButton.frame.size.height]
                          forState:UIControlStateHighlighted];
    [sortButton addTarget:self action:@selector(onTouchSortFilterButton:) forControlEvents:UIControlEventTouchUpInside];
    [_sortFilterView addSubview:sortButton];
    
    _dlvFilterView.hidden = NO;
    _sortFilterView.hidden = NO;
    _titleLabel.hidden = NO;
    _subLabel.hidden = NO;
    _underLine.hidden = NO;

    //와이즈로그
    NSArray *tempItems = _item[@"items"];
    if (tempItems && [tempItems count] > 0) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDG01"];
    }
    
    NSString *isMore = _item[@"isMore"];
    if ([@"Y" isEqualToString:isMore]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDH01"];
    }
}

- (void)setReviewList
{
    _titleLabel.text = _item[@"title"];
    [_titleLabel sizeToFitWithVersion];
    _titleLabel.frame = CGRectMake(10,
                                   20-(_titleLabel.frame.size.height/2),
                                   _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    
    NSString *subText = [Modules numberFormat:[_item[@"totalCount"] integerValue]];
    _subLabel.text = [NSString stringWithFormat:@"%@개", subText];
    _subLabel.font = [UIFont boldSystemFontOfSize:14];
    [_subLabel sizeToFitWithVersion];
    _subLabel.frame = CGRectMake(CGRectGetMaxX(_titleLabel.frame)+6,
                                 (20)-(_subLabel.frame.size.height/2),
                                 _subLabel.frame.size.width, _subLabel.frame.size.height);
    
    _underLine.frame = CGRectMake(0, 39, self.frame.size.width, 1);

    NSArray *tabs = _item[@"tabs"];
    _reviewTabView.frame = CGRectMake(10, 49, self.frame.size.width-20, 36);
    
    for (UIView *subview in _reviewTabView.subviews) {
        [subview removeFromSuperview];
    }

    UIImage *tabBg = [UIImage imageNamed:@"tab_pd_review_bg.png"];
    tabBg = [tabBg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 18, 0, 18)];
    
    UIImageView *tabBgView = [[UIImageView alloc] initWithFrame:_reviewTabView.bounds];
    tabBgView.image = tabBg;
    [_reviewTabView addSubview:tabBgView];
    
    for (NSInteger i=0; i<[tabs count]; i++) {
        
        CGFloat buttonWidth = _reviewTabView.frame.size.width/2;
        UIImage *btnBg = (i == 0 ? [UIImage imageNamed:@"tab_pd_review_01.png"] : [UIImage imageNamed:@"tab_pd_review_02.png"]);
        btnBg = [btnBg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(i * buttonWidth, 0, buttonWidth, _reviewTabView.frame.size.height)];
        [btn setBackgroundImage:btnBg forState:UIControlStateHighlighted];
        [btn setBackgroundImage:btnBg forState:UIControlStateSelected];
        
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn setTitle:tabs[i][@"title"] forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateHighlighted];
        [btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateSelected];
        [btn setTag:i];
        [btn addTarget:self action:@selector(onTouchReviewTabs:) forControlEvents:UIControlEventTouchUpInside];
        [_reviewTabView addSubview:btn];
        
        if ([@"Y" isEqualToString:tabs[i][@"selected"]])    btn.selected = YES;
        else                                                btn.selected = NO;
    }

    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDJ01"];
    
    if ([@"Y" isEqualToString:tabs[0][@"selected"]])    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDJ04"];
    if ([@"Y" isEqualToString:tabs[1][@"selected"]])    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDK04"];

    if ([@"Y" isEqualToString:tabs[0][@"isMore"]])    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDJ06"];
    if ([@"Y" isEqualToString:tabs[1][@"isMore"]])    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDK06"];

    _titleLabel.hidden = NO;
    _subLabel.hidden = NO;
    _underLine.hidden = NO;
    _reviewTabView.hidden = NO;
}

- (void)setSatisfyScore
{
    _titleLabel.text = _item[@"title"];
    [_titleLabel sizeToFitWithVersion];
    _titleLabel.frame = CGRectMake(10,
                                   (self.frame.size.height/2)-(_titleLabel.frame.size.height/2),
                                   _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    
    
    _subLabel.text = _item[@"unit"];
    _subLabel.font = [UIFont boldSystemFontOfSize:12];
    _subLabel.textColor = UIColorFromRGB(0x7883a2);
    [_subLabel sizeToFitWithVersion];
    _subLabel.frame = CGRectMake(self.frame.size.width-8-_subLabel.frame.size.width,
                                 (self.frame.size.height/2)-(_subLabel.frame.size.height/2),
                                 _subLabel.frame.size.width, _subLabel.frame.size.height);
    
    _underLine.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
    
    _titleLabel.hidden = NO;
    _subLabel.hidden = NO;
    _underLine.hidden = NO;
    
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDL01"];
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDL02"];
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDL03"];
}

- (void)setSaleGraph
{
    _titleLabel.text = _item[@"title"];
    [_titleLabel sizeToFitWithVersion];
    _titleLabel.frame = CGRectMake(10,
                                   (self.frame.size.height/2)-(_titleLabel.frame.size.height/2),
                                   _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    
    _subLabel.text = _item[@"unit"];
    _subLabel.font = [UIFont boldSystemFontOfSize:12];
    _subLabel.textColor = UIColorFromRGB(0x7883a2);
    [_subLabel sizeToFitWithVersion];
    _subLabel.frame = CGRectMake(self.frame.size.width-8-_subLabel.frame.size.width,
                                 (self.frame.size.height/2)-(_subLabel.frame.size.height/2),
                                 _subLabel.frame.size.width, _subLabel.frame.size.height);

    _underLine.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
    
    _titleLabel.hidden = NO;
    _subLabel.hidden = NO;
    _underLine.hidden = NO;
    
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDM01"];
}

- (void)setSameCategoryModels
{
    _titleLabel.text = _item[@"title"];
    [_titleLabel sizeToFitWithVersion];
    _titleLabel.frame = CGRectMake(10,
                                   (self.frame.size.height/2)-(_titleLabel.frame.size.height/2),
                                   _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    
    _underLine.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
    
    _titleLabel.hidden = NO;
    _underLine.hidden = NO;
    
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDN01"];
}

- (void)setSameBrandModels
{
    _titleLabel.text = _item[@"title"];
    [_titleLabel sizeToFitWithVersion];
    _titleLabel.frame = CGRectMake(10,
                                   (self.frame.size.height/2)-(_titleLabel.frame.size.height/2),
                                   _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    
    _underLine.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
    
    _titleLabel.hidden = NO;
    _underLine.hidden = NO;
    
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDO01"];
}

- (void)setBestProducts
{
    _titleLabel.text = _item[@"title"];
    [_titleLabel sizeToFitWithVersion];
    _titleLabel.frame = CGRectMake(10,
                                   (self.frame.size.height/2)-(_titleLabel.frame.size.height/2),
                                   _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    
    _rightButton.frame = CGRectMake(self.frame.size.width-60, (self.frame.size.height/2)-(18), 60, 36);

    UIImage *arrowImg = [UIImage imageNamed:@"ic_pd_arrow_right_02.png"];
    [_rightButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_rightButton setTitleColor:UIColorFromRGB(0x2b3794) forState:UIControlStateNormal];
    [_rightButton setTitleColor:UIColorFromRGB(0xafb3fa) forState:UIControlStateHighlighted];
    [_rightButton setTitle:@"더보기" forState:UIControlStateNormal];
    [_rightButton setImage:arrowImg forState:UIControlStateNormal];
    [_rightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -14, 0, 0)];
    [_rightButton setImageEdgeInsets:UIEdgeInsetsMake(0, 46, 0, 0)];
    
    _underLine.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
    
    _titleLabel.hidden = NO;
    _rightButton.hidden = NO;
    _underLine.hidden = NO;
    
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDP01"];
}

#pragma mark - selectors
- (void)onTouchRightButton:(id)sender
{
    NSString *openYn = _item[@"selected"];
    
    BOOL isOpen = ![openYn isEqualToString:@"Y"];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(priceDetailHeaderOnTouchOpenYn:type:)]) {
        [self.delegate priceDetailHeaderOnTouchOpenYn:isOpen type:self.type];
    }
}

- (void)onTouchDlvFilterButton:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(priceDetailHeaderOnTouchFilterPopup:)]) {
        [self.delegate priceDetailHeaderOnTouchFilterPopup:@"dlvTypes"];
    }
}

- (void)onTouchSortFilterButton:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(priceDetailHeaderOnTouchFilterPopup:)]) {
        [self.delegate priceDetailHeaderOnTouchFilterPopup:@"sortCds"];
    }
}

- (void)onTouchReviewTabs:(id)sender
{
    NSInteger selectIndex = [sender tag];
    
    if (selectIndex == 0)   [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDJ02"];
    else                    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDJ03"];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(priceDetailHeaderOnTOuchReviewTabs:)]) {
        [self.delegate priceDetailHeaderOnTOuchReviewTabs:selectIndex];
    }
}

@end
