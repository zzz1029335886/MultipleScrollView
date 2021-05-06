//
//  MultipleScrollView.m
//  ZZPagingView
//
//  Created by zerry on 2021/4/25.
//

#import "MultipleScrollView.h"
#import "ZZDynamicItem.h"
#import <WebKit/WebKit.h>
#import "UIScrollView+MultipleScrollView.h"

typedef struct _IsBounceTopPadding {
    BOOL isBounce;
    BOOL isTop;
    CGFloat padding;
}IsBounceTopPadding;

@interface MultipleScrollView() <UIGestureRecognizerDelegate, UIDynamicAnimatorDelegate, UITableViewDelegate, UITableViewDataSource>{
    CGFloat HEIGHT;
    CGFloat WIDTH;
}

/// 主tableView
@property(nonatomic, strong) UITableView *mainTableView;
/// 手势
@property(nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property(nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@property(nonatomic, weak) UIDynamicItemBehavior *inertialBehavior;
@property(nonatomic, weak) UIAttachmentBehavior *bounceBehavior;
/// 边缘处能上拉或下拉的最大距离
@property(nonatomic) CGFloat bounceDistanceThreshold;
/// 边缘处能上拉或下拉的最大距离
@property(nonatomic,weak) UIView *firstSectionView;

/// 第一个scrollView到达顶部
- (BOOL)firstScrollViewIsReachTop;
/// 最后一个scrollView到达底部
- (BOOL)lastScrollViewIsReachBottom;

/// 所有view
@property(nonatomic, strong) NSArray<UIView *> *allView;
/// allView里插入包括了tableView
@property(nonatomic, strong) NSArray<UIView *> *includeTableViewViews;
/// 所有cell
@property(nonatomic, strong) NSArray<NSArray<UITableViewCell *> *> *cellsArray;
/// 最后一个cell，用于检测到达底部
@property(nonatomic, strong) UITableViewCell *lastCell;

@end

@implementation MultipleScrollView

#pragma mark - Getters
- (UIPanGestureRecognizer *)panRecognizer {
    if (!_panRecognizer) {
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
        _panRecognizer.delegate = self;
    }
    return _panRecognizer;
}

- (UIDynamicAnimator *)dynamicAnimator {
    if (!_dynamicAnimator) {
        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
        _dynamicAnimator.delegate = self;
    }
    return _dynamicAnimator;
}

- (UITableView *)tableView{
    return self.mainTableView;
}

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
//        _mainTableView.estimatedRowHeight = self.bounds.size.height;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTableView.rowHeight = UITableViewAutomaticDimension;
        if (@available(iOS 13.0, *)) {
            _mainTableView.automaticallyAdjustsScrollIndicatorInsets = NO;
        }
        if (@available(iOS 11.0, *)) {
            _mainTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _lastCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"lastCell"];
        
    }
    return _mainTableView;
}

- (NSArray<UIView *> *)allView{
    if (!_allView) {
        NSMutableArray<UIView *> *allView = [NSMutableArray array];
        NSMutableArray<UIView *> *includeTableViewViews = [NSMutableArray array];
        NSMutableArray<NSMutableArray<UITableViewCell *> *> *cellsArray = [NSMutableArray array];
        
        if (self.dataSource) {
            NSInteger numberOfSections = 1;
            
            if ([self.dataSource respondsToSelector:@selector(numberOfScrollSectionsInMultipleScrollView:)]) {
                numberOfSections = [self.dataSource numberOfScrollSectionsInMultipleScrollView:self];
            }
            for (int i = 0; i< numberOfSections; i++) {
                NSMutableArray<UITableViewCell *> *cells = [NSMutableArray array];
                NSInteger numberOfRowsInSection = [self.dataSource multipleScrollView:self numberOfRowsInSection:i];
                for (int j = 0; j < numberOfRowsInSection; j++) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                    UIView *view = [self.dataSource multipleScrollView:self viewForRowAtIndexPath: indexPath];
                    [allView addObject:view];
                    [includeTableViewViews addObject:view];
                    [includeTableViewViews addObject:self.mainTableView];
                    
                    UITableViewCell *cell = [self cellForIndexPath:indexPath];
                    [cells addObject:cell];
                }
                [cellsArray addObject:cells];
            }
        }
        [includeTableViewViews removeLastObject];
        
        _cellsArray = cellsArray;
        _allView = allView;
        _includeTableViewViews = includeTableViewViews;
    }
    return _allView;
}

