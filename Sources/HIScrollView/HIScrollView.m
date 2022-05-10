//
//  HIScrollView.m
//  Infinite Scroll View
//
//  Created by Nahidul Islam Raffi on 1/1/21.
//

#import "HIScrollView.h"
#import "HIScrollViewChild.h"

@implementation HIScrollView {
    struct {
        unsigned int sizeForItemAt:1;
        unsigned int interItemSpacingIn:1;
    } delegateRespondsTo;
    
    struct {
        unsigned int numberOfItemsIn:1;
        unsigned int viewForItemAt:1;
    } dataSourceRespondsTo;
}

@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;

- (void)setDelegate:(id<HIScrollViewDelegate>)delegate
{
    if (![self.delegate isEqual:delegate])
    {
        _delegate = delegate;
        super.delegate = delegate;
        
        delegateRespondsTo.sizeForItemAt = [delegate respondsToSelector:@selector(horizontalInfiniteScrollView:sizeForItemAt:)];
        delegateRespondsTo.interItemSpacingIn = [delegate respondsToSelector:@selector(interItemSpacingIn:)];
    }
}

- (BOOL)hasDelegateConformedCompletely
{
    if (!delegateRespondsTo.interItemSpacingIn || !delegateRespondsTo.sizeForItemAt)
    {
        return NO;
    }
    return YES;
}

- (void)setDataSource:(id<HIScrollViewDataSource>)dataSource
{
    if (![self.dataSource isEqual:dataSource])
    {
        _dataSource = dataSource;
        
        dataSourceRespondsTo.numberOfItemsIn = [dataSource respondsToSelector:@selector(numberOfItemsIn:)];
        dataSourceRespondsTo.viewForItemAt = [dataSource respondsToSelector:@selector(horizontalInfiniteScrollView:viewForItemAt:)];
    }
}

- (BOOL) hasDataSourceConformedCompletely
{
    if (!dataSourceRespondsTo.viewForItemAt || !dataSourceRespondsTo.numberOfItemsIn)
    {
        return NO;
    }
    return YES;
}

#pragma mark- Initializer
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _visibleViews = [[NSMutableArray alloc] init];
        
        _containerView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.containerView setBackgroundColor:UIColor.clearColor];
        
        [self addSubview:self.containerView];
        
        [NSLayoutConstraint activateConstraints:@[
            [self.containerView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [self.containerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [self.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor],
            [self.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor]
        ]];
    
        [self setShowsHorizontalScrollIndicator:NO];
        [self setShowsVerticalScrollIndicator:NO];
    }
    return self;
}

#pragma mark- Layout

