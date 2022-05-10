//
//  HIScrollViewChild.h
//  InfiniteScrollView
//
//  Created by Nahidul Islam Raffi on 1/1/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HIScrollViewChildType <NSObject>

@property (nonatomic, assign) NSInteger shownItemIndex;

@end

@interface HIScrollViewChild : UIView <HIScrollViewChildType>

@end

NS_ASSUME_NONNULL_END