/// 根据indexPath创建cell
/// @param indexPath 位置
- (UITableViewCell *)cellForIndexPath:(NSIndexPath *)indexPath{
    NSString *string = @"UITableViewCell";
    string = [string stringByAppendingFormat:@"%ld%ld", indexPath.section * 10000, indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:string];
    cell.contentView.autoresizingMask = UIViewAutoresizingNone;
    cell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    cell.contentView.autoresizesSubviews = NO;
    cell.contentView.tag = indexPath.section * 10000 + indexPath.row;
    [self equalSubView:cell.contentView superView:cell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

/// 第一个scrollView到达顶部
- (BOOL)firstScrollViewIsReachTop{
    if ([self.allView.firstObject isKindOfClass:UIScrollView.class]) {
        UIScrollView *firstScrollView = (UIScrollView *)self.allView.firstObject;
        return firstScrollView.isReachTop;
    } else {
        return YES;
    }
}

/// 最后一个scrollView到达底部
- (BOOL)lastScrollViewIsReachBottom{
    if ([self.allView.lastObject isKindOfClass:UIScrollView.class]) {
        UIScrollView *lastScrollView = (UIScrollView *)self.allView.lastObject;
        return lastScrollView.isReachBottom;
    } else {
        return YES;
    }
}

/// 根据view获取scrollView
/// @param view 需要传入view
- (UIScrollView *)getScrollView: (UIView *)view{
    if ([view isKindOfClass:UIScrollView.class]) {
        UIScrollView *scrollView = (UIScrollView *)view;
        return scrollView;
    } else if ([view isKindOfClass:WKWebView.class]){
        WKWebView *webView = (WKWebView *)view;
        return webView.scrollView;
    } else {
        return NULL;
    }
}

/// view是否到达顶部
/// @param view 判断的view
- (BOOL)isTouchTop: (UIView *)view{
    UITableViewCell *cell = [view getCell];
    if (!cell) {
        return NO;
    }
    
    CGFloat exitHeight = 0;
    if (cell.contentView.tag == 0) {
        UIView *view = self.mainTableView.tableHeaderView;
        if (view) {
            exitHeight = view.frame.size.height;
        }
//        if (self.firstSectionView) {
//            exitHeight += self.firstSectionView.frame.size.height;
//        }
        if ([self _abs:exitHeight - self.mainTableView.contentOffset.y] < 1){
            return YES;
        }
        return NO;
    }
    
    if ((cell.frame.origin.y - exitHeight) < self.mainTableView.contentOffset.y){
        return YES;
    }
    return NO;
}

/// 是否到达底部
/// @param view 判断的view
- (BOOL)isTouchBottom: (UIView *)view{
    UITableViewCell *cell = [view getCell];
    if (!cell) {
        return NO;
    }
    if (CGRectGetMaxY(cell.frame) > self.mainTableView.contentOffset.y + self.mainTableView.frame.size.height){
        return YES;
    }
    return NO;
}

/// view是否滚到自己的底部
/// @param view 判断的view
- (BOOL)isReachBottomView: (UIView *)view{
    UIScrollView *scrollView = [self getScrollView:view];
    if (scrollView) {
        return scrollView.isReachBottom;
    } else {
        return YES;
    }
}

/// view是否滚到自己的顶部
/// @param view 判断的view
- (BOOL)isReachTopView: (UIView *)view{
    UIScrollView *scrollView = [self getScrollView:view];
    if (scrollView) {
        return scrollView.isReachTop;
    }
    return YES;
}

- (void)setDataSource:(id<MultipleScrollViewDataSource>)dataSource{
    _dataSource = dataSource;
 
    _allView = nil;
    [self allView];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.bounceDistanceThreshold = self.frame.size.height * 0.66;
    HEIGHT = self.frame.size.height;
    WIDTH = self.frame.size.width;
}


- (void)dealloc {
    _panRecognizer.delegate = nil;
    NSLog(@"dealloc");
}

/// 刷新
- (void)reload;{
//    _mainTableView.estimatedRowHeight = self.bounds.size.height;
    
    _allView = nil;
   [self allView];
    
    [self.cellsArray enumerateObjectsUsingBlock:^(NSArray<UITableViewCell *> * _Nonnull array, NSUInteger idx, BOOL * _Nonnull stop) {
        [array enumerateObjectsUsingBlock:^(UITableViewCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
            cell.tag = 0;
        }];
    }];
    [self.mainTableView reloadData];
}

- (void)setupViews{
    if (!self.mainTableView.scrollEnabled) {
        return;
    }
    
    self.mainTableView.scrollEnabled = NO;
    self.mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:self.mainTableView];
    [self equalSubView:self.mainTableView superView:self];
    
    [self addGestureRecognizer:self.panRecognizer];
}

/// 滚动中，单击可以停止滚动
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.dynamicAnimator removeAllBehaviors];
}

