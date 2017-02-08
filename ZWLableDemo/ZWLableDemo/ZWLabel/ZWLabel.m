//
//  ZWLabel.m
//  ZWLabel
//
//  Created by 郑亚伟 on 16/11/28.
//  Copyright © 2016年 郑亚伟. All rights reserved.
//


#import "ZWLabel.h"

//基于CoreText自定义的AttributeLabel
@interface ZWLabel ()
@property(nonatomic,strong)NSMutableArray *linkRanges;//包含NSRange的数组
@property(nonatomic)NSRange selectedRange;//点击的range


//三个必须设置的属性
@property(nonatomic,strong)NSTextStorage *textStorage;
@property(nonatomic,strong)NSLayoutManager *layoutManager;
@property(nonatomic,strong)NSTextContainer *textContainer;

@property(nonatomic,strong)UIColor *linkTextColor;//文字链接颜色
@property(nonatomic,strong)UIColor *selectedBackgroudColor;//选中文字背景颜色


@end

@implementation ZWLabel
#pragma mark - init相关
- (instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]){
        [self prepareLabel];
        
    }
    return self;
}


- (void)prepareLabel{
    [self.textStorage addLayoutManager:self.layoutManager];
    [self.layoutManager addTextContainer:self.textContainer];
    self.textContainer.lineFragmentPadding = 0;
    self.userInteractionEnabled = YES;
    [self updateTextStorage];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.textContainer.size = self.bounds.size;
}

#pragma mark - 更新TextStorage并重新绘制text
- (void)updateTextStorage{
    if (self.attributedText == nil){
        
        return;
    }
    
    //设置省略模式
    NSMutableAttributedString *attrStringM = [self addLineBreak:self.attributedText];
    //设置正则表达式相关
    [self regexLinkRanges:attrStringM ];
    //设置文本相关属性
    [self addLinkAttribute:attrStringM];
    
    [self.textStorage setAttributedString:attrStringM];
    
    [self setNeedsDisplay];
}

//设置省略模式
- (NSMutableAttributedString *)addLineBreak:(NSAttributedString *)attrString{
    NSMutableAttributedString *attrStringM = [[NSMutableAttributedString alloc]initWithAttributedString:attrString];
    if (attrStringM.length == 0){
        return attrStringM;
    }
    NSRange range = NSMakeRange(0, 0);
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc]initWithDictionary:[attrStringM attributesAtIndex:0 effectiveRange:&range]];
    //不可变转可变
    NSParagraphStyle *paragraphStyle1 = attributes[NSParagraphStyleAttributeName];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setParagraphStyle:paragraphStyle1];
    
    if (paragraphStyle != nil) {
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    }else{
        // iOS 8.0 can not get the paragraphStyle directly
        paragraphStyle = [[NSMutableParagraphStyle alloc]init];
         paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        attributes[NSParagraphStyleAttributeName] = paragraphStyle;
        [attrStringM setAttributes:attributes range:range];
    }
    return attrStringM;
}
//设置正则表达式相关
- (void)regexLinkRanges:(NSMutableAttributedString *)attrString{
    //MARK:正则表达式相关
    NSArray *patterns = @[@"[a-zA-Z]*://[a-zA-Z0-9/\\.]*", @"#.*?#", @"@[\\u4e00-\\u9fa5a-zA-Z0-9_-]*"];
    //MARK:---
    NSRange regexRange = NSMakeRange(0, attrString.string.length);
    for (NSString *pattern in patterns) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionDotMatchesLineSeparators error:nil];
        //MARK:-----
        NSArray *results = [regex matchesInString:attrString.string options:NSMatchingReportProgress range:regexRange];
        for (NSTextCheckingResult * r in results) {
            NSRange range = [r rangeAtIndex:0];
            /*************************************************/
            //可变数组中不能直接添加NSRange，只能借助NSValue
            NSValue *valueOfRange = [NSValue valueWithRange:range];
            [self.linkRanges addObject:valueOfRange];
            //NSLog(@"%@",valueOfRange);
        }
    }
}

//设置字体属性
- (void)addLinkAttribute:(NSMutableAttributedString *)attrStringM{
    
    if (attrStringM.length == 0){
        return ;
    }
    
    NSRange range = NSMakeRange(0, 0);
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc]initWithDictionary:[attrStringM attributesAtIndex:0 effectiveRange:&range]];
    attributes[NSFontAttributeName] = self.font;
    attributes[NSForegroundColorAttributeName] = self.textColor;
    //MARK:-----自己额外添加
   // attributes[NSBackgroundColorAttributeName] = [UIColor greenColor];
    [attrStringM addAttributes:attributes range:range];
    
    attributes[NSForegroundColorAttributeName] = self.linkTextColor;
    
    for (NSValue *valueOfRange in self.linkRanges) {
        NSRange range = valueOfRange.rangeValue;
        [attrStringM setAttributes:attributes range:range];
    }
}



#pragma mark - touch events事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    NSValue *valueOfRange = [self linkRangeAtLocation:location];
    self.selectedRange = [valueOfRange rangeValue];

    //NSLog(@"%ld",self.selectedRange.location);
    //NSLog(@"%ld",self.selectedRange.length);
    [self modifySelectedAttribute:YES];
