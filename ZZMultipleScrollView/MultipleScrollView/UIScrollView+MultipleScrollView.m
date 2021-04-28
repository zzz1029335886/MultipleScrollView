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
    return self.contentOffset.y > ([self maxContentOffsetY]) ||
    abs(self.contentOffset.y - [self maxContentOffsetY]) < FLT_EPSILON;
}

- (BOOL)isReachTop {
    return self.contentOffset.y <= 0;
}

- (void)scrollToTopWithAnimated:(BOOL)animated {
    [self setContentOffset:CGPointZero animated:animated];
}

@end