#pragma mark - UIGestureRecognizerDelegate
/// 避免影响横滑手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:UIPanGestureRecognizer.class]) {
        CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self];
        return [self _abs:velocity.y] > [self _abs:velocity.x];
    } else {
        return YES;
    }
}

#pragma mark - UIDynamicAnimatorDelegate
/// 防止误触tableView的点击事件
- (void)dynamicAnimatorWillResume:(UIDynamicAnimator *)animator {
    self.mainTableView.userInteractionEnabled = NO;
    [self.allView enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.userInteractionEnabled = NO;
    }];
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator {
    self.mainTableView.userInteractionEnabled = YES;
    [self.allView enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.userInteractionEnabled = YES;
    }];
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            [self.dynamicAnimator removeAllBehaviors];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [recognizer translationInView:self];
            [self scrollViewsWithDeltaY:translation.y velocityY:[self _abs:[recognizer velocityInView:self].y] isBounce:NO];
            [recognizer setTranslation:CGPointZero inView:self];
        }
            break;
        case UIGestureRecognizerStateEnded: {
            // 这个if是为了避免在拉到边缘时，以一个非常小的初速度松手不回弹的问题
//            if ([self _abs:[recognizer velocityInView:self].y] < 120) {
//                if (self.firstScrollViewIsReachTop &&
//                    self.mainTableView.isReachTop) {
//                    [self performBounceForScrollView:self.mainTableView isAtTop:YES];
//                } else if (self.lastScrollViewIsReachBottom &&
//                           self.mainTableView.isReachBottom) {
//                    [self performBounceForScrollView:self.mainTableView isAtTop:NO];
//                }
//                [self isTopOrBottom];
//                return;
//            }
            IsBounceTopPadding result = [self paddingForTopOrBottom];
            if (!result.isBounce) {
                
                [self performBounceForScrollView:self.mainTableView isAtTop:result.isTop padding:result.padding];
                return;
            }
            CGFloat velocityY = [recognizer velocityInView:self].y;
            
            ZZDynamicItem *item = [[ZZDynamicItem alloc] init];
            item.center = CGPointZero;
            __block CGFloat lastCenterY = 0;
            UIDynamicItemBehavior *inertialBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[item]];
            inertialBehavior.elasticity = 1;
            
            [inertialBehavior addLinearVelocity:CGPointMake(0, -velocityY) forItem:item];
            inertialBehavior.resistance = 2;
            __weak typeof(self) weakSelf = self;
            inertialBehavior.action = ^{
                
                CGFloat deltaY = lastCenterY - item.center.y;
                [weakSelf scrollViewsWithDeltaY:deltaY velocityY: velocityY];
                lastCenterY = item.center.y;
                
            };
            self.inertialBehavior = inertialBehavior;
            [self.dynamicAnimator addBehavior:inertialBehavior];
            
        }
            break;
        default:
            break;
    }
}

