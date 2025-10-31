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
#import <objc/message.h>

static __weak id alert;

@implementation MLeaksMessenger

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message {
    [self alertWithTitle:title message:message additionalButtonTitle:nil handler:nil];
}

+ (void)alertWithTitle:(NSString *)title
               message:(NSString *)message
 additionalButtonTitle:(NSString *)additionalButtonTitle
               handler:(void (^)(NSInteger buttonIndex))handler {
    Class alertClass = NSClassFromString(@"BTAlertView");
    if (alertClass) {
        // 调用 alloc

        // 调用 show
        ((void (*)(id, SEL))objc_msgSend)(alert, @selector(dismiss));

        alert = ((id (*)(id, SEL))objc_msgSend)(alertClass, @selector(alloc));

        // 调用 initWithTitle:message:cancelButtonTitle:otherButtonTitles:
        SEL initSel = NSSelectorFromString(@"initWithTitle:message:cancelButtonTitle:otherButtonTitles:");
        alert = ((id (*)(id, SEL, id, id, id, id, id))objc_msgSend)(
            alert,
            initSel,
            title,
            message,
            @"ok",
            additionalButtonTitle,
            nil
        );

        // 设置 block
        void (^clickBlock)(NSInteger) = ^(NSInteger index) {
            // 处理点击
        };

        SEL setBlockSel = NSSelectorFromString(@"setTitleButtonDidClickBlock:");
        ((void (*)(id, SEL, id))objc_msgSend)(alert, setBlockSel, clickBlock);

        // 调用 show
        ((void (*)(id, SEL))objc_msgSend)(alert, @selector(show));
    }


}


@end
