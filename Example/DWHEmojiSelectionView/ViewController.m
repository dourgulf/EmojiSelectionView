//
//  DWHViewController.m
//  DWHEmojiSelectionView
//
//  Created by lidawen on 03/15/2021.
//  Copyright (c) 2021 lidawen. All rights reserved.
//

#import "ViewController.h"
#import "DWHEmojiSelectionView.h"

@interface ViewController () <DWHEmojiOptionsViewDelegate>

@property(weak, nonatomic) DWHEmojiSelectionView *emojiSelectionView;
@property(weak, nonatomic) UILabel *emojiDisplayLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self testEmojiView];
}

- (void)testEmojiView {
    CGRect rect = CGRectMake(0, 300, [[UIScreen mainScreen] bounds].size.width, 320);
    DWHEmojiSelectionView *emojiView = [[DWHEmojiSelectionView alloc] initWithFrame:rect];
    emojiView.delegate = self;
    [self.view addSubview:emojiView];
    self.emojiSelectionView = emojiView;

    rect.origin.y -= 44;
    rect.size.height = 44;
    UILabel *emojiDisplay = [[UILabel alloc] initWithFrame:rect];
    emojiDisplay.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:emojiDisplay];
    self.emojiDisplayLabel = emojiDisplay;
}

- (void)onEmojiSelectionAddEmoji:(NSString *)emoji
{
    NSString *text = self.emojiDisplayLabel.text;
    if (text) {
        text = [text stringByAppendingString:emoji];
    } else {
        text = emoji;
    }
    self.emojiDisplayLabel.text = text;
    [self.emojiSelectionView enableFunctions:YES];
}

- (void)onEmojiSelectionSendClicked:(UIButton *)sender
{
    [self.emojiSelectionView enableFunctions:NO];
    [self animateChangeText:@""];
}

- (void)onEmojiSelectionDeleteClicked:(UIButton *)sender
{
    NSString *text = self.emojiDisplayLabel.text;
    if (text.length > 0) {
        NSUInteger index = text.length - 1;
        text = [text substringToIndex:[text rangeOfComposedCharacterSequenceAtIndex:index].location];
    }
    if (text.length == 0) {
        [self.emojiSelectionView enableFunctions:NO];
    }
    [self animateChangeText:text];
}

- (void)animateChangeText:(NSString *)text {
    [UIView transitionWithView:self.emojiDisplayLabel
                      duration:0.25f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.emojiDisplayLabel.text = text;
                    } completion:nil];
}

@end