/// 顶部或底部的间距，用于refreshHeader和refreshFooter
- (IsBounceTopPadding)paddingForTopOrBottom{
    IsBounceTopPadding result;
    result.isBounce = YES;
    result.isTop = YES;
    result.padding = 0;
    
    if (self.firstScrollViewIsReachTop &&
        self.mainTableView.isReachTop) {
        if ([self.delegate respondsToSelector:@selector(multipleScrollView:scrollToTop:)]) {
            CGFloat _padding = [self.delegate multipleScrollView:self scrollToTop:self.mainTableView];
            if (_padding <= 0) {
                result.isBounce = NO;
                [self performBounceForScrollView:self.mainTableView isAtTop:YES];
            }else{
                result.padding = _padding;
                result.isTop = YES;
                result.isBounce = NO;
            }
        }
    }else if (self.lastScrollViewIsReachBottom && self.mainTableView.isReachBottom) {
        
        if ([self.delegate respondsToSelector:@selector(multipleScrollView:scrollToLastBottom:)]) {
            CGFloat _padding = [self.delegate multipleScrollView:self scrollToLastBottom:self.mainTableView];
            if (_padding <= 0) {
                result.isBounce = NO;
                [self performBounceForScrollView:self.mainTableView isAtTop:NO];
            }else{
                result.padding = _padding;
                result.isTop = NO;
                result.isBounce = NO;
            }
        }
    }
    return result;
}

/// 滚到顶部
- (void)scrollTop{
    if (self.bounceBehavior) {
        [self.dynamicAnimator removeBehavior:self.bounceBehavior];
    }
    
    [self.mainTableView scrollToTopWithAnimated:YES];
}

/// 滚到底部
- (void)scrollBottom{
    if (self.bounceBehavior) {
        [self.dynamicAnimator removeBehavior:self.bounceBehavior];
    }
    [self bounceForScrollView:self.mainTableView isAtTop:NO padding:0];
}

/// <#Description#>
/// @param deltaY <#deltaY description#>
/// @param velocityY <#velocityY description#>
/// @param isBounce <#isBounce description#>
- (void)scrollViewsWithDeltaY:(CGFloat)deltaY velocityY: (CGFloat) velocityY isBounce:(BOOL) isBounce{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.includeTableViewViews];
    [array insertObject:self.mainTableView atIndex:0];
    [array addObject:self.mainTableView];
    NSLog(@"%lf", deltaY);
    
    if (deltaY < 0) { //上滑
        
        for (int i = 0; i< array.count; i++) {
            UIView *view = array[i];
            UIScrollView *scrollView = [self getScrollView:view];
            
            if ([self isReachBottomView:scrollView]) {
                if (i == array.count - 1) {
                    scrollView = self.mainTableView;
                    CGFloat bounceDelta = MAX(0, (self.bounceDistanceThreshold - [self _abs: (scrollView.contentOffset.y - scrollView.maxContentOffsetY)]) / self.bounceDistanceThreshold) * 0.5;
                    scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y - deltaY * bounceDelta);
                    [self performBounceIfNeededForScrollView:scrollView isAtTop:NO];
                } else {
                    continue;
                }
            }else {
                if (scrollView == self.mainTableView && i < array.count - 1) {
                    UIScrollView *nextScrollView = array[i + 1];
                    BOOL isTouchTop = [self isTouchTop:nextScrollView];
                    
                    if (isTouchTop) {
                        continue;
                    } else {
                        [self topPanScrollView:scrollView deltaY:deltaY];
                        return;
                    }
                } else {
                    [self topPanScrollView:scrollView deltaY:deltaY];
                    return;
                }
            }
        }
        
    } else if (deltaY > 0) { //下滑
        
        for (NSInteger i = array.count - 1; i >= 0; i--) {
            UIView *view = array[i];
            UIScrollView *scrollView = [self getScrollView:view];
            
            if ([self isReachTopView:scrollView]) {
                
                if (i == 0) {
                    scrollView = self.mainTableView;
                    CGFloat bounceDelta = MAX(0, (self.bounceDistanceThreshold - [self _abs:(scrollView.contentOffset.y)]) / self.bounceDistanceThreshold) * 0.5;
                    CGFloat y = scrollView.contentOffset.y - deltaY * bounceDelta;
                    scrollView.contentOffset = CGPointMake(0, y);
                    [self performBounceIfNeededForScrollView:scrollView isAtTop:YES];
                }else{
                    continue;
                }
            }else {
                if (scrollView == self.mainTableView && i > 0) {
                    UIScrollView *nextScrollView = array[i - 1];

                    BOOL isTouchBottom = [self isTouchBottom:nextScrollView];
                    
                    if (isTouchBottom) {
                        continue;
                    } else {
                        [self bottomPanScrollView:scrollView deltaY:deltaY];
                        return;
                    }
                }else{
                    [self bottomPanScrollView:scrollView deltaY:deltaY];
                    return;
                }
            }
        }
    }
}

