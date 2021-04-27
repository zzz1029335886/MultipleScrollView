//
//  ZZMultipleScrollView.h
//  ZZPagingView
//
//  Created by zerry on 2021/4/25.
//

#import <UIKit/UIKit.h>
@protocol ZZMultipleScrollViewDataSource,ZZMultipleScrollViewDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface ZZMultipleScrollView : UIView
@property (nonatomic, weak, nullable) id <ZZMultipleScrollViewDataSource> dataSource;
@property (nonatomic, weak, nullable) id <ZZMultipleScrollViewDelegate> delegate;
@property (nonatomic, strong, readonly) UITableView *tableView;

- (void)reload;
- (void)scrollBottom;
- (void)scrollTop;

@end


@protocol ZZMultipleScrollViewDataSource<NSObject>
@required
- (NSInteger)multipleScrollView:(ZZMultipleScrollView *)multipleScrollView numberOfRowsInSection:(NSInteger)section;
- (UIView *)multipleScrollView:(ZZMultipleScrollView *)multipleScrollView viewForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (NSInteger)numberOfScrollSectionsInMultipleScrollView:(ZZMultipleScrollView *)multipleScrollView;              // Default is 1 if not implemented
@end


@protocol ZZMultipleScrollViewDelegate<NSObject, UIScrollViewDelegate>
@optional
- (nullable UIView *)multipleScrollView:(ZZMultipleScrollView *)multipleScrollView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
- (nullable UIView *)multipleScrollView:(ZZMultipleScrollView *)multipleScrollView viewForFooterInSection:(NSInteger)section;   // custom view for footer. will be adjusted to default or specified footer height
- (CGFloat)multipleScrollView:(ZZMultipleScrollView *)multipleScrollView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)multipleScrollView:(ZZMultipleScrollView *)multipleScrollView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)multipleScrollView:(ZZMultipleScrollView *)multipleScrollView heightForFooterInSection:(NSInteger)section;

- (CGFloat)multipleScrollView:(ZZMultipleScrollView *)multipleScrollView scrollToLastBottom:(UITableView *)tableView;
- (CGFloat)multipleScrollView:(ZZMultipleScrollView *)multipleScrollView scrollToTop:(UITableView *)tableView;

- (void)multipleScrollView:(ZZMultipleScrollView *)multipleScrollView willScrollToBottomInView:(UIView *)view forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)multipleScrollView:(ZZMultipleScrollView *)multipleScrollView willDisplayView:(UIView *)view forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)multipleScrollView:(ZZMultipleScrollView *)multipleScrollView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section;

@end

NS_ASSUME_NONNULL_END
