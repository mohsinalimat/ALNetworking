//
//  UIViewController+ALExtension.m
//  ALNetworkingDemo
//
//  Created by Arclin on 2017/6/8.
//  Copyright © 2017年 arclin. All rights reserved.
//

#import "UIViewController+ALExtension.h"
#import "ALNetworking.h"
#import "ALNetworkingViewController.h"
#import <objc/runtime.h>

@implementation UIViewController (ALExtension)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector1 = @selector(viewDidLoad);
        SEL swizzledSelector1 = @selector(logger_viewDidLoad);
        Method originalMethod1 = class_getInstanceMethod(class, originalSelector1);
        Method swizzledMethod1 = class_getInstanceMethod(class, swizzledSelector1);
        BOOL didAddMethod1 = class_addMethod(class,originalSelector1,method_getImplementation(swizzledMethod1),method_getTypeEncoding(swizzledMethod1));
        if (didAddMethod1) {
            class_replaceMethod(class,swizzledSelector1,method_getImplementation(originalMethod1),method_getTypeEncoding(originalMethod1));
        } else {
            method_exchangeImplementations(originalMethod1, swizzledMethod1);
        }
    });
}

- (void)logger_viewDidLoad
{
    [self logger_viewDidLoad];
    
    UIGestureRecognizer *customGesture = [ALNetworking sharedInstance].config.gesture;
    
    if(customGesture) { // 如果有自定义手势就直接添加在View上面
        [customGesture.rac_gestureSignal subscribeNext:^(id x) {
            [self showLoggerViewController];
        }];
        [self.view addGestureRecognizer:customGesture];
    } else {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showLoggerViewController)];
        longPress.minimumPressDuration = 2.0f;
        [self.view addGestureRecognizer:longPress];
    }
}

- (void)logger_viewWillAppear:(BOOL)animate
{
    [self logger_viewWillAppear:animate];
}

- (void)showLoggerViewController
{
    if([ALNetworking sharedInstance].config.debugMode) { // 如果是调试模式的话
        ALNetworkingViewController *vc = [[ALNetworkingViewController alloc] initWithHistoryViewController];
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

@end
