//
//  DWHEmojiSelectionView.m
//  DWHEmojiSelectionView
//
//  Created by dawenhing 2021/3/13.
//  Copyright © 2021 lizhi. All rights reserved.
//

#import "DWHEmojiSelectionView.h"

#define kScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#define kScreenHeight ([[UIScreen mainScreen] bounds].size.height)
#define UIColorRGBA(r,g,b,a)  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define RGBA(c, a) UIColorRGBA((((int)c) >> 16),((((int)c) >> 8) & 0xff),(((int)c) & 0xff),a)

static NSString *const kEmojiRowCellIdentifier = @"EmojiRowCell";
static NSString *const kEmojiSectionHeaderIdentifier = @"EmojiSectionHeader";

static const NSInteger kEmojiButtonWidth = 34;
static const NSInteger kEmojiButtonHeight = 55;
static const NSInteger kEmojiButtonFontSize = 32;
static const NSInteger kEmojiButtonBaseTag = 1000;
static const NSInteger kEmojiHideOffset = 100;
static const NSInteger kEmojiShadowHeight = 30;
static const NSInteger kEmojiIconsOfOneRow = 7;

#pragma mark - Cell

@protocol DWHEmojiRowCellDelegate <NSObject>

- (void)onEmojiCellClicked:(NSString *)emoji;

@end
// cell for one row
@interface ZYEmojiRowCell : UICollectionViewCell

@property(weak, nonatomic) id<DWHEmojiRowCellDelegate> delegate;
@property(weak, nonatomic) UIView *shadowCover;

- (void)udpateRow:(NSInteger)row emoji:(NSArray *)emojiData;

@end

@implementation ZYEmojiRowCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // TODO: 界面上的大量按钮不是很好
        
        NSInteger icons = kEmojiIconsOfOneRow;
        CGFloat width = frame.size.width;
        // 根据表情按钮的宽度计算剩余的间隔（取整）
        NSUInteger gap = (width - icons * kEmojiButtonWidth)/(icons+1);
        CGFloat originY = 0;
        CGFloat originX = gap;
        for (NSInteger i=0; i<icons; i++) {
            UIButton *button = [[UIButton alloc] init];
            button.frame = CGRectMake(originX, originY, kEmojiButtonWidth, kEmojiButtonHeight);
            button.titleLabel.font = [UIFont fontWithName:@"Apple color emoji"
                                                     size:kEmojiButtonFontSize];
            // 不显示点击的高亮效果
            button.reversesTitleShadowWhenHighlighted = YES;
            button.tag = kEmojiButtonBaseTag + i;
            [button addTarget:self action:@selector(onEmojiButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            originX += (kEmojiButtonWidth + gap);
        }
        // 最后几个按钮的遮盖层
        const NSInteger ShadowCoverCount = 3;
        originX = (icons - ShadowCoverCount) * (gap + kEmojiButtonWidth) + gap;
        UIView *shadowCover = [[UIView alloc] initWithFrame:CGRectMake(originX, originY, frame.size.width - originX, kEmojiButtonHeight)];
        shadowCover.backgroundColor = [UIColor blackColor];
        shadowCover.alpha = 0;
        [self addSubview:shadowCover];
        self.shadowCover = shadowCover;
    }
    return self;
}

- (void)udpateRow:(NSInteger)row emoji:(NSArray *)emojiData {
    for (NSUInteger i=0; i<emojiData.count; i++) {
        NSString *emoji = emojiData[i];
        UIButton *button = [self viewWithTag:kEmojiButtonBaseTag + i];
        NSAssert(button != nil, @"Tag不正确");
        [button setTitle:emoji forState:UIControlStateNormal];
    }
}

- (void)updateScrollOffset:(CGFloat)offset {
    CGFloat alpha = 0;
    if (offset <= kEmojiHideOffset) {
        alpha = 1;
    } else if (offset <= kEmojiHideOffset + kEmojiShadowHeight) {
        alpha = (CGFloat)(kEmojiShadowHeight- (offset - kEmojiHideOffset))/(CGFloat)kEmojiShadowHeight;
        if (alpha < 0) {
            alpha = 0;
        }
    }
    NSLog(@"DEBUG>>>row(%@) offset=%f, alpha=%f",
          [self theEmojis], offset, alpha);
    [self hideLastButtons:alpha];
}

- (void)hideLastButtons:(CGFloat)alpha {
    self.shadowCover.alpha = alpha;
}

