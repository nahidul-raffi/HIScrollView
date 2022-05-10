//
//  HIScrollView.h
//
//  Created by Nahidul Islam Raffi on 1/1/21.
//

#include "HIScrollViewChild.h"
#include "HIScrollViewDataSource.h"
#include "HIScrollViewDelegate.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HIScrollView : UIScrollView

@property (nonatomic, weak, nullable) IBOutlet id<HIScrollViewDataSource> dataSource;
@property (nonatomic, weak, nullable) IBOutlet id<HIScrollViewDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *visibleViews;
@property (nonatomic, strong) UIView *containerView;

-(void)reloadData;
-(void)scrollToNextItemAnimated:(BOOL) flag;
-(void)scrollToPreviousItemAnimated:(BOOL) flag;

@end

NS_ASSUME_NONNULL_END
