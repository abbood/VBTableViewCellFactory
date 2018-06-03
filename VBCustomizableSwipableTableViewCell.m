//
//  VBCustomizableSwipableTableViewCell.m
//  Vibereel
//
//  Created by Abdullah Bakhach on 4/14/15.
//  Copyright (c) 2015 tohtt. All rights reserved.
//

#import "VBCustomizableSwipableTableViewCell.h"

#import <CocoaLumberjack/DDLog.h>
#import "VBCustomLoggers.h"
#import "VBGlobalDebugLevel.h"

#import "UIView+VBBehaviour.h"
#import "VBViewBehaviourProtocol.h"

@implementation VBCustomizableSwipableTableViewCell
{
    id _proxy;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    DDLogVerbose(@"customizable swipable table view cell setSelected:animated called");
    [super setSelected:selected animated:animated];
    if ([_proxy respondsToSelector:@selector(setSelected:animated:)]) {
        DDLogVerbose(@"customizable swipable table view cell setSelected:animated forwarded to proxy object [%@]", _proxy);
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
    DDLogDebug(@"%@", NSStringFromSelector(_cmd));
    [super prepareForReuse];
    // set all the attached behaviours to default
    DDLogDebug(@"%@ existing behaviours count %d", NSStringFromSelector(_cmd), [[self behaviours] count]);
    for (id<VBViewBehaviourProtocol> behaviour in [[self behaviours] allValues]) {
        DDLogDebug(@"seeing if we can reset behaviour %@ to default", behaviour);
        if ([behaviour respondsToSelector:@selector(resetToDefaultBehaviour)]) {
            DDLogDebug(@"%@ reseting behaviour %@", NSStringFromSelector(_cmd), NSStringFromClass([behaviour class]));
            [behaviour resetToDefaultBehaviour];
        }
    }
}

@end