- (void)scrollViewsWithDeltaY:(CGFloat)deltaY velocityY: (CGFloat) velocityY{
    [self scrollViewsWithDeltaY:deltaY velocityY:velocityY isBounce:NO];
}

/// scrollView向下滑
/// @param scrollView scrollView
/// @param deltaY 值
- (void)bottomPanScrollView:(UIScrollView *)scrollView deltaY:(CGFloat)deltaY{
    scrollView.contentOffset = CGPointMake(0, MAX(scrollView.contentOffset.y - deltaY, 0));
}
/// scrollView向上滑
/// @param scrollView scrollView
/// @param deltaY 值
- (void)topPanScrollView:(UIScrollView *)scrollView deltaY:(CGFloat)deltaY{
    scrollView.contentOffset = CGPointMake(0, MIN(scrollView.contentOffset.y - deltaY, scrollView.maxContentOffsetY));
}

/// 区分滚动到边缘处回弹 和 拉到边缘后以极小的初速度滚动
- (void)performBounceIfNeededForScrollView:(UIScrollView *)scrollView isAtTop:(BOOL)isTop{
    if (self.inertialBehavior) {
        [self performBounceForScrollView:scrollView isAtTop:isTop padding:0];
    }
}

/// scrollView滚到顶部或者底部
/// @param scrollView scrollView
/// @param isTop 是否顶部
- (void)performBounceForScrollView:(UIScrollView *)scrollView isAtTop:(BOOL)isTop{
    [self performBounceForScrollView:scrollView isAtTop:isTop padding:0];
}

/// <#Description#>
/// @param scrollView <#scrollView description#>
/// @param isTop <#isTop description#>
/// @param padding <#padding description#>
- (void)performBounceForScrollView:(UIScrollView *)scrollView isAtTop:(BOOL)isTop padding:(CGFloat)padding{
    if (!self.bounceBehavior) {
        [self bounceForScrollView:scrollView isAtTop:isTop padding:padding];
    }
}

- (void)bounceForScrollView:(UIScrollView *)scrollView isAtTop:(BOOL)isTop padding:(CGFloat)padding{
    if (self.inertialBehavior) {
        [self.dynamicAnimator removeBehavior:self.inertialBehavior];
    }
    
    if (self.bounceBehavior) {
        [self.dynamicAnimator addBehavior:self.bounceBehavior];
    }

    ZZDynamicItem *item = [[ZZDynamicItem alloc] init];
    CGPoint center = scrollView.contentOffset;
    item.center = center;
    CGFloat attachedToAnchorY = isTop ? -padding : scrollView.maxContentOffsetY + padding;
    UIAttachmentBehavior *bounceBehavior = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:CGPointMake(0, attachedToAnchorY)];
    bounceBehavior.length = 0;
    bounceBehavior.damping = 1;
    bounceBehavior.frequency = 2;
    __weak typeof(bounceBehavior) weakBounceBehavior = bounceBehavior;
    __weak typeof(self) weakSelf = self;
    bounceBehavior.action = ^{
        scrollView.contentOffset = CGPointMake(0, item.center.y);
        if ([self _abs:(scrollView.contentOffset.y - attachedToAnchorY)] < FLT_EPSILON) {
            [weakSelf.dynamicAnimator removeBehavior:weakBounceBehavior];
        }
    };
    self.bounceBehavior = bounceBehavior;
    [self.dynamicAnimator addBehavior:bounceBehavior];
}

- (void)disableDynamicAnimator {
    [self.dynamicAnimator removeAllBehaviors];
}

