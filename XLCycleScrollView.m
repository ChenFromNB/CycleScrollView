//
//  XLCycleScrollView.m
//

#import "XLCycleScrollView.h"
#import "NSTimer+Addition.h"

@interface XLCycleScrollView()
{
    NSInteger _totalPages;
    NSInteger _curPage;
    NSMutableArray *_curViews;
}

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (assign, nonatomic) NSInteger currentPage;

@property (strong, nonatomic) NSTimer *animationTimer;

@end

@implementation XLCycleScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(self.frame.size.width * 3, self.frame.size.height);
        _scrollView.showsHorizontalScrollIndicator = NO;//水平线
        _scrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
        _scrollView.pagingEnabled = YES;
        [self addSubview:_scrollView];
        
        CGRect rect = CGRectMake(80, self.bounds.size.height - 20, 160, 20);
        _pageControl = [[UIPageControl alloc] initWithFrame:rect];
        _pageControl.userInteractionEnabled = NO;
        [self addSubview:_pageControl];
        
        _curPage = 0;
        //自动翻页
        self.animationInterval = 1.5f;
        self.animateDuration = 2.0f;
//        if (self.animationInterval > 0.0) {
//            self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:self.animationInterval
//                                                                   target:self
//                                                                 selector:@selector(animationTimerDidFired:)
//                                                                 userInfo:nil
//                                                                  repeats:YES];
//        }
    }
    return self;
}

- (void)setAnimationInterval:(NSTimeInterval)animationInterval
{
    _animationInterval = animationInterval;
    [_animationTimer invalidate];
    if (self.animationInterval > 0) {
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:self.animationInterval
                                                               target:self
                                                             selector:@selector(animationTimerDidFired:)
                                                             userInfo:nil
                                                              repeats:YES];
    }
}

- (void)setDatasource:(id<XLCycleScrollViewDatasource>)datasource
{
    _datasource = datasource;
    [self reloadData];
}

- (void)reloadData
{
    _totalPages = [_datasource numberOfPages];
    if (_totalPages == 0) {
        return;
    }
    _pageControl.numberOfPages = _totalPages;
    [self loadData];
}

- (void)loadData
{
    _pageControl.currentPage = _curPage;
    
    //从scrollView上移除所有的subview
    NSArray *subViews = [_scrollView subviews];
    if([subViews count] != 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self getDisplayImagesWithCurpage:_curPage];
    
    for (int i = 0; i < 3; i++) {
        UIView *v = [_curViews objectAtIndex:i];
        v.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleTap:)];
        [v addGestureRecognizer:singleTap];
        v.frame = CGRectOffset(v.frame, v.frame.size.width * i, 0);
        [_scrollView addSubview:v];
    }
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
}

- (void)getDisplayImagesWithCurpage:(int)page
{
    int pre = [self validPageValue:_curPage-1];
    int last = [self validPageValue:_curPage+1];
    
    if (!_curViews) {
        _curViews = [[NSMutableArray alloc] init];
    }
    
    [_curViews removeAllObjects];
    [_curViews addObject:[_datasource pageAtIndex:pre]];
    [_curViews addObject:[_datasource pageAtIndex:page]];
    [_curViews addObject:[_datasource pageAtIndex:last]];
}

- (int)validPageValue:(NSInteger)value {
    
    if(value == -1) value = _totalPages - 1;
    if(value == _totalPages) value = 0;
    
    return value;
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    
    if ([_delegate respondsToSelector:@selector(didClickPage:atIndex:)]) {
        [_delegate didClickPage:self atIndex:_curPage];
    }
    
}

- (void)setViewContent:(UIView *)view atIndex:(NSInteger)index
{
    if (index == _curPage) {
        [_curViews replaceObjectAtIndex:1 withObject:view];
        for (int i = 0; i < 3; i++) {
            UIView *v = [_curViews objectAtIndex:i];
            v.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(handleTap:)];
            [v addGestureRecognizer:singleTap];
            v.frame = CGRectOffset(v.frame, v.frame.size.width * i, 0);
            [_scrollView addSubview:v];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    int x = aScrollView.contentOffset.x;
    
    //往下翻一张
    if(x >= (2*self.frame.size.width)) {
        _curPage = [self validPageValue:_curPage+1];
        [self loadData];
    }
    
    //往上翻
    if(x <= 0) {
        _curPage = [self validPageValue:_curPage-1];
        [self loadData];
    }
}

//ScrollView的手势操作
- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.animationTimer pauseTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.animationTimer resumeTimerAfterTimeInterval:self.animationInterval];
}

- (void)animationTimerDidFired:(NSTimer *)timer
{
    CGPoint newOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame) * 2, self.scrollView.contentOffset.y);
    _scrollView.delegate = nil;
    [self pause];

    [UIView animateWithDuration:self.animateDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.scrollView.contentOffset = newOffset;
                     }
                     completion:^(BOOL finished){
                         int x = _scrollView.contentOffset.x;
                         //往下翻一张
                         if(x >= (2*self.frame.size.width)) {
                             _curPage = [self validPageValue:_curPage+1];
                             [self loadData];
                         }
                         //往上翻
                         if(x <= 0) {
                             _curPage = [self validPageValue:_curPage-1];
                             [self loadData];
                         }
                         _scrollView.delegate = self;
                         [self resume];
                     }];
}

//暂停动画
- (void)pause
{
    [self.animationTimer pauseTimer];
}

//继续动画
- (void)resume
{
    [self.animationTimer resumeTimerAfterTimeInterval:self.animationInterval];
}

//减少父控件的引用计数
- (void)free
{
    [_animationTimer invalidate];
}

@end
