//
//  UIScrollView+MultipleScrollView.h
//  ZZPagingView
//
//  Created by zerry on 2021/4/25.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (MultipleScrollView)

- (CGFloat)maxContentOffsetY;
- (BOOL)isReachBottom;
- (BOOL)isReachTop;
- (void)scrollToTopWithAnimated:(BOOL)animated;

@end

@interface UIView (MultipleScrollView)
- (UITableViewCell *)getCell;

@end
