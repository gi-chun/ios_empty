//
//  CPSearchView.h
//  11st
//
//  Created by spearhead on 2014. 9. 30..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

// NS_ENUM
typedef NS_ENUM(NSUInteger, CPSearchType){
    CPSearchTypeRecent = 0,     //최근
    CPSearchTypeRise,           //급상승
    CPSearchTypeHot             //인기
};

@protocol CPSearchViewDelegate;

@interface CPSearchView : UIView

@property (nonatomic, weak) id<CPSearchViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame tabContentsItems:(NSArray *)tabContentsItems searchType:(CPSearchType)searchType searchDate:(NSString *)searchDate pageIndex:(NSInteger)pageIndex;

@end

@protocol CPSearchViewDelegate <NSObject>
@optional

- (void)didTouchKeyword:(NSString *)keyword;
- (void)didScrollViewWillBeginDragging;

@end