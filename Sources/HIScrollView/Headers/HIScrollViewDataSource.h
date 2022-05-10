//
//  HIScrollViewDataSource.h
//  
//
//  Created by Nahidul Islam Raffi on 10/5/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HIScrollView, HIScrollViewChild;

@protocol HIScrollViewDataSource<NSObject>
@required
- (NSInteger)numberOfItemsIn:(HIScrollView *) scrollView;
- (HIScrollViewChild *)horizontalInfiniteScrollView:(HIScrollView *) scrollView
                           viewForItemAt:(NSInteger) index;
@end

NS_ASSUME_NONNULL_END
