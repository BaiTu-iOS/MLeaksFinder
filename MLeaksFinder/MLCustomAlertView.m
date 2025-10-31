//
//  MLCustomAlertView.m
//  MLeaksFinder
//
//  Created by Jiang Chencheng on 2025/10/31.
//  Copyright © 2025 zeposhe. All rights reserved.
//

#import "MLCustomAlertView.h"

@interface MLCustomAlertView()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *alertContentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttons;
@property (nonatomic, copy) NSString *cancelButtonTitle;
@property (nonatomic, strong) NSArray<NSString *> *otherButtonTitles;


@end

@implementation MLCustomAlertView

#pragma mark - Initialization

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray<NSString *> *)otherButtonTitles {
    self = [super init];
    if (self) {
        _title = title;
        _message = message;
        _cancelButtonTitle = cancelButtonTitle;
        _otherButtonTitles = otherButtonTitles ?: @[];
        _buttons = [NSMutableArray array];
        [self setupViews];
    }
    return self;
}

#pragma mark - Setup Views

- (void)setupViews {
    // 获取主窗口尺寸
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    self.frame = screenBounds;

    // 背景遮罩
    self.backgroundView = [[UIView alloc] initWithFrame:screenBounds];
    self.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    self.backgroundView.alpha = 0;
    [self addSubview:self.backgroundView];

    // 添加点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
    [self.backgroundView addGestureRecognizer:tapGesture];

    // 弹窗主体
    CGFloat alertWidth = 270;
    self.alertContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, alertWidth, 0)];
    self.alertContentView.backgroundColor = [UIColor whiteColor];
    self.alertContentView.layer.cornerRadius = 14;
    self.alertContentView.layer.masksToBounds = YES;
    self.alertContentView.alpha = 0;
    self.alertContentView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    [self addSubview:self.alertContentView];

    CGFloat currentY = 0;
    CGFloat padding = 16;

    // 标题
    if (self.title && self.title.length > 0) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, currentY + 20, alertWidth - 2 * padding, 0)];
        self.titleLabel.text = self.title;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.numberOfLines = 0;
        [self.titleLabel sizeToFit];
        self.titleLabel.frame = CGRectMake(padding, currentY + 20, alertWidth - 2 * padding, self.titleLabel.frame.size.height);
        [self.alertContentView addSubview:self.titleLabel];
        currentY = CGRectGetMaxY(self.titleLabel.frame) + 8;
    }

    // 消息内容
    if (self.message && self.message.length > 0) {
        CGFloat messageTopPadding = self.title ? 0 : 20;
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, currentY + messageTopPadding, alertWidth - 2 * padding, 0)];
        self.messageLabel.text = self.message;
        self.messageLabel.font = [UIFont systemFontOfSize:13];
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.textColor = [UIColor grayColor];
        [self.messageLabel sizeToFit];
        self.messageLabel.frame = CGRectMake(padding, currentY + messageTopPadding, alertWidth - 2 * padding, self.messageLabel.frame.size.height);
        [self.alertContentView addSubview:self.messageLabel];
        currentY = CGRectGetMaxY(self.messageLabel.frame) + 20;
    }

    // 创建按钮
    [self createButtons];

    // 按钮布局
    NSInteger buttonCount = self.buttons.count;
    CGFloat buttonHeight = 44;

    if (buttonCount <= 2) {
        // 横向排列
        CGFloat buttonWidth = alertWidth / buttonCount;
        for (NSInteger i = 0; i < buttonCount; i++) {
            UIButton *button = self.buttons[i];
            button.frame = CGRectMake(i * buttonWidth, currentY, buttonWidth, buttonHeight);
            [self.alertContentView addSubview:button];

            // 添加分割线
            if (i > 0) {
                UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(i * buttonWidth, currentY, 0.5, buttonHeight)];
                separator.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
                [self.alertContentView addSubview:separator];
            }
        }
        currentY += buttonHeight;
    } else {
        // 纵向排列
        for (NSInteger i = 0; i < buttonCount; i++) {
            UIButton *button = self.buttons[i];
            button.frame = CGRectMake(0, currentY, alertWidth, buttonHeight);
            [self.alertContentView addSubview:button];
            currentY += buttonHeight;

            // 添加分割线
            if (i < buttonCount - 1) {
                UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, currentY - 0.5, alertWidth, 0.5)];
                separator.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
                [self.alertContentView addSubview:separator];
            }
        }
    }

    // 顶部分割线
    UIView *topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, currentY - buttonHeight * (buttonCount <= 2 ? 1 : buttonCount), alertWidth, 0.5)];
    topSeparator.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
    [self.alertContentView addSubview:topSeparator];

    // 设置最终高度和居中
    self.alertContentView.frame = CGRectMake(0, 0, alertWidth, currentY);
    self.alertContentView.center = CGPointMake(screenBounds.size.width / 2, screenBounds.size.height / 2);
}

- (void)createButtons {
    // 其他按钮
    for (NSInteger i = 0; i < self.otherButtonTitles.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:self.otherButtonTitles[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:0.0 green:0.478 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:17];
        button.tag = i;
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
    }

    // 取消按钮
    if (self.cancelButtonTitle && self.cancelButtonTitle.length > 0) {
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [cancelButton setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor colorWithRed:0.0 green:0.478 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        cancelButton.tag = self.otherButtonTitles.count;
        [cancelButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:cancelButton];
    }
}

#pragma mark - Actions

- (void)buttonTapped:(UIButton *)button {
    if (self.buttonHandler) {
        self.buttonHandler(button.tag);
    }
    [self dismiss];
}

- (void)backgroundTapped {
    // 可选：点击背景不关闭
    // [self dismiss];
}

#pragma mark - Show & Dismiss

- (void)show {
    UIWindow *window = [self getCurrentWindow];
    [window addSubview:self];

    // 动画显示
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.backgroundView.alpha = 1;
        self.alertContentView.alpha = 1;
        self.alertContentView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundView.alpha = 0;
        self.alertContentView.alpha = 0;
        self.alertContentView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Helper Methods

- (UIWindow *)getCurrentWindow {
    UIWindow *window = nil;

    // iOS 13+ 使用 UIScene
    if (@available(iOS 13.0, *)) {
        NSSet<UIScene *> *connectedScenes = [UIApplication sharedApplication].connectedScenes;
        for (UIScene *scene in connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                    for (UIWindow *sceneWindow in windowScene.windows) {
                        if (sceneWindow.isKeyWindow) {
                            window = sceneWindow;
                            break;
                        }
                    }
                    if (!window && windowScene.windows.count > 0) {
                        window = windowScene.windows.firstObject;
                    }
                }
            }
            if (window) break;
        }

        // 如果没找到活跃的 window，使用第一个可用的
        if (!window) {
            for (UIScene *scene in connectedScenes) {
                if ([scene isKindOfClass:[UIWindowScene class]]) {
                    UIWindowScene *windowScene = (UIWindowScene *)scene;
                    if (windowScene.windows.count > 0) {
                        window = windowScene.windows.firstObject;
                        break;
                    }
                }
            }
        }
    }

    // iOS 13 以下的兼容处理
    if (!window) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        window = [UIApplication sharedApplication].keyWindow;
        if (!window) {
            window = [UIApplication sharedApplication].windows.firstObject;
        }
        #pragma clang diagnostic pop
    }

    return window;
}

@end
