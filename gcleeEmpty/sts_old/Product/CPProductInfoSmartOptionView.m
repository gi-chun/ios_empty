//
//  CPProductInfoSmartOptionView.m
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 10..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductInfoSmartOptionView.h"
#import "CPProductInfoSmartOptionTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "HEXColor.h"
#import "ProductSmartOptionModel.h"

//#import "InfoDescriptCouponView.h"
//#import "InfoDescriptEncoreView.h"
//#import "InfoDescriptBottomView.h"



@interface CPProductInfoSmartOptionView () <UITableViewDataSource,
                                            UITableViewDelegate,
//                                            InfoDescriptCouponViewDelegate,
//                                            InfoDescriptEncoreViewDelegate,
                                            CPProductInfoSmartOptionTableViewCellDelegate,
//                                            InfoDescriptBottomViewDelegate,
                                            UIScrollViewDelegate>
{
    UITableView *_tableView;
    
    // header
    UIView *_headerView;
//    InfoDescriptCouponView *_couponsView;
//    InfoDescriptEncoreView *_encoreDealView;
//    
//    // footer
//    InfoDescriptBottomView *_descriptBottomView;
}

@property (nonatomic, strong) NSDictionary *productDetailInfo;
@property (nonatomic, strong) NSMutableArray *cellHeights;
@property (nonatomic, assign) CGFloat headerViewHeight;
@property (nonatomic, assign) CGFloat footerViewHeight;

- (void)initSubviews;
- (void)initDefaultHeights;

@end

@implementation CPProductInfoSmartOptionView

- (void)releaseItem
{
    if (_tableView) _tableView.dataSource = nil, _tableView.delegate = nil, _tableView = nil;
    if (_headerView) _headerView = nil;
}

- (void)removeFromSuperview
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    [super removeFromSuperview];
}

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame withProductDetailInfo:(NSDictionary *)productDetailInfo
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _productDetailInfo = productDetailInfo;
        [self initSubviews];
        
        self.backgroundColor = [UIColor colorWithHexString:@"ebebeb"];
    }
    
    return self;
}

#pragma mark - Subviews

- (void)initSubviews
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.scrollsToTop = YES;
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    [_tableView registerClass:[CPProductInfoSmartOptionTableViewCell class] forCellReuseIdentifier:@"ProductInfoSmartOptionViewCell"];
    [self addSubview:_tableView];
    
    // header
    _headerView = [[UIView alloc] initWithFrame:CGRectZero];
    
//    NSArray *couponList = (_productDetailInfo[@"couponList"] != (id)[NSNull null]) ? _productDetailInfo[@"couponList"] : nil;
//    _couponsView = [[InfoDescriptCouponView alloc] initWithFrame:CGRectZero
//                                                           items:couponList];
//    _couponsView.delegate = self;
//    [_headerView addSubview:_couponsView];
//    
//    NSDictionary *encoreItem = (_productDetailInfo[@"encoreItem"] != (id)[NSNull null]) ? _productDetailInfo[@"encoreItem"] : nil;
//    _encoreDealView = [[InfoDescriptEncoreView alloc] initWithFrame:CGRectZero
//                                                               item:encoreItem];
//    _encoreDealView.delegate = self;
//    [_headerView addSubview:_encoreDealView];
    
    _tableView.tableHeaderView = _headerView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rectClient = self.bounds;
    [_tableView setFrame:rectClient];
}

#pragma mark - Property

- (void)setOptionItems:(NSArray *)optionItems
{
    if (_optionItems != optionItems)
    {
        _optionItems = optionItems;
        [self initDefaultHeights];
        
        [_tableView reloadData];
    }
}

#pragma mark - Private Methods

- (void)initDefaultHeights
{
    if (_cellHeights == nil)
    {
        _cellHeights = [[NSMutableArray alloc] initWithCapacity:_optionItems.count];
    }
    [_cellHeights removeAllObjects];
    
    for (NSUInteger i = 0; i < _optionItems.count; i++)
    {
        [_cellHeights addObject:[NSNull null]];
    }
}

#pragma mark - Public Methods

- (void)setScrollTop
{
    [_tableView scrollRectToVisible:CGRectMake(0.0f, 0.0f, 1.0f, 1.0f) animated:NO];
}

- (void)setScrollEnabled:(BOOL)isEnable
{
    [_tableView setScrollEnabled:isEnable];
}

- (void)setShowsHorizontalScrollIndicator:(BOOL)isShow
{
    [_tableView setShowsHorizontalScrollIndicator:isShow];
}

