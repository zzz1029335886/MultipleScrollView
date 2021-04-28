//
//  DynamicItem.m
//  ZZPagingView
//
//  Created by zerry on 2021/4/25.
//

#import "ZZDynamicItem.h"

@implementation ZZDynamicItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _bounds = CGRectMake(0, 0, 1, 1);
    }
    return self;
}

@end
