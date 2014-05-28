CycleScrollView
===============
滚动图片的ScrollView + PageView
------

#如何使用
    
1、在类里引入
```#import XLCycleScrollView.h ```

2、实现代理方法:
```- (NSInteger)numberOfPages;```
```- (UIView *)pageAtIndex:(NSInteger)index;```
点击事件(可以不实现)：
```- (void)didClickPage:(XLCycleScrollView *)csView atIndex:(NSInteger)index;```

3、取消引用计数
在类的```- (void)dealloc```方法中，调用```[XLCycleScrollView free]``