- (void)recenterIfNecessary
{
    CGPoint currentOffset = [self contentOffset];
    CGFloat contentWidth = [self contentSize].width;
    CGFloat centerOffsetX = (contentWidth - [self bounds].size.width) / 2.0;
    CGFloat distanceFromCenter = fabs(currentOffset.x - centerOffsetX);
    
    if (distanceFromCenter > (contentWidth / 4.0)) {
        self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
        
        for (UIView *view in self.visibleViews) {
            CGPoint center = [self.containerView convertPoint:view.center toView:self];
            center.x += (centerOffsetX - currentOffset.x);
            view.center = [self convertPoint:center toView:self.containerView];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self recenterIfNecessary];
    
    CGRect visibleBounds = [self convertRect:[self bounds] toView:self.containerView];
    CGFloat minimumVisibleX = ceil(CGRectGetMinX(visibleBounds));
    CGFloat maximumVisibleX = ceil(CGRectGetMaxX(visibleBounds));
    
    [self placeViewsFromMinX:minimumVisibleX toMaxX:maximumVisibleX];
}

- (BOOL)shouldProcedeWithCalculation
{
    if ([self hasDelegateConformedCompletely] && [self hasDataSourceConformedCompletely] && [self.dataSource numberOfItemsIn:self] > 0)
    {
        return YES;
    }
    return NO;
}


#pragma mark- View Tiling

- (NSInteger)getItemIndex:(NSInteger) rawIndex
{
    if (!dataSourceRespondsTo.numberOfItemsIn || [self.dataSource numberOfItemsIn:self] <= 0)
    {
        return rawIndex;
    }
    
    NSInteger itemCount = [self.dataSource numberOfItemsIn:self];
    NSInteger remainder = rawIndex % itemCount;
    
    if (rawIndex < 0) {
        return itemCount + remainder;
    }
    
    return remainder;
}

- (HIScrollViewChild *)insertViewForItemAt:(NSInteger) index
{
    if (!dataSourceRespondsTo.viewForItemAt)
    {
        return [[HIScrollViewChild alloc] init];
    }
    
    HIScrollViewChild *view = [self.dataSource horizontalInfiniteScrollView:self viewForItemAt:index];
    view.shownItemIndex = index;
    [self.containerView addSubview:view];
    return view;
}

- (HIScrollViewChild *)placeViewOnLeftof:(NSInteger) index
                      ofEdge:(CGFloat) leftEdge;
{
    if (![self hasDelegateConformedCompletely])
    {
        return 0;
    }
    
    NSInteger refinedIndex = [self getItemIndex:index - 1];
    HIScrollViewChild *view = [self insertViewForItemAt:refinedIndex];
    [self.visibleViews insertObject:view atIndex:0];
    
    CGSize viewSize = [self.delegate horizontalInfiniteScrollView:self sizeForItemAt:refinedIndex];
    CGFloat itemSpacing = [self.delegate interItemSpacingIn:self];
    
    CGRect frame = [view frame];
    frame.origin.x = leftEdge - itemSpacing - viewSize.width;
    frame.origin.y = [self.containerView bounds].size.height - viewSize.height;
    frame.size.width = viewSize.width;
    frame.size.height = viewSize.height;
    [view setFrame:frame];
    
    return view;
}

- (HIScrollViewChild *)placeViewOnRightOf:(NSInteger) index
                       ofEdge:(CGFloat) rightEdge;
{
    if (![self hasDelegateConformedCompletely])
    {
        return 0;
    }
    
    NSInteger refinedIndex = [self getItemIndex:index + 1];
    HIScrollViewChild *view = [self insertViewForItemAt:refinedIndex];
    [self.visibleViews addObject:view];
    
    CGSize viewSize = [self.delegate horizontalInfiniteScrollView:self sizeForItemAt:refinedIndex];
    CGFloat itemSpacing = [self.delegate interItemSpacingIn:self];
    
    CGRect frame = [view frame];
    frame.origin.x = rightEdge + itemSpacing;
    frame.origin.y = [self.containerView bounds].size.height - viewSize.height;
    frame.size.width = viewSize.width;
    frame.size.height = viewSize.height;
    [view setFrame:frame];
    
    return view;
}

- (void)placeViewsFromMinX:(CGFloat) minimumVisibleX
                    toMaxX:(CGFloat) maximumVisibleX
{
    if (![self shouldProcedeWithCalculation])
    {
        return;
    }
    
    if ([self.visibleViews count] == 0)
    {
        [self placeViewOnRightOf:-1 ofEdge:minimumVisibleX];
    }
    
    CGFloat interItemSpacing = [self.delegate interItemSpacingIn:self];
    
    HIScrollViewChild *lastView = [self.visibleViews lastObject];
    CGFloat rightEdge = ceil(CGRectGetMaxX([lastView frame]));
    while (rightEdge + interItemSpacing < maximumVisibleX)
    {
        lastView = [self placeViewOnRightOf:[lastView shownItemIndex] ofEdge:rightEdge];
        rightEdge = CGRectGetMaxX([lastView frame]);
    }
    
    HIScrollViewChild *firstView = [self.visibleViews firstObject];
    CGFloat leftEdge = ceil(CGRectGetMinX([firstView frame]));
    while (leftEdge - interItemSpacing > minimumVisibleX)
    {
        firstView = [self placeViewOnLeftof:[firstView shownItemIndex] ofEdge:leftEdge];
        leftEdge = CGRectGetMinX([firstView frame]);
    }
    
    lastView = [self.visibleViews lastObject];
    while(ceil(CGRectGetMinX([lastView frame])) >= maximumVisibleX)
    {
        [lastView removeFromSuperview];
        [self.visibleViews removeLastObject];
        lastView = [self.visibleViews lastObject];
    }
    
    firstView = [self.visibleViews firstObject];
    while(ceil(CGRectGetMaxX([firstView frame])) <= minimumVisibleX)
    {
        [firstView removeFromSuperview];
        [self.visibleViews removeObjectAtIndex:0];
        firstView = [self.visibleViews firstObject];
    }
}

#pragma mark- Reload
-(void)reloadData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (HIScrollViewChild* view in self.visibleViews)
        {
            [view removeFromSuperview];
        }
        
        [self.visibleViews removeAllObjects];
        [self setNeedsLayout];
    });
}

#pragma mark- Scrolling
-(void)scrollToNextItemAnimated:(BOOL) flag
{
    if (![self shouldProcedeWithCalculation])
    {
        return;
    }
    
    CGPoint currentOffset = [self contentOffset];
    
    HIScrollViewChild *view = [self.visibleViews firstObject];
    CGFloat viewLeftEdge = CGRectGetMinX(view.frame);
    
    CGFloat distanceToMove = (viewLeftEdge - currentOffset.x) + [view frame].size.width;
    
    CGFloat newOffsetX = currentOffset.x + distanceToMove;
    [self setContentOffset:CGPointMake(newOffsetX, currentOffset.y) animated:flag];
}

-(void)scrollToPreviousItemAnimated:(BOOL) flag
{
    if (![self shouldProcedeWithCalculation])
    {
        return;
    }
    
    CGPoint currentOffset = [self contentOffset];
    
    CGFloat interItemSpacing = [self.delegate interItemSpacingIn:self];
    
    HIScrollViewChild *view = [self.visibleViews firstObject];
    CGFloat viewLeftEdge = CGRectGetMinX(view.frame);
    CGFloat distance = fabs(currentOffset.x - viewLeftEdge);
    
    CGFloat distanceToMove = 0;
    
    if (viewLeftEdge >= currentOffset.x) {
        NSInteger nextIndex = [self getItemIndex:[view shownItemIndex] - 1];
        CGFloat nextItemWidth = [self.delegate horizontalInfiniteScrollView:self sizeForItemAt:nextIndex].width;
        
        distanceToMove = (interItemSpacing * 2) + nextItemWidth - distance;
    }else {
        distanceToMove = distance + interItemSpacing;
    }
    
    CGFloat newOffsetX = currentOffset.x - distanceToMove;;
    [self setContentOffset:CGPointMake(newOffsetX, currentOffset.y) animated:flag];
}

@end
