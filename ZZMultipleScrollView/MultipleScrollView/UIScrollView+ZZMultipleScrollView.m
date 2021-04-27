//
//  UIScrollView+ZZMultipleScrollView.m
//  ScrollViewNestDemo
//
//  Created by XuNing on 2017/11/12.
//  Copyright © 2017年 xuning. All rights reserved.
//

#import "UIScrollView+ZZMultipleScrollView.h"

@implementation UIScrollView (Demo)

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
