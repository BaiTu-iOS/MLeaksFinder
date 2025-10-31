//
//  MLCustomAlertView.h
//  MLeaksFinder
//
//  Created by Jiang Chencheng on 2025/10/31.
//  Copyright © 2025 zeposhe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^MLCustomAlertViewButtonHandler)(NSUInteger buttonIndex);

@interface MLCustomAlertView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) MLCustomAlertViewButtonHandler buttonHandler;

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray<NSString *> *)otherButtonTitles;

- (void)show;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
