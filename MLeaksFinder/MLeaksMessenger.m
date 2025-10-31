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
#import "MLCustomAlertView.h"

static __weak MLCustomAlertView *alertView;

@implementation MLeaksMessenger

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message {
    [self alertWithTitle:title message:message additionalButtonTitle:nil handler:nil];
}

+ (void)alertWithTitle:(NSString *)title
               message:(NSString *)message
 additionalButtonTitle:(NSString *)additionalButtonTitle
               handler:(void (^)(NSUInteger buttonIndex))handler {


    [alertView dismiss];
    NSMutableArray *otherButtonTitles = [NSMutableArray arrayWithCapacity:1];
    [otherButtonTitles addObject:additionalButtonTitle];

    MLCustomAlertView *alertViewTemp = [[MLCustomAlertView alloc] initWithTitle:title message:message cancelButtonTitle:@"OK" otherButtonTitles:otherButtonTitles];
    [alertViewTemp show];
    alertViewTemp.buttonHandler = handler;
    alertView = alertViewTemp;

    NSLog(@"%@: %@", title, message);
}


@end
