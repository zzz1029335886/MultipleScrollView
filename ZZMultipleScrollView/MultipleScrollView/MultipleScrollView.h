//
//  MultipleScrollView.h
//  ZZPagingView
//
//  Created by zerry on 2021/4/25.
//

#import <UIKit/UIKit.h>
@protocol MultipleScrollViewDataSource,MultipleScrollViewDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface MultipleScrollView : UIView
@property (nonatomic, weak, nullable) id <MultipleScrollViewDataSource> dataSource;
@property (nonatomic, weak, nullable) id <MultipleScrollViewDelegate> delegate;
@property (nonatomic, strong, readonly) UITableView *tableView;

- (void)reload;
- (void)scrollBottom;
- (void)scrollTop;
+ (nullable UITableViewCell *)getCell:(UIView *)view;

@end


@protocol MultipleScrollViewDataSource<NSObject>
@required
- (NSInteger)multipleScrollView:(MultipleScrollView *)multipleScrollView numberOfRowsInSection:(NSInteger)section;
- (UIView *)multipleScrollView:(MultipleScrollView *)multipleScrollView viewForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (NSInteger)numberOfScrollSectionsInMultipleScrollView:(MultipleScrollView *)multipleScrollView;              // Default is 1 if not implemented
@end


@protocol MultipleScrollViewDelegate<NSObject, UIScrollViewDelegate>
@optional
- (nullable UIView *)multipleScrollView:(MultipleScrollView *)multipleScrollView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
- (nullable UIView *)multipleScrollView:(MultipleScrollView *)multipleScrollView viewForFooterInSection:(NSInteger)section;   // custom view for footer. will be adjusted to default or specified footer height
- (CGFloat)multipleScrollView:(MultipleScrollView *)multipleScrollView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)multipleScrollView:(MultipleScrollView *)multipleScrollView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)multipleScrollView:(MultipleScrollView *)multipleScrollView heightForFooterInSection:(NSInteger)section;

/// 滚到底部的事件
/// @param multipleScrollView 返回值表示距离底部的位置，-1表示无间距
/// @param tableView tableView
- (CGFloat)multipleScrollView:(MultipleScrollView *)multipleScrollView scrollToLastBottom:(UITableView *)tableView;

/// 滚到顶部的事件，返回值表示距离顶部的位置，-1表示无间距
/// @param multipleScrollView 当前
/// @param tableView tableView
- (CGFloat)multipleScrollView:(MultipleScrollView *)multipleScrollView scrollToTop:(UITableView *)tableView;

/// 即将滚到底部的view
/// @param multipleScrollView 当前
/// @param view view
/// @param indexPath 位置
- (void)multipleScrollView:(MultipleScrollView *)multipleScrollView willScrollToBottomInView:(UIView *)view forRowAtIndexPath:(NSIndexPath *)indexPath;

/// 即将显示的view
/// @param multipleScrollView 当前
/// @param view view
/// @param indexPath 位置
- (void)multipleScrollView:(MultipleScrollView *)multipleScrollView willDisplayView:(UIView *)view forRowAtIndexPath:(NSIndexPath *)indexPath;

/// 即将显示的headerView
/// @param multipleScrollView 当前multipleScrollView
/// @param view headerView
/// @param section section
- (void)multipleScrollView:(MultipleScrollView *)multipleScrollView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section;

@end

NS_ASSUME_NONNULL_END
