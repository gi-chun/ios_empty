//
//  OptionItemView.h
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 2..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OptionItemViewDelegate;

@interface OptionItemView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<OptionItemViewDelegate>optionDelegate;

@property (nonatomic, strong) NSMutableArray *options;
@property (nonatomic, strong) NSArray *optionItemArray;
@property (nonatomic, strong) NSArray *selectedItemArray;
@property (nonatomic, strong) NSDictionary *itemDetailInfo;

@property (nonatomic, strong) UITableView *optionTableView;
@property (nonatomic, strong) NSString *optionType, *selOptCnt, *title, *selectName, *compareOptNo;
@property (nonatomic, weak) NSDictionary *multiOptionDictionary;
@property (nonatomic, strong) NSString *searchWord;

@property (nonatomic, assign) CGRect superviewFrame;
@property (nonatomic, assign) CGFloat openOffset;
@property (nonatomic, assign) CGFloat openMinimumHeight;

- (id)initWithProductOption:(NSArray *)options
             selectedOption:(NSArray *)selected
             itemDetailInfo:(NSDictionary *)itemDetailInfo
                      title:(NSString *)title
                 selectName:(NSString *)selectName
               isAdditional:(BOOL)additional
                      frame:(CGRect)frame;

- (void)reloadOptionItemView;
- (void)touchOptionWithIndex:(NSInteger)optionIndex;

@end


@protocol OptionItemViewDelegate <NSObject>
@optional
- (void)optionItem:(OptionItemView *)optionItem didSelectOptionItem:(NSDictionary *)items selectedRow:(NSInteger)selectedRow isConfirm:(BOOL)isConfirm;

- (void)didSelectedOptionItem:(OptionItemView *)optionItemView item:(NSDictionary *)item selectedRow:(NSInteger)selectedRow isConfirm:(BOOL)isConfirm;
- (void)didCloseOptionItem:(OptionItemView *)tableView;

- (void)didTouchCloseDrawerButton;
- (void)didTouchOpenDrawerButton;

@end
