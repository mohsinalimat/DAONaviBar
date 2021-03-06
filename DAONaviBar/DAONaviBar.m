//
//  DAONaviBar.m
//  AlleyStore
//
//  Created by daoseng on 2017/7/26.
//  Copyright © 2017年 LikeABossApp.All rights reserved.
//

#import "DAONaviBar.h"
#import "HTDelegateProxy.h"

@interface DAONaviBar () <UIScrollViewDelegate>

@property (weak, nonatomic) UIViewController *vc;
@property (strong, nonatomic) UIWindow *statusBarWindow;
@property (strong, nonatomic) UIView *cloneBackView;

@property (nonatomic) CGFloat previousScrollViewYOffset;
@property (assign, nonatomic) BOOL isScrollAnimating;
@property (strong, nonatomic) HTDelegateProxy *delegateProxy;

@end

@implementation DAONaviBar

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.isDragging) {
        CGFloat scrollHeight = scrollView.frame.size.height;
        CGFloat scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom;
        CGFloat scrollOffset = MAX(-scrollView.contentInset.top, MIN(scrollContentSizeHeight - scrollHeight, scrollView.contentOffset.y));
        
        CGRect statusFrame = self.statusBarWindow.frame;
        CGFloat framePercentage = ((0 - statusFrame.origin.y) / CGRectGetHeight([UIApplication sharedApplication].statusBarFrame));
        CGFloat scrollDiff = scrollOffset - self.previousScrollViewYOffset;
        
        // 滑動速度
        CGFloat velocity = 40;
        
        if (scrollDiff > velocity) {
            [self showStatusBar:NO];
        }
        else if (scrollDiff < -velocity) {
            [self showStatusBar:YES];
        }
        
        if (!self.isScrollAnimating) {
            // 數值越大滑動效果越慢
            CGFloat velocityLevel = 6.0;
            
            statusFrame.origin.y = MIN(0, MAX(-CGRectGetHeight([UIApplication sharedApplication].statusBarFrame), statusFrame.origin.y - (scrollDiff / velocityLevel)));
            self.statusBarWindow.frame = statusFrame;

            CGRect frame = self.vc.navigationController.navigationBar.frame;
            frame.origin.y = MIN(CGRectGetHeight([UIApplication sharedApplication].statusBarFrame), MAX(0, frame.origin.y - (scrollDiff / velocityLevel)));
            frame.size.height = MIN(44, MAX(24, frame.size.height - (scrollDiff / velocityLevel)));
            [self.vc.navigationController.navigationBar setFrame:frame];
            
            [self updateBarButtonItems:framePercentage];
            [self updateStatusBar:framePercentage];
        }
        
        self.previousScrollViewYOffset = scrollOffset;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self stoppedScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self stoppedScrolling];
    }
}

#pragma - animation

- (void)stoppedScrolling {
    [self showStatusBar:self.statusBarWindow.frame.origin.y >= 0 - (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) / 2)];
}

- (void)showStatusBar:(BOOL)show {
    self.isScrollAnimating = YES;
    
    CGRect statusFrame = self.statusBarWindow.frame;
    statusFrame.origin.y = show ? 0 : -CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    
    CGRect frame = self.vc.navigationController.navigationBar.frame;
    frame.origin.y = show ? CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) : 0;
    frame.size.height = show ? 44 : 24;
    
    CGFloat percentage = show ? 0 : 1;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.statusBarWindow.frame = statusFrame;
        self.vc.navigationController.navigationBar.frame = frame;
        [self updateStatusBar:percentage];
        [self updateBarButtonItems:percentage];
    } completion:^(BOOL finished) {
        self.isScrollAnimating = NO;
    }];
}

- (void)updateStatusBar:(CGFloat)percentage {
    CGFloat alpha = 1 - percentage;
    self.statusBarWindow.alpha = alpha;
}

- (void)updateBarButtonItems:(CGFloat)percentage {
    CGFloat alpha = 1 - percentage;
    
    CGRect frame = self.cloneBackView.frame;
    frame.origin.y = 6 - (6 * percentage);
    frame.origin.x = 6 - (10 * percentage);
    frame.size.height = 30 - (6 * percentage);
    self.cloneBackView.frame = frame;
    
    for (UIView *view in self.vc.navigationController.navigationBar.subviews) {
        if ([NSStringFromClass([view class]) isEqualToString:@"UINavigationItemView"]) {
            view.alpha = alpha;
        }
    }
}

#pragma mark - misc

- (void)tap:(UITapGestureRecognizer *)sender {
    [self showStatusBar:YES];
}

- (void)back:(UITapGestureRecognizer *)sender {
    [self showStatusBar:YES];
    [self showDefaultBackButton];
    [self.vc.navigationController popViewControllerAnimated:YES];
}

- (void)showDefaultBackButton {
    for (UIView *view in self.vc.navigationController.navigationBar.subviews) {
        if ([NSStringFromClass([view class]) isEqualToString:@"UINavigationButton"]) {
            view.alpha = 1.0;
            [self.cloneBackView removeFromSuperview];
        }
    }
}

#pragma mark - init values

+ (instancetype)sharedInstance {
    static DAONaviBar *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DAONaviBar alloc] init];
    });
    return instance;
}

- (void)setupWithController:(UIViewController *)vc scrollView:(UIScrollView *)scrollView {
    self.vc = vc;
    self.delegateProxy = [[HTDelegateProxy alloc] initWithDelegates:@[self, vc]];
    scrollView.delegate = (id)self.delegateProxy;
    
    [self setupInitValues];
    [self setupBackImageView];
}

- (void)setupInitValues {
    self.statusBarWindow = (UIWindow *)[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"];
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.vc.navigationController.navigationBar addGestureRecognizer:tapGR];
}

- (void)setupBackImageView {
    for (UIView *view in self.vc.navigationController.navigationBar.subviews) {
        if ([NSStringFromClass([view class]) isEqualToString:@"UINavigationButton"]) {
            self.cloneBackView = [[UIView alloc] initWithFrame:view.frame];
            
            for (UIImageView *imageView in view.subviews) {
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                UIImageView *newImageView = [[UIImageView alloc] initWithFrame:imageView.frame];
                newImageView.contentMode = UIViewContentModeScaleAspectFit;
                newImageView.image = imageView.image;
                newImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
                [self.cloneBackView addSubview:newImageView];
            }

            UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
            [self.cloneBackView addGestureRecognizer:tapGR];
            [self.vc.navigationController.navigationBar addSubview:self.cloneBackView];
            
            view.alpha = 0;
        }
    }
}

@end
