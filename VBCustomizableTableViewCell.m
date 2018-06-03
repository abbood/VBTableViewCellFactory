//
//  VBCustomizableTableViewCell.m
//  Vibereel
//
//  Created by Abdullah Bakhach on 4/14/15.
//  Copyright (c) 2015 tohtt. All rights reserved.
//

#import "VBCustomizableTableViewCell.h"

#import <CocoaLumberjack/DDLog.h>
#import "VBCustomLoggers.h"
#import "VBGlobalDebugLevel.h"
#import "UIView+VBBehaviour.h"
#import "VBViewBehaviourProtocol.h"

@implementation VBCustomizableTableViewCell
{
    id _proxy;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor clearColor];

    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    DDLogVerbose(@"customizable table view cell setSelected:animated called");
    [super setSelected:selected animated:animated];
    if ([_proxy respondsToSelector:@selector(setSelected:animated:)]) {
        DDLogVerbose(@"customizable table view cell setSelected:animated forwarded to proxy object [%@]", _proxy);
        [_proxy setSelected:selected animated:animated];
    }
}

- (UIEdgeInsets)layoutMargins
{
    if ([_proxy respondsToSelector:@selector(layoutMargins)]) {
        return [_proxy layoutMargins];
    }
    return [super layoutMargins];
}

# pragma mark - VBProxiableViewProtocol
- (void)setProxy:(id)proxy
{
    _proxy = proxy;
}

# pragma mark - override

- (void)prepareForReuse
{
    [super prepareForReuse];
    // set all the attached behaviours to default
    for (id<VBViewBehaviourProtocol> behaviour in [[self behaviours] allValues]) {
        if ([behaviour respondsToSelector:@selector(resetToDefaultBehaviour)]) {
            [behaviour resetToDefaultBehaviour];
        }
    }
}

@end
