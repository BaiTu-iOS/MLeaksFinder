/**
 * Tencent is pleased to support the open source community by making MLeaksFinder available.
 *
 * Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 *
 * https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

#import "MLeaksMessenger.h"

// 持有当前显示的 alertController 的弱引用，以便在需要时可以关闭它
static __weak UIAlertController *presentedAlert;

@implementation MLeaksMessenger

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message {
    [self alertWithTitle:title message:message additionalButtonTitle:nil handler:nil];
}

+ (void)alertWithTitle:(NSString *)title
               message:(NSString *)message
 additionalButtonTitle:(NSString *)additionalButtonTitle
               handler:(void (^)(UIAlertAction *))handler {

    // 如果当前已有警报正在显示，则先将其关闭
    if (presentedAlert) {
        [presentedAlert dismissViewControllerAnimated:NO completion:nil];
    }

    // 必须在主线程上执行 UI 操作
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *presentingViewController = [self topMostViewController];
        if (!presentingViewController) {
            NSLog(@"MLeaksMessenger Error: Could not find a view controller to present from.");
            return;
        }

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                   message:message
                                                                            preferredStyle:UIAlertControllerStyleAlert];

        // 添加默认的 "确定" 按钮
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
        [alertController addAction:okAction];

        // 如果提供了附加按钮标题，则创建并添加该按钮
        if (additionalButtonTitle) {
            UIAlertAction *additionalAction = [UIAlertAction actionWithTitle:additionalButtonTitle
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:handler];
            [alertController addAction:additionalAction];
        }

        // 显示警报
        [presentingViewController presentViewController:alertController animated:YES completion:nil];

        // 弱引用新创建的警报
        presentedAlert = alertController;

        // 打印日志
        NSLog(@"%@: %@", title ?: @"Alert", message ?: @"");
    });
}

#pragma mark - Helper

/**
 * @brief 查找并返回最顶层的视图控制器 (适配 iOS 13+ UIScene)
 */
+ (UIViewController *)topMostViewController {
    UIViewController *topController = nil;

    if (@available(iOS 13.0, *)) {
        // In iOS 13+, we must find the active UIWindowScene.
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        topController = window.rootViewController;
                        break;
                    }
                }
            }
            if (topController) {
                break;
            }
        }
    } else {
        // Fallback for older iOS versions.
        topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    }

    // After finding the root, traverse up the presentation hierarchy.
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }

    return topController;
}

@end