#pragma mark - UITableViewDelegate || UITableViewDataSource

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.delegate && ![self.delegate isEqual:self] && [self.delegate respondsToSelector: @selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == [self numberOfSectionsInTableView:tableView] - 1) {
        return [[UIView alloc]init];
    }
    
    
    if (self.delegate && [self.delegate respondsToSelector: @selector(multipleScrollView:viewForHeaderInSection:)]) {
        UIView *view = [self.delegate multipleScrollView:self viewForHeaderInSection:section];
        if (section == 0) {
            self.firstSectionView = view;
        }
        return view;
    } else {
        return nil;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == [self numberOfSectionsInTableView:tableView] - 1) {
        return 0.1;
    }
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector: @selector(multipleScrollView:heightForHeaderInSection:)]) {
            return [self.delegate multipleScrollView:self heightForHeaderInSection:section];
        } else if ([self.delegate respondsToSelector: @selector(multipleScrollView:viewForHeaderInSection:)]){
            if ([self.delegate multipleScrollView:self viewForHeaderInSection:section]){
                return UITableViewAutomaticDimension;
            }
        }
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (self.delegate) {
        if ([self.delegate respondsToSelector: @selector(multipleScrollView:viewForFooterInSection:)]) {
            return [self.delegate multipleScrollView:self viewForFooterInSection:section];
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == [self numberOfSectionsInTableView:tableView] - 1) {
        return 0.1;
    }

    if (self.delegate) {
        if ([self.delegate respondsToSelector: @selector(multipleScrollView:heightForFooterInSection:)]) {
            return [self.delegate multipleScrollView:self heightForFooterInSection:section];
        } else if ([self.delegate respondsToSelector: @selector(multipleScrollView:heightForFooterInSection:)]){
            if ([self.delegate multipleScrollView:self heightForFooterInSection:section]){
                return UITableViewAutomaticDimension;
            }
        }
    }
    return 0;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

    if (self.dataSource && [self.dataSource respondsToSelector: @selector(multipleScrollView:viewForRowAtIndexPath:)]) {
        UITableViewCell *cell = self.cellsArray[indexPath.section][indexPath.row];
        if (!cell) {
            cell = [self cellForIndexPath:indexPath];
            NSMutableArray<NSMutableArray<UITableViewCell *> *> *cells = [NSMutableArray arrayWithArray:self.cellsArray];
            cells[indexPath.section][indexPath.row] = cell;
        }
        
        if (cell.tag == 0) {
            UIView *contentView = [self.dataSource multipleScrollView:self viewForRowAtIndexPath:indexPath];
            contentView.translatesAutoresizingMaskIntoConstraints = NO;
            UIScrollView *scrollView = [self getScrollView:contentView];
            scrollView.scrollEnabled = NO;

            [cell.contentView removeConstraints:contentView.constraints];
            [cell.contentView addSubview:contentView];
            [self equalSubView:contentView superView:cell.contentView];
            if (scrollView.contentSize.height != 0 && scrollView.contentSize.height < scrollView.frame.size.height) {
                CGRect frame = scrollView.frame;
                frame.size.height = scrollView.contentSize.height;
                scrollView.frame = frame;
            }
            if (contentView.frame.size.height > 0) {
//                tableView.estimatedRowHeight = contentView.frame.size.height;
                [self constraintHeightWidthView:contentView];
            }
            cell.tag = 1;
        }
        
        return cell;
    }else{
        return [[UITableViewCell alloc]init];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate && [self.delegate respondsToSelector: @selector(multipleScrollView:heightForRowAtIndexPath:)]) {
        return [self.delegate multipleScrollView:self heightForRowAtIndexPath:indexPath];
    }else{
        return UITableViewAutomaticDimension;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == [self numberOfSectionsInTableView:tableView] - 1) {
        return 0;
    }
    
    if (self.dataSource && [self.dataSource respondsToSelector: @selector(multipleScrollView:numberOfRowsInSection:)]) {
        return [self.dataSource multipleScrollView:self numberOfRowsInSection:section];
    }else{
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    /// 多一个section，用于delegate滚到底部的willScrollToBottomInView
    if (self.dataSource ) {
        if ([self.dataSource respondsToSelector: @selector(numberOfScrollSectionsInMultipleScrollView:)]) {
            return [self.dataSource numberOfScrollSectionsInMultipleScrollView:self] + 1;
        } else {
            return 2;
        }
    }else{
        return 2;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(multipleScrollView:willScrollToBottomInView:forRowAtIndexPath:)]) {
        if ((indexPath.section + indexPath.row) > 0) {
            
            NSInteger section = 0;
            NSInteger row = 0;
            BOOL hasHeaderView = NO;
            if (indexPath.row > 0) {
                section = indexPath.section;
                row = indexPath.row - 1;
            }else if (indexPath.section > 0) {
                if ([self.delegate respondsToSelector:@selector(multipleScrollView:viewForHeaderInSection:)] && [self.delegate multipleScrollView:self viewForHeaderInSection:indexPath.section]) {
                    hasHeaderView = YES;
                }else{
                    section = indexPath.section - 1;
                    
                    NSArray<UITableViewCell *> *sectionCells;
                    for (NSInteger i = section; i >= 0; i--) {
                        NSArray *array = self.cellsArray[i];
                        if (array.count) {
                            sectionCells = array;
                            section = i;
                            break;
                        }
                    }

                    if (sectionCells) {
                        row = self.cellsArray[section].count - 1;
                    }
                }
            }
            
            if (!hasHeaderView && section >= 0 && row >= 0) {
                UITableViewCell *cell = self.cellsArray[section][row];
                UIView *view = [self getViewFromCell: cell];
                    
                if (view) {
                    [self.delegate multipleScrollView:self willScrollToBottomInView:view forRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                }
            }
            
        }
    }
    
    if (indexPath.section == [self numberOfSectionsInTableView:tableView] - 1) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(multipleScrollView:willDisplayView:forRowAtIndexPath:)]) {
        UIView *view = [self getViewFromCell:cell];
        [self.delegate multipleScrollView:self willDisplayView:view forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    
    if ([self.delegate respondsToSelector:@selector(multipleScrollView:willScrollToBottomInView:forRowAtIndexPath:)]) {
        if (section > 0) {
            NSArray<UITableViewCell *> *sectionCells = self.cellsArray[section - 1];
            if (sectionCells.lastObject) {
                UIView *view = [self getViewFromCell:sectionCells.lastObject];
                [self.delegate multipleScrollView:self willScrollToBottomInView:view forRowAtIndexPath:[NSIndexPath indexPathForRow:sectionCells.count - 1 inSection:section - 1]];
            }
        }
    }
    
    if (section == [self numberOfSectionsInTableView:tableView] - 1) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(multipleScrollView:willDisplayHeaderView:forSection:)]) {
        [self.delegate multipleScrollView:self willDisplayHeaderView:view forSection:section];
    }
}