- (NSString *)theEmojis {
    NSMutableString *emojiString = [[NSMutableString alloc] init];
    for (NSUInteger i=0; i<kEmojiIconsOfOneRow; i++) {
        UIButton *button = [self viewWithTag:kEmojiButtonBaseTag + i];
        NSString *title = [button titleForState:UIControlStateNormal];
        [emojiString appendFormat:@" %@", title];
    }
    return emojiString;
}

-(void)onEmojiButtonClicked:(UIButton *)sender {
    [self.delegate onEmojiCellClicked:sender.titleLabel.text];
}

@end

#pragma mark - EmojiSelectionView
@interface DWHEmojiSelectionView ()<UICollectionViewDelegate, UICollectionViewDataSource, DWHEmojiRowCellDelegate>
{
    NSArray<NSArray *> *_emojiDataRows;
}

@property (weak, nonatomic) UICollectionView *emojiPanelView;

@end

@implementation DWHEmojiSelectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self prepareEmojiData];
        [self setupSubviews];
    }
    return self;
}

- (void)enableFunctions:(BOOL)enable
{
    if (enable) {
        UIColor *backgroundColor = RGBA(0x14CC70, 1);
        UIColor *textColor = [UIColor colorWithWhite:1 alpha:0.9];

        self.sendButton.backgroundColor = backgroundColor;
        // don't change delete button background
        [self.sendButton setTitleColor:textColor forState:UIControlStateNormal];
        [self.deleteButton setTitleColor:textColor forState:UIControlStateNormal];
    } else {
        UIColor *backgroundColor = [UIColor grayColor];;
        UIColor *textColor = [UIColor colorWithWhite:1 alpha:0.2];
        self.sendButton.backgroundColor = backgroundColor;
        self.deleteButton.backgroundColor = backgroundColor;
        [self.sendButton setTitleColor:textColor forState:UIControlStateNormal];
        [self.deleteButton setTitleColor:textColor forState:UIControlStateNormal];
    }
    self.sendButton.enabled = enable;
    self.deleteButton.enabled = enable;
}

- (void)prepareEmojiData {
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"EmojisList"
                                                     ofType:@"plist"];
    NSAssert(path != nil, @"Emoji文件没有配置");
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSAssert(dict != nil, @"Emoji文件格式错误");
    NSArray *peopleEmoji = dict[@"People"];
    NSAssert(peopleEmoji != nil, @"Emoji文件格式错误");
    
    NSInteger iconsPerRow = kEmojiIconsOfOneRow;
    NSMutableArray *allRows = [[NSMutableArray alloc] initWithCapacity:peopleEmoji.count/iconsPerRow + 1];
    NSMutableArray *oneRow = [[NSMutableArray alloc] initWithCapacity:iconsPerRow];
    NSInteger counter = 0;
    for (id emoji in peopleEmoji) {
        [oneRow addObject:emoji];
        counter += 1;
        if (counter == iconsPerRow) {
            counter = 0;
            [allRows addObject:oneRow];
            oneRow = [[NSMutableArray alloc] initWithCapacity:iconsPerRow];
        }        
    }
    _emojiDataRows = allRows;
}

- (void)setupSubviews {
    [self setupEmojiPannelView];
    [self setupFunctionView];
}

