//
//  DWHEmojiSelectionView.m
//  DWHEmojiSelectionView
//
//  Created by dawenhing 2021/3/13.
//  Copyright © 2021 lizhi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DWHEmojiOptionsViewDelegate

@required
- (void)onEmojiSelectionAddEmoji:(NSString *)emoji;
- (void)onEmojiSelectionSendClicked:(UIButton *)sender;
- (void)onEmojiSelectionDeleteClicked:(UIButton *)sender;

@end

@interface DWHEmojiSelectionView : UIView

@property(weak, nonatomic) id<DWHEmojiOptionsViewDelegate> delegate;
@property (weak, nonatomic) UIButton *deleteButton;
@property (weak, nonatomic) UIButton *sendButton;

- (void)enableFunctions:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