- (UIView *)getViewFromCell:(UITableViewCell *)cell{
    return cell.contentView.subviews.firstObject;
}

- (void)equalSubView: (UIView *)subView
           superView: (UIView *)superView {
    NSLayoutConstraint *botttom = [self equalSubView:subView superView:superView attribute:NSLayoutAttributeBottom];
    
    [superView addConstraints:@[
        [self equalSubView:subView superView:superView attribute:NSLayoutAttributeTop],
        botttom,
        [self equalSubView:subView superView:superView attribute:NSLayoutAttributeLeading],
        [self equalSubView:subView superView:superView attribute:NSLayoutAttributeTrailing]
    ]];
}

- (NSLayoutConstraint *)equalSubView: (UIView *)subView
                           superView: (UIView *)superView
                           attribute: (NSLayoutAttribute)attribute {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:subView
                                                                  attribute:attribute
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:superView
                                                                  attribute:attribute
                                                                 multiplier:1
                                                                   constant:0];
    return constraint;
}

- (void)constraintHeightWidthView:(UIView *) view{
    for (NSLayoutConstraint *constraint in view.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeWidth) {
            [view removeConstraint:constraint];
        }else if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            [view removeConstraint:constraint];
        }
    }
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:0.0
                                                                         constant:view.frame.size.height];
    heightConstraint.priority = UILayoutPriorityDefaultHigh;
    [view addConstraint:heightConstraint];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:0.0
                                                                        constant:view.frame.size.width];
    widthConstraint.priority = UILayoutPriorityDefaultHigh;
    [view addConstraint:widthConstraint];
}

- (CGFloat)_abs:(CGFloat)value{
    return abs(value);
}

@end

