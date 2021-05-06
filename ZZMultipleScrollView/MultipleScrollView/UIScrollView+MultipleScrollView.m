//
//  UIScrollView+MultipleScrollView.m
//  ZZPagingView
//
//  Created by zerry on 2021/4/25.
//

#import "UIScrollView+MultipleScrollView.h"

@implementation UIScrollView (MultipleScrollView)

- (CGFloat)maxContentOffsetY {
    return MAX(0, self.contentSize.height - self.frame.size.height);
}

- (BOOL)isReachBottom {
    BOOL bool1 = self.contentOffset.y > ([self maxContentOffsetY]);
    BOOL bool2 = abs(self.contentOffset.y - [self maxContentOffsetY]) < FLT_EPSILON;
    return  bool1 || bool2;
}

- (BOOL)isReachTop {
    return self.contentOffset.y <= 0;
}

- (void)scrollToTopWithAnimated:(BOOL)animated {
    [self setContentOffset:CGPointZero animated:animated];
}

@end

@implementation UIView (MultipleScrollView)

- (UITableViewCell *)getCell{
    UIView *view = self;
    while (![view isKindOfClass:UITableViewCell.class]) {
        
        view = view.superview;
        if (!view) {
            return nil;
        }
    }
    return (UITableViewCell *)view;
}

@end
