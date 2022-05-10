//
//  HIScrollViewDelegate.h
//  
//
//  Created by Nahidul Islam Raffi on 10/5/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HIScrollView, HIScrollViewChild;

@protocol HIScrollViewDelegate<UIScrollViewDelegate>
@required
- (CGSize)horizontalInfiniteScrollView:(HIScrollView *) scrollView
                           sizeForItemAt: (NSInteger) index;
- (CGFloat)interItemSpacingIn:(HIScrollView *) scrollView;
@end

NS_ASSUME_NONNULL_END
