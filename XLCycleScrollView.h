//
//  XLCycleScrollView.h
//

#import <UIKit/UIKit.h>

@class XLCycleScrollView;

@protocol XLCycleScrollViewDelegate <NSObject>
@optional
- (void)didClickPage:(XLCycleScrollView *)csView atIndex:(NSInteger)index;
@end

@protocol XLCycleScrollViewDatasource <NSObject>
@required
- (NSInteger)numberOfPages;
- (UIView *)pageAtIndex:(NSInteger)index;
@end

@interface XLCycleScrollView : UIView<UIScrollViewDelegate>

@property (nonatomic,assign) id<XLCycleScrollViewDatasource> datasource;
@property (nonatomic,assign) id<XLCycleScrollViewDelegate> delegate;

//两个View翻页时间间隔
@property (assign, nonatomic) NSTimeInterval animationInterval;
//View翻页时间
@property (assign, nonatomic) CGFloat animateDuration;

//NSTimer停止
- (void)free;
//暂停翻滚
- (void)pause;
//继续翻滚
- (void)resume;
//reload数据
- (void)reloadData;

@end


