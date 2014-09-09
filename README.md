CycleScrollView
===============
滚动图片的ScrollView + PageView
------


    
![结构](http://mypicturespace.qiniudn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202014-09-09%20%E4%B8%8B%E5%8D%885.17.29.png)
#如何使用
#####1、在类里引入
`import XLCycleScrollView.h`

#####2、实现代理方法:
```objectivec
- (NSInteger)numberOfPages;
- (UIView *)pageAtIndex:(NSInteger)index;
//optional
- (void)didClickPage:(XLCycleScrollView *)csView atIndex:(NSInteger)index;
```
可以定制控件的翻页时间间隔`animationInterval`和翻页时间`animateDuration`
#####3、remove a timer from the NSRunLoop object
在类的`- (void)dealloc`方法中，调用`[XLCycleScrollView free]`