//    NSUInteger idx = [self.layoutManager glyphIndexForPoint:location inTextContainer:self.textContainer];
//    NSLog(@"点击了第%ld个",idx);
//    for (NSValue *valueOfRange in self.linkRanges) {
//        NSRange r = valueOfRange.rangeValue;
//        NSLog(@"valueOfRange = %@",valueOfRange);
//        if (NSLocationInRange(idx, r) == YES){
//            [self.textStorage addAttributes:@{NSBackgroundColorAttributeName:[UIColor redColor]} range:r];
//           //这里必不可少
//            [self setNeedsDisplay];
//        }
//    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    NSRange range = [[self linkRangeAtLocation:location] rangeValue];
    if (range.location == self.selectedRange.location && range.length == self.selectedRange.length){
        [self modifySelectedAttribute:NO];
        self.selectedRange = range;
        [self modifySelectedAttribute:YES];
    }else{
        [self modifySelectedAttribute:NO];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.selectedRange.length != 0 && self.selectedRange.location != 0) {
        NSString *text = [self.textStorage.string substringWithRange:self.selectedRange];
        //NSLog(@"选中的文字：%@",text);
        if ([self.delegate respondsToSelector:@selector(zwLabel:didSelectedLinkText:)]) {
            [self.delegate zwLabel:self didSelectedLinkText:text];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self modifySelectedAttribute:NO];
        });
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self modifySelectedAttribute:NO];
}


- (NSValue *)linkRangeAtLocation:(CGPoint )location{
    if (self.textStorage.length == 0) {
        return nil;
    }
    //offset
    //CGPoint offset = [self glyphsOffset:[self glyphsRange]];
   //CGPoint point = CGPointMake(offset.x + location.x, offset.y + location.y);
    CGPoint point = CGPointMake(location.x,  location.y);
    //CGPoint point = CGPointMake(offset.x , offset.y );
    NSInteger index = [self.layoutManager glyphIndexForPoint:point inTextContainer:self.textContainer];
    for (NSValue *valueOfRange in self.linkRanges) {
        NSRange range = valueOfRange.rangeValue;
        if (index >= range.location && index <= range.location + range.length) {
           // NSLog(@"------------%@",[NSValue valueWithRange:range]);
            return  [NSValue valueWithRange:range];
        }
    }
    return nil;
}

- (void)modifySelectedAttribute:(BOOL)isSet{
    /*********************************************/
    //MARK:模拟range==nil情况的判断
    if (self.selectedRange.location == 0 && self.selectedRange.length == 0) {
        return;
    }
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc]initWithDictionary:[self.textStorage attributesAtIndex:0 effectiveRange:nil]];
    attributes[NSForegroundColorAttributeName] = self.linkTextColor;
    
    NSRange range = self.selectedRange;
    if (isSet){
        attributes[NSBackgroundColorAttributeName] = self.selectedBackgroudColor;
    }else{
        attributes[NSBackgroundColorAttributeName] = [UIColor clearColor];
        self.selectedRange = NSMakeRange(0, 0);
    }
    [self.textStorage addAttributes:attributes range:range];
    
    [self setNeedsDisplay];
}


#pragma mark -系统方法
//系统方法
-(void)drawTextInRect:(CGRect)rect{
     //消除父类的绘制，这里我们自己绘制
    //[super drawTextInRect:rect];
    //range
    NSRange range = [self glyphsRange];
    //offset
    //CGPoint offset = [self glyphsOffset:range];
    
    
    //设置选中链接的背景
    [self.layoutManager drawBackgroundForGlyphRange:range atPoint:CGPointZero];
    //设置字形
    [self.layoutManager drawGlyphsForGlyphRange:range atPoint:CGPointZero];
}

- (NSRange) glyphsRange{
    return NSMakeRange(0, self.textStorage.length);
}

- (CGPoint)glyphsOffset:(NSRange)range{
    CGRect rect = [self.layoutManager boundingRectForGlyphRange:range inTextContainer:self.textContainer];
    CGFloat height = (self.bounds.size.height - rect.size.height) * 0.25;
    return  CGPointMake(0, height);
}



//不设置如下四个方法，对外设置的这些属性就无法起到作用。基于coreTextKit的本质：就是去的label的控制权
#pragma mark - setter方法
- (void)setText:(NSString *)text{
     [super setText:text];
     [self updateTextStorage];
}

- (void)setAttributedText:(NSAttributedString *)attributedText{
    [super setAttributedText:attributedText];
    [self updateTextStorage];
}

-(void)setFont:(UIFont *)font{
    [super setFont:font];
    [self updateTextStorage];
}

- (void)setTextColor:(UIColor *)textColor{
    [super setTextColor:textColor];
    [self updateTextStorage];
}

//- (void)setTextAlignment:(NSTextAlignment)textAlignment{
//    [super setTextAlignment:textAlignment];
//    [self updateTextStorage];
//}
//
//- (void)setNumberOfLines:(NSInteger)numberOfLines{
//    [super setNumberOfLines:numberOfLines];
//    [self updateTextStorage];
//}

#pragma mark - getter方法
- (UIColor *)selectedBackgroudColor{
    if (_selectedBackgroudColor == nil) {
        _selectedBackgroudColor = [UIColor lightGrayColor];
    }
    return _selectedBackgroudColor;
}

- (UIColor *)linkTextColor{
    if (_linkTextColor == nil) {
        _linkTextColor = [UIColor blueColor];
    }
    return _linkTextColor;
}

- (NSMutableArray *)linkRanges{
    if (_linkRanges == nil) {
        _linkRanges = [NSMutableArray array];
    }
    return _linkRanges;
}

- (NSTextStorage *)textStorage{
    if (_textStorage == nil) {
        _textStorage = [[NSTextStorage alloc]init];
    }
    return _textStorage;
}

- (NSTextContainer *)textContainer{
    if (_textContainer == nil) {
        _textContainer = [[NSTextContainer alloc]init];
    }
    return _textContainer;
}

- (NSLayoutManager *)layoutManager{
    if (_layoutManager == nil) {
        _layoutManager = [[NSLayoutManager alloc]init];
    }
    return _layoutManager;
}

@end
