//
//  CPHiddenView.h
//  11st
//
//  Created by saintsd on 2015. 6. 1..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPHiddenViewDelegate;

@interface CPHiddenView : UIView

@property (nonatomic, weak) id <CPHiddenViewDelegate> delegate;

- (void)setInfo:(NSDictionary *)info;
- (void)reloadData;
- (void)reloadDataWithIgnoreCache:(NSNumber *)delay;
- (void)reloadDataWithErrorRequest;
- (void)goToTopScroll;

@end

@protocol CPHiddenViewDelegate <NSObject>
@optional
- (void)didTouchButtonWithUrl:(NSString *)productUrl;
@end

//======================================================================

@protocol CPHiddenViewCellDelegate;

@interface CPHiddenViewCell : UITableViewCell

@property (nonatomic, weak) id <CPHiddenViewCellDelegate> delegate;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, strong) NSString *linkUrl;

@end

@protocol CPHiddenViewCellDelegate <NSObject>
@optional
- (void)CPHiddenViewCell:(CPHiddenViewCell *)cell moveUrl:(NSString *)url;
@end
