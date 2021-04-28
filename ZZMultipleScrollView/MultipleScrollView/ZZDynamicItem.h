//
//  ZZDynamicItem.h
//  ZZPagingView
//
//  Created by zerry on 2021/4/25.
//

#import <UIKit/UIKit.h>

@interface ZZDynamicItem : NSObject <UIDynamicItem>

@property (nonatomic, readwrite) CGPoint center;
@property (nonatomic, readonly) CGRect bounds;
@property (nonatomic, readwrite) CGAffineTransform transform;

@end
