#import <UIKit/UIKit.h>

@class CPProductOption;
@class CPWebView;

@protocol CPProductOptionItemDelegate;

@interface CPProductOptionItem : UIView

@property (nonatomic, weak) id<CPProductOptionItemDelegate> delegate;
@property (nonatomic, strong) NSString *searchWord;
@property (nonatomic, strong) NSMutableDictionary *productOptionInfo;


- (id)initWithFrame:(CGRect)frame productOptionRawData:(NSDictionary *)productOptionRawData;
- (void)reloadOptionItemView:(NSDictionary *)productOptionRawData;
- (void)redrawTableContainerFrame:(CGRect)frame;

@end

@protocol CPProductOptionItemDelegate <NSObject>
@optional
- (void)optionItem:(CPProductOptionItem *)optionItem textFieldShouldBeginEditing:(BOOL)isEdit;
- (void)optionItem:(CPProductOptionItem *)optionItem didSelectOptionItem:(NSDictionary *)items selectedRow:(NSInteger)selectedRow isConfirm:(BOOL)isConfirm;
- (void)optionItem:(CPProductOptionItem *)optionItem textFieldShouldReturn:(NSString *)text selectedRow:(NSInteger)selectedRow;
- (void)optionItemDidCancel:(CPProductOptionItem *)optionItem;

- (void)didTouchCloseDrawerButton;
- (void)didTouchOpenDrawerButton;

@end
