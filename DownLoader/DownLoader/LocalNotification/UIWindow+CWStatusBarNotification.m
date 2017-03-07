//
//  UIViewController+CWStatusBarNotification.m
//  CWStatusBarNotificationDemo
//
//  Created by Cezary Wojcik on 9/18/13.
//  Copyright (c) 2013 Cezary Wojcik. All rights reserved.
//

#import "UIWindow+CWStatusBarNotification.h"
#import <objc/runtime.h>

@implementation UIWindow (CWStatusBarNotification);

#define STATUS_BAR_ANIMATION_LENGTH 0.25f
#define FONT_SIZE 12.f

NSString const *CWWindowStatusBarIsHiddenKey = @"CWStatusBarIsHiddenKey";
NSString const *CWWindowStatusBarNotificationIsShowingKey = @"CWStatusBarNotificationIsShowingKey";
NSString const *CWWindowStatusBarNotificationLabelKey = @"CWStatusBarNotificationLabelKey";

# pragma mark - overriding functions

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (BOOL)prefersStatusBarHidden {
    return self.statusBarIsHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}
#pragma clang diagnostic pop

# pragma mark - helper functions

- (void)updateStatusBar {
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
      //  [self setNeedsStatusBarAppearanceUpdate];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:self.statusBarIsHidden withAnimation:self.preferredStatusBarUpdateAnimation];
    }
}

# pragma mark - dimensions

- (CGFloat)getStatusBarHeight {
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.width;
    }
    NSLog(@"%f", statusBarHeight);
    return 1.0 * statusBarHeight;
}

- (CGFloat)getStatusBarWidth {
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        return [UIScreen mainScreen].bounds.size.width;
    }
    return [UIScreen mainScreen].bounds.size.height;
}

- (CGRect)getStatusBarHiddenFrame
{
   // if (!IS_UpIOS7)
    //{
    //    return CGRectMake(0, -2*[self getStatusBarHeight], [self getStatusBarWidth], [self getStatusBarHeight]);
   // }
    //else
  //  {
        return CGRectMake(0, -1*[self getStatusBarHeight], [self getStatusBarWidth], [self getStatusBarHeight]);
   // }
}

- (CGRect)getStatusBarFrame
{
    //if (!IS_UpIOS7)
   // {
    //    return CGRectMake(0, -1*[self getStatusBarHeight], [self getStatusBarWidth], [self getStatusBarHeight]);
   // }
   // else
   // {
        return CGRectMake(0, 0, [self getStatusBarWidth], [self getStatusBarHeight]);
   // }
}

# pragma mark - show status bar notification function

static NSString* messageN = nil;
static CGFloat durationN = 1.0;

- (void)showStatusBarNotification:(NSString *)message forDuration:(CGFloat)duration
{
    messageN = message;
    durationN = duration;
    [self performSelectorOnMainThread : @selector(_showStatusBarNotification) withObject : nil waitUntilDone:NO];
}

- (void)_showStatusBarNotification
{
    [self _InnershowStatusBarNotification : messageN forDuration : durationN];
}

- (void)_InnershowStatusBarNotification:(NSString *)message forDuration:(CGFloat)duration {
    if (!self.statusBarNotificationIsShowing) {
        self.statusBarNotificationIsShowing = YES;
        self.statusBarNotificationLabel.frame = [self getStatusBarHiddenFrame];
        self.statusBarNotificationLabel.text = message;
        self.statusBarNotificationLabel.alpha = 1.0;
        self.statusBarNotificationLabel.backgroundColor = [UIColor colorWithRed:94/255.0 green:92/255.0 blue:158/255.0 alpha:1.0];
        
        if ([message rangeOfString:@"成功"].location != NSNotFound)
             self.statusBarNotificationLabel.textColor = [UIColor whiteColor];
        else if ([message rangeOfString:@"完成"].location != NSNotFound)
            self.statusBarNotificationLabel.textColor = [UIColor whiteColor];
        else if ([message rangeOfString:@"失败"].location != NSNotFound)
            self.statusBarNotificationLabel.textColor = [UIColor whiteColor];
        else
            self.statusBarNotificationLabel.textColor = [UIColor whiteColor];
        
        self.statusBarNotificationLabel.textAlignment = NSTextAlignmentRight;
        self.statusBarNotificationLabel.adjustsFontSizeToFitWidth = YES;
        self.statusBarNotificationLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        [self addSubview:self.statusBarNotificationLabel];
        [self bringSubviewToFront:self.statusBarNotificationLabel];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenOrientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        CGRect statusBarFrame = [self getStatusBarFrame];
        //float duration = STATUS_BAR_ANIMATION_LENGTH;
        
        //if (!IS_UpIOS7)
       // {
       //     duration *= 2;
       // }
        
        [UIView animateWithDuration:STATUS_BAR_ANIMATION_LENGTH animations:^{
            self.statusBarIsHidden = YES;
            [UIApplication sharedApplication].statusBarHidden = YES;
            [self updateStatusBar];
            self.statusBarNotificationLabel.frame = statusBarFrame;
        } completion:^(BOOL finished){
            [UIView animateWithDuration:duration - 2*STATUS_BAR_ANIMATION_LENGTH animations:^{

            } completion:^(BOOL finished) {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [UIView animateWithDuration:STATUS_BAR_ANIMATION_LENGTH animations:^{
                        self.statusBarIsHidden = NO;
                        [self updateStatusBar];
                        [UIApplication sharedApplication].statusBarHidden = NO;
                        self.statusBarNotificationLabel.frame = [self getStatusBarHiddenFrame];
                    } completion:^(BOOL finished) {
                        [self.statusBarNotificationLabel removeFromSuperview];
                        self.statusBarNotificationIsShowing = NO;
                        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
                    }];
                });
            }];
        }];
    }
}

- (IBAction)txtFieldEditingDidEnd:(UITextField *)sender {
}

# pragma mark - screen orientation change

- (void)screenOrientationChanged {
    self.statusBarNotificationLabel.frame = [self getStatusBarFrame];
}

# pragma mark - getters/setters

- (void)setStatusBarIsHidden:(BOOL)statusBarIsHidden {
    objc_setAssociatedObject(self, &CWWindowStatusBarIsHiddenKey, [NSNumber numberWithBool:statusBarIsHidden], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)statusBarIsHidden {
    return [objc_getAssociatedObject(self, &CWWindowStatusBarIsHiddenKey) boolValue];
}

- (void)setStatusBarNotificationIsShowing:(BOOL)statusBarNotificationIsShowing {
    objc_setAssociatedObject(self, &CWWindowStatusBarNotificationIsShowingKey, [NSNumber numberWithBool:statusBarNotificationIsShowing], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)statusBarNotificationIsShowing {
    return [objc_getAssociatedObject(self, &CWWindowStatusBarNotificationIsShowingKey) boolValue];
}

- (void)setStatusBarNotificationLabel:(UILabel *)statusBarNotificationLabel {
    objc_setAssociatedObject(self, &CWWindowStatusBarNotificationLabelKey, statusBarNotificationLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UILabel *)statusBarNotificationLabel
{
    if (objc_getAssociatedObject(self, &CWWindowStatusBarNotificationLabelKey) == nil) {
        [self setStatusBarNotificationLabel:[UILabel new]];
    }
    return objc_getAssociatedObject(self, &CWWindowStatusBarNotificationLabelKey);
}

@end