- (void)setupEmojiPannelView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(8, 0, 0, 0);
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.itemSize = CGSizeMake(self.bounds.size.width, kEmojiButtonHeight);
    flowLayout.headerReferenceSize = CGSizeMake(self.bounds.size.width, 44);
    
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    collection.showsHorizontalScrollIndicator = NO;
    collection.showsVerticalScrollIndicator = YES;
    [collection registerClass:[ZYEmojiRowCell class] forCellWithReuseIdentifier:kEmojiRowCellIdentifier];
    [collection registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kEmojiSectionHeaderIdentifier];
    collection.dataSource = self;
    collection.delegate = self;
    collection.scrollsToTop = NO;

    [self addSubview:collection];
    self.emojiPanelView = collection;

    collection.translatesAutoresizingMaskIntoConstraints = NO;
    [collection.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [collection.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [collection.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [collection.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
}

- (void)setupFunctionView {
    const NSInteger kFunctionBottomOffset = 34;
    const NSInteger kFunctionTrailingOffset = 20;
    const NSInteger kFunctionGap = 12;
    const NSInteger kFunctionButtonHeight = 44;
    const NSInteger kFunctionButtonWidth = 58;
    
    UIButton *send = [[UIButton alloc] init];
    [self addSubview:send];
    [send setTitle:@"发送" forState:UIControlStateNormal];
    send.titleLabel.font = [UIFont systemFontOfSize:18];
    send.layer.cornerRadius = 22;
    [send addTarget:self action:@selector(onSendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    send.translatesAutoresizingMaskIntoConstraints = NO;
    [send.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-kFunctionBottomOffset].active = YES;
    [send.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-kFunctionTrailingOffset].active = YES;
    [send.heightAnchor constraintEqualToConstant:kFunctionButtonHeight].active = YES;
    [send.widthAnchor constraintEqualToConstant:kFunctionButtonWidth].active = YES;
    self.sendButton = send;

    UIButton *delete = [[UIButton alloc] init];
    [delete setTitle:@"×" forState:UIControlStateNormal];
    delete.titleLabel.font = [UIFont systemFontOfSize:22];
    delete.layer.cornerRadius = 22;
    [delete addTarget:self action:@selector(onDeleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    delete.reversesTitleShadowWhenHighlighted = YES;

    [self addSubview:delete];
    
    delete.translatesAutoresizingMaskIntoConstraints = NO;
    [delete.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-kFunctionBottomOffset].active = YES;
    [delete.trailingAnchor constraintEqualToAnchor:send.leadingAnchor constant:-kFunctionGap].active = YES;
    [delete.heightAnchor constraintEqualToConstant:kFunctionButtonHeight].active = YES;
    [delete.widthAnchor constraintEqualToConstant:kFunctionButtonWidth].active = YES;
    self.deleteButton = delete;
    [self enableFunctions:NO];
}

#pragma mark - UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return _emojiDataRows.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kEmojiSectionHeaderIdentifier forIndexPath:indexPath];
        UILabel *title = [[UILabel alloc] init];
        title.backgroundColor = [UIColor blackColor];
        title.textColor = [UIColor colorWithWhite:1 alpha:0.7];
        title.font = [UIFont systemFontOfSize:14];
        title.text = @"所有表情";
        [reusableView addSubview:title];
        
        title.translatesAutoresizingMaskIntoConstraints = NO;
        [title.topAnchor constraintEqualToAnchor:reusableView.topAnchor constant:18].active = YES;
        [title.bottomAnchor constraintEqualToAnchor:reusableView.bottomAnchor constant:-12].active = YES;
        [title.leadingAnchor constraintEqualToAnchor:reusableView.leadingAnchor constant:20].active = YES;
        [title.trailingAnchor constraintEqualToAnchor:reusableView.trailingAnchor].active = YES;
    }
    return reusableView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *emojiRow = _emojiDataRows[indexPath.item];
    ZYEmojiRowCell *cell = (ZYEmojiRowCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kEmojiRowCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    [cell udpateRow:indexPath.item emoji:emojiRow];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollHeight = self.emojiPanelView.contentOffset.y + self.emojiPanelView.bounds.size.height;
    NSArray<NSIndexPath *> *sortedIndexPath = [[self.emojiPanelView indexPathsForVisibleItems] sortedArrayUsingSelector:@selector(compare:)];
    const NSUInteger kCheckCount = 3;
    if (sortedIndexPath.count > kCheckCount) {
        NSRange subRange = NSMakeRange(sortedIndexPath.count - 3, kCheckCount);
        NSArray<NSIndexPath *> *lastIndexPaths = [sortedIndexPath subarrayWithRange:subRange];
        for (NSIndexPath *indexPath in lastIndexPaths) {
            ZYEmojiRowCell *cell = (ZYEmojiRowCell *)[self.emojiPanelView cellForItemAtIndexPath:indexPath];
            CGFloat offset = scrollHeight - cell.frame.origin.y;
            [cell updateScrollOffset:offset];
        }
    }
}

#pragma mark - ClickEvent
- (void)onEmojiCellClicked:(NSString *)emoji {
    [self.delegate onEmojiSelectionAddEmoji:emoji];
}

- (void)onDeleteButtonClicked:(UIButton *)sender {
    [self.delegate onEmojiSelectionDeleteClicked:sender];
}

- (void)onSendButtonClicked:(UIButton *)sender {
    [self.delegate onEmojiSelectionSendClicked:sender];
}

@end
