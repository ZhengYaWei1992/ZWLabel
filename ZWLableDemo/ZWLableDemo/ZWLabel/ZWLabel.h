//
//  ZWLabel.h
//  ZWLabel
//
//  Created by 郑亚伟 on 16/11/28.
//  Copyright © 2016年 郑亚伟. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ZWLabelDelegate <NSObject>

@optional
- (void)zwLabel:(UILabel *)label didSelectedLinkText:(NSString *)text;
@end

@interface ZWLabel : UILabel

@property(nonatomic,weak)id<ZWLabelDelegate> delegate;

@end
