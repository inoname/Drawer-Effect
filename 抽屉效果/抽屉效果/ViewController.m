//
//  ViewController.m
//  抽屉效果
//
//  Created by kouliang on 14/12/26.
//  Copyright (c) 2014年 kouliang. All rights reserved.
//

//用KVO监听主视图的frame


#import "ViewController.h"

@interface ViewController ()
@property(nonatomic,weak)UIView *mainV;
@property(nonatomic,weak)UIView *leftV;
@property(nonatomic,weak)UIView *rightV;
@property(nonatomic,assign)BOOL isDraging;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1.添加子控件
    [self addChildView];
    // 2.用KVO监听主视图的frame
    // Observer:观察者
    // KeyPath:监听哪个属性
    // options:监听这个属性什么改变,监听新值的改变
    [_mainV addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)addChildView{
    // 左边视图
    UIView *leftV = [[UIView alloc] initWithFrame:self.view.bounds];
    leftV.backgroundColor = [UIColor greenColor];
    [self.view addSubview:leftV];
    _leftV = leftV;
    
    // 右边视图
    UIView *rightV = [[UIView alloc] initWithFrame:self.view.bounds];
    rightV.backgroundColor = [UIColor blueColor];
    [self.view addSubview:rightV];
    _rightV = rightV;
    
    // 主视图
    UIView *mainV = [[UIView alloc] initWithFrame:self.view.bounds];
    mainV.backgroundColor = [UIColor redColor];
    [self.view addSubview:mainV];
    _mainV = mainV;
}

// 只要一有新值就会调用观察者对象的方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"%@",NSStringFromCGRect(_mainV.frame));
    if (_mainV.frame.origin.x > 0) { // 显示左边视图
        _leftV.hidden = NO;
        _rightV.hidden = YES;
    }else if (_mainV.frame.origin.x < 0){ // 显示右边视图
        _leftV.hidden = YES;
        _rightV.hidden = NO;
    }
}

- (void)dealloc
{
    // 一定要记住移除观察者
    [_mainV removeObserver:self forKeyPath:@"frame"];
}

// 手指移动的时候调用
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isDraging = YES;
    // 获取UITouch对象
    UITouch *touche = [touches anyObject];
    
    // 获取当前触摸点
    CGPoint curP = [touche locationInView:self.view];
    // 获取上一次触摸点
    CGPoint preP = [touche previousLocationInView:self.view];
    
    // 获取x轴的偏移量
    CGFloat offsetX = curP.x - preP.x;
    
    //    CGRect frame = _mainV.frame;
    //    frame.origin.x += offsetX;
    // 设置当前主视图的frame
    _mainV.frame = [self frameWithOffsetX:offsetX];
    
    
}
#define maxY 60
#define screenW [UIScreen mainScreen].bounds.size.width
// 根据偏移量获取当前视图的frame
- (CGRect)frameWithOffsetX:(CGFloat)offsetX
{
    //    CGFloat screenW = h;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    // 获取x轴每偏移一点,y轴偏移多少
    CGFloat offsetY = offsetX * maxY / screenW;
    // 获取缩放比例
    CGFloat scale = (screenH - 2 * offsetY) / screenH;
    
    if (_mainV.frame.origin.x < 0) { // x< 0,缩放比例保持跟之前一样
        scale = (screenH + 2 * offsetY) / screenH;
    }
    
    // 获取当前视图frame
    CGRect frame = _mainV.frame;
    frame.origin.x += offsetX;
    frame.size.width = frame.size.width * scale;
    frame.size.height = frame.size.height * scale;
    frame.origin.y = (screenH - frame.size.height) * 0.5;
    
    return frame;
    
    
}

#define targetR 250
#define targetL -220
// 手指抬起的时候调用
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    // 复位
    if (_isDraging == NO && _mainV.frame.origin.x != 0) {
        [UIView animateWithDuration:0.25 animations:^{
            
            _mainV.frame = self.view.bounds;
        }];
    }
    
    // 定位功能
    // 获取定位点
    CGFloat target = 0;
    if (_mainV.frame.origin.x > screenW * 0.5) { // _main.x > screenW * 0.5 自动定位到右边 250
        target = targetR;
    }else if (CGRectGetMaxX(_mainV.frame) < screenW * 0.5){ // max(_main.x) < screenW * 0.5 自动定位到左边 -220
        target = targetL;
    }
    
    // 获取当前偏移量
    CGFloat offsetX = target - _mainV.frame.origin.x;
    if (target == 0) {
        [UIView animateWithDuration:0.25 animations:^{
            
            _mainV.frame = self.view.bounds;
        }];
    }else{
        
        [UIView animateWithDuration:0.25 animations:^{
            
            _mainV.frame = [self frameWithOffsetX:offsetX];
        }];
    }
    
    _isDraging = NO;
}

@end