- (void)setShowsVerticalScrollIndicator:(BOOL)isShow
{
    [_tableView setShowsVerticalScrollIndicator:isShow];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _optionItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductSmartOptionModel *option = _optionItems[indexPath.row][0];
    ProductSmartOptionCellType type = option.cellType;
    
    CPProductInfoSmartOptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductInfoSmartOptionViewCell" forIndexPath:indexPath];
    cell.productSmartOptionCellType = type;
    cell.index = @(indexPath.row);
    cell.delegate = self;
    
    cell.items = _optionItems[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [CPProductInfoSmartOptionTableViewCell contentHeight];
    if (_cellHeights[indexPath.row] != (id)[NSNull null])
    {
        height = [_cellHeights[indexPath.row] floatValue];
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger totalRow = [tableView numberOfRowsInSection:indexPath.section];
    if (indexPath.row == totalRow - 1)
    {
        // footer
//        if (_descriptBottomView == nil)
//        {
//            _descriptBottomView = [[InfoDescriptBottomView alloc] initWithFrame:CGRectZero
//                                                                          items:_productDetailInfo[@"detailInfo"]
//                                                                          prdNo:_productDetailInfo[@"productNumber"]
//                                                                     dispCtgrNo:_productDetailInfo[@"categoryNumber"]
//                                                                  recommendItem:_productDetailInfo[@"recommendItemInfo"]];
//            _descriptBottomView.delegate = self;
//            
//            _tableView.tableFooterView = _descriptBottomView;
//        }
    }
}

#pragma mark - ProductInfoSmartOptionTableViewCellDelegate

- (void)productInfoSmartOptionTableViewCellImageDownloadedAtIndex:(NSNumber *)index withHeight:(NSNumber *)height
{
    if (_cellHeights[index.integerValue] == (id)[NSNull null])
    {
        [_cellHeights replaceObjectAtIndex:index.integerValue withObject:height];
        [_tableView reloadData];
    }
}

- (void)productInfoSmartOptionTableViewCell:(CPProductInfoSmartOptionTableViewCell *)cell didClickedOptionDetailButton:(ProductSmartOptionModel *)option
{
    DELEGATE_CALL2(_delegate,
                   productInfoSmartOptionView
                   : didClickedOptionDetailButton:,
                   self,
                   option);
}

- (void)productInfoSmartOptionTableViewCell:(CPProductInfoSmartOptionTableViewCell *)cell didClickedOptionSelectButton:(ProductSmartOptionModel *)option
{
    DELEGATE_CALL2(_delegate,
                   productInfoSmartOptionView
                   : didClickedOptionSelectButton:,
                   self,
                   option);
}

#pragma mark - InfoDescriptCouponViewDelegate

//- (void)infoDescriptCouponView:(InfoDescriptCouponView *)view didChangedViewHeight:(NSNumber *)height
//{
//    CGRect newFrame = _headerView.frame;
//    newFrame.size.height += [height floatValue];
//    _headerView.frame = newFrame;
//    
//    newFrame = _couponsView.frame;
//    newFrame.size.height = [height floatValue];
//    _couponsView.frame = newFrame;
//    
//    _tableView.tableHeaderView = _headerView;
//}

#pragma mark - InfoDescriptEncoreViewDelegate

//- (void)infoDescriptEncoreView:(InfoDescriptEncoreView *)view didChangedViewHeight:(NSNumber *)height
//{
//    CGRect newFrame = _headerView.frame;
//    newFrame.size.height += [height floatValue];
//    _headerView.frame = newFrame;
//    
//    newFrame = _encoreDealView.frame;
//    newFrame.size.height = [height floatValue];
//    _encoreDealView.frame = newFrame;
//    
//    _tableView.tableHeaderView = _headerView;
//}

#pragma mark - InfoDescriptBottomViewDelegate

//- (void)InfoDescriptBottomView:(InfoDescriptBottomView *)view addContentHeight:(NSNumber *)height
//{
//    _footerViewHeight += [height floatValue];
//    
//    CGRect newFrame = _descriptBottomView.frame;
//    newFrame.size.height = _footerViewHeight;
//    _descriptBottomView.frame = newFrame;
//    _tableView.tableFooterView = _descriptBottomView;
//}

//- (void)InfoDescriptBottomView:(InfoDescriptBottomView *)item moveMorePage:(NSString *)typeStr
//{
//    DELEGATE_CALL2(_delegate,
//                   productInfoSmartOptionView
//                   : moveMorePage:,
//                   self,
//                   typeStr);
//}
//
//- (void)InfoDescriptBottomView:(InfoDescriptBottomView *)view moveUrl:(NSString *)url
//{
//    DELEGATE_CALL2(_delegate,
//                   productInfoSmartOptionView
//                   : moveUrl:,
//                   self,
//                   url);
//}
//
//- (void)InfoDescriptBottomView:(InfoDescriptBottomView *)view moveProductDetailController:(NSString *)prdNo
//{
//    DELEGATE_CALL2(_delegate,
//                   productInfoSmartOptionView
//                   : moveProductDetailController:,
//                   self,
//                   prdNo);
//}
//
//- (void)InfoDescriptBottomView:(InfoDescriptBottomView *)view moveProductDetailControllerWithDict:(NSDictionary *)prdDict
//{
//    DELEGATE_CALL2(_delegate,
//                   productInfoSmartOptionView
//                   : moveProductDetailControllerWithDict:,
//                   self,
//                   prdDict);
//}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(productInfoSmartOptionView:scrollViewDidScroll:)]) {
        [self.delegate productInfoSmartOptionView:self scrollViewDidScroll:scrollView];
        
    }
//    DELEGATE_CALL2(_delegate,
//                   productInfoSmartOptionView
//                   : scrollViewDidScroll:,
//                   self,
//                   scrollView);
}

@end