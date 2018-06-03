//
//  VBUITableViewCellFactory.m
//  Vibereel
//
//  Created by Abdullah Bakhach on 4/11/15.
//  Copyright (c) 2015 tohtt. All rights reserved.
//

#import "VBTableViewCellFactory.h"
#import "MGSwipeTableCell.h"
#import "VBViewBehaviourProtocol.h"

// base cells
#import "VBCustomizableTableViewCell.h"
#import "VBCustomizableSwipableTableViewCell.h"

// behaviours
#import "VBMasterCellBehaviour.h"
#import "VBSimpleCellBehaviour.h"
#import "VBTaggableCellBehaviour.h"
#import "VBRightDeleteButtonCellBehaviour.h"
#import "VBRightDetailsButtonsCellBehaviour.h"
#import "VBSongCellBehaviour.h"
#import "VBCommentCellBehaviour.h"
#import "VBRightReportButtonCellBehaviour.h"
#import "VBSwitchCellBehaviour.h"
#import "VBStandardCellBehaviour.h"
#import "VBReportableCellBehaviour.h"
#import "VBUnavailableSongCellBehaviour.h"
#import "VBSongFavouritingBehavior.h"
#import "VBSeparatorBehaviour.h"

// DF behaviours
#import "DFSongCellBehaviour.h"
#import "DFArtistCellBehaviour.h"
#import "DFAlbumCellBehaviour.h"
#import "DFPlusSelectionBehaviourDevice.h"
#import "DFPlusSelectionBehaviourYoutube.h"
#import "DFGenericCellBehaviour.h"
#import "DFLongTitleCellBehaviour.h"
#import "DFTitleCellBehaviour.h"
#import "DFDimmableCellBehaviour.h"
#import "DFBottomCornerDescriptionCellBehavior.h"
#import "DFPreviewSongBehaviour.h"
#import "DFUnavailableSongCellBehavior.h"

// proxies
#import "VBProxiableViewProtocol.h"
#import "VBSelectableCellProxy.h"
#import "DFSelectableCellProxy.h"

#import "NSString+VBAddons.h"
#import "UIView+VBBehaviour.h"
#import "NSArray+Addons.h"

#import <CocoaLumberjack/DDLog.h>
#import "VBCustomLoggers.h"
#import "VBGlobalDebugLevel.h"

@implementation VBTableViewCellFactory

+ (NSString *)reuseIdentifierWithRootType:(VBRootCellType)type
                               behaviours:(NSArray *)behaviours
                               proxyClass:(Class)proxyClass
{
    return [VBTableViewCellFactory reuseIdentifierWithRootType:type
                                                    behaviours:behaviours
                                                    proxyClass:proxyClass
                                                  dependencies:nil];
}

+ (NSString *)reuseIdentifierWithRootType:(VBRootCellType)type
                               behaviours:(NSArray *)behaviours
                               proxyClass:(Class)proxyClass
                             dependencies:(NSDictionary *)dependencies
{
    NSAssert(type, @"cannot instantiate a customizable cell without setting a root type");
    NSMutableArray *componentIdentifiers = [NSMutableArray array];
    DDLogVerbose(@"----- %@:%@ [dependencies: %@]-----", NSStringFromClass([self class]), NSStringFromSelector(_cmd), dependencies);

    [componentIdentifiers addObject:[VBRootCellIdentifier getRootCellIdentifierStrWithType:type]];
    DDLogInfo(@"component identifiers: %@", componentIdentifiers);

    if (behaviours) {
        [behaviours enumerateObjectsUsingBlock:^(id<VBViewBehaviourProtocol>  _Nonnull behaviour, NSUInteger idx, BOOL * _Nonnull stop) {
            [componentIdentifiers addObject:[behaviour behaviourID]];
        }];
    }
    DDLogInfo(@"behaviours: %@", behaviours);

    if (proxyClass) {
        [componentIdentifiers addObject:[proxyClass proxyID]];
        DDLogInfo(@"proxyClass: %@", [proxyClass proxyID]);
    }


    if (dependencies) {
        NSMutableArray *dependenciesArr = [NSMutableArray array];
        if (dependencies) {
            for (id<VBViewBehaviourProtocol> _Nonnull childBehaviour in dependencies) {
                id<VBViewBehaviourProtocol> parentBehaviour = [dependencies objectForKey:childBehaviour];
                [dependenciesArr addObject:[NSString stringWithFormat:@"%@->%@", [childBehaviour behaviourID], [parentBehaviour behaviourID]]];
            }
        }

        [componentIdentifiers addObjectsFromArray:dependenciesArr];
    }
    DDLogInfo(@"dependencies: %@", dependencies);

    DDLogInfo(@"final reuse id: %@", [componentIdentifiers componentsJoinedByString:@"."]);

    return [componentIdentifiers componentsJoinedByString:@"."];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    VBRootCellType type = [VBRootCellIdentifier getRootCellTypeFromIdentifierStr:reuseIdentifier];
    Class proxyClass = [self getProxyClassFromReuseId:reuseIdentifier];

    NSArray *excluded;
    if (proxyClass) {
        excluded = @[[VBRootCellIdentifier getRootCellIdentifierStrWithType:type], [proxyClass proxyID]];
    } else {
        excluded = @[[VBRootCellIdentifier getRootCellIdentifierStrWithType:type]];
    }

    // behaviours
    NSArray *behaviours = [self getBehavioursArrayFromReuseId:reuseIdentifier excludingComponents:excluded];

    // dependenies
    NSMutableArray *componentsAndBehaviours = [excluded mutableCopy];
    [componentsAndBehaviours addObjectsFromArray:[behaviours mapObjectsUsingBlock:^id(id<VBViewBehaviourProtocol> behaviour, NSUInteger idx){
        return [behaviour behaviourID];
    }]];
    NSDictionary *dependences = [self getDependencyDictionaryfromReuseId:reuseIdentifier excludingComponentsAndBehaviours:componentsAndBehaviours];

    self = [[self class] buildRootCellOfType:type
                              withBehaviours:behaviours
                               andProxyClass:proxyClass
                             andDependencies:dependences
                               havingReuseId:reuseIdentifier];
    return self;
}
#pragma clang diagnostic pop

+ (UITableViewCell *)getRootCellOfType:(VBRootCellType)cellType havingReuseId:(NSString *)reuseId
{
    UITableViewCell *cell;
    switch (cellType) {
        case VBRootCellTypeStandard:
            cell = [[VBCustomizableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                      reuseIdentifier:reuseId];
            break;

        case VBRootCellTypeSwipable:
            cell = [[VBCustomizableSwipableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                              reuseIdentifier:reuseId];
            break;

        default:
            cell = [[VBCustomizableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                      reuseIdentifier:reuseId];
            break;
    }
    return cell;
}

- (NSArray *)getBehavioursArrayFromReuseId:(NSString *)reuseId excludingComponents:(NSArray *)exclude
{
    NSMutableArray *components = [[reuseId componentsSeparatedByString:@"."] mutableCopy];
    [components removeObjectsInArray:exclude];

    NSMutableArray *selectedArray = [NSMutableArray arrayWithCapacity:components.count];
    [components enumerateObjectsUsingBlock:^(NSString*  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([key rangeOfString:@"->"].location != NSNotFound) return; // skip dependencies
        Class cls = [[self class] behaviours][key];
        if (!cls) {
            DDLogError(@"");
            assert(NO);
        }
        else {
            [selectedArray addObject:cls];
        }
    }];
    return selectedArray;
}

- (NSDictionary *)getDependencyDictionaryfromReuseId:(NSString *)reuseId excludingComponentsAndBehaviours:(NSArray *)exclude
{
    NSMutableArray *dependencies = [[reuseId componentsSeparatedByString:@"."] mutableCopy];
    [dependencies removeObjectsInArray:exclude];

    if ([dependencies count] == 0) return nil;

    NSMutableDictionary *dependencyDict = [@{} mutableCopy];

    for (NSString *dependencyStr in dependencies) {
        NSArray *dependencyPair = [dependencyStr componentsSeparatedByString:@"->"];
        Class childBehaviourCls = [[self class] behaviours][[dependencyPair firstObject]];
        if (!childBehaviourCls) {
            DDLogError(@"");
            assert(NO);
        }
        Class parentBehaviourCls = [[self class] behaviours][dependencyPair[1]];
        if (!parentBehaviourCls) {
            DDLogError(@"");
            assert(NO);
        }

        [dependencyDict setObject:parentBehaviourCls forKey:(id<NSCopying>)childBehaviourCls];
        //[dependencyDict setObject:childBehaviourCls forKey:(id<NSCopying>)parentBehaviourCls];
    }

    return dependencyDict;
}

+ (NSDictionary *)behaviours
{
    static NSDictionary *behaviours;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        behaviours = [NSDictionary dictionaryWithObjectsAndKeys:
                      [VBSimpleCellBehaviour class],                [VBSimpleCellBehaviour behaviourID],
                      [VBMasterCellBehaviour class],                [VBMasterCellBehaviour behaviourID],
                      [VBTaggableCellBehaviour class],              [VBTaggableCellBehaviour behaviourID],
                      [VBRightDeleteButtonCellBehaviour class],     [VBRightDeleteButtonCellBehaviour behaviourID],
                      [VBRightDetailsButtonsCellBehaviour class],   [VBRightDetailsButtonsCellBehaviour behaviourID],
                      [VBSongCellBehaviour class],                  [VBSongCellBehaviour behaviourID],
                      [VBCommentCellBehaviour class],               [VBCommentCellBehaviour behaviourID],
                      [VBRightReportButtonCellBehaviour class],     [VBRightReportButtonCellBehaviour behaviourID],
                      [VBSwitchCellBehaviour class],                [VBSwitchCellBehaviour behaviourID],
                      [VBStandardCellBehaviour class],              [VBStandardCellBehaviour behaviourID],
                      [VBReportableCellBehaviour class],            [VBReportableCellBehaviour behaviourID],
                      [VBUnavailableSongCellBehaviour class],       [VBUnavailableSongCellBehaviour behaviourID],
                      [VBSongFavouritingBehavior class],            [VBSongFavouritingBehavior behaviourID],
                      [VBSeparatorBehaviour class],                 [VBSeparatorBehaviour behaviourID],
                      [DFSongCellBehaviour class],                  [DFSongCellBehaviour behaviourID],
                      [DFPlusSelectionBehaviourDevice class],       [DFPlusSelectionBehaviourDevice behaviourID],
                      [DFPlusSelectionBehaviourYoutube class],      [DFPlusSelectionBehaviourYoutube behaviourID],
                      [DFArtistCellBehaviour class],                [DFArtistCellBehaviour behaviourID],
                      [DFAlbumCellBehaviour class],                 [DFAlbumCellBehaviour behaviourID],
                      [DFGenericCellBehaviour class],               [DFGenericCellBehaviour behaviourID],
                      [DFLongTitleCellBehaviour class],             [DFLongTitleCellBehaviour behaviourID],
                      [DFTitleCellBehaviour class],                 [DFTitleCellBehaviour behaviourID],
                      [DFDimmableCellBehaviour class],              [DFDimmableCellBehaviour behaviourID],
                      [DFBottomCornerDescriptionCellBehavior class],[DFBottomCornerDescriptionCellBehavior behaviourID],
                      [DFPreviewSongBehaviour class],               [DFPreviewSongBehaviour behaviourID],
                      [DFUnavailableSongCellBehavior class],        [DFUnavailableSongCellBehavior behaviourID],
                      nil];
    });

    return behaviours;
}

- (Class)getProxyClassFromReuseId:(NSString *)reuseId
{
    static NSDictionary *proxies;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        proxies = [NSDictionary dictionaryWithObjectsAndKeys:
                   [VBSelectableCellProxy class], [VBSelectableCellProxy proxyID],
                   [DFSelectableCellProxy class], [DFSelectableCellProxy proxyID],
                   nil];
    });

    NSPredicate *filter = [NSPredicate predicateWithFormat:@"SELF like %@", @"*proxy*"];
    NSString *proxyKey = [[[reuseId componentsSeparatedByString:@"."] filteredArrayUsingPredicate:filter] firstObject];


    return proxies[proxyKey];
}

+ (BOOL)isBehaviourClassAChild:(Class)behaviourClass fromDependencies:(NSDictionary *)dependencies
{
    return [dependencies objectForKey:(id<NSCopying>)behaviourClass] != nil;
}

+ (BOOL)isBehaviourClassAParent:(Class)behaviourClass fromDependencies:(NSDictionary *)dependencies
{
    NSArray *parentBehaviours = [dependencies allValues];
    return [parentBehaviours containsObject:behaviourClass];
}

// dependencies
// key: child class (more than one child can belong to same parent)
// value: parent class
+ (id)buildRootCellOfType:(VBRootCellType)cellType
           withBehaviours:(NSArray *)behaviours
            andProxyClass:(Class)proxyClass
          andDependencies:(NSDictionary *)dependencies
            havingReuseId:(NSString *)reuseId
{
    UITableViewCell *rootCell = [[self class] getRootCellOfType:cellType havingReuseId:reuseId];
    DDLogVerbose(@"%@\n\nbehaviours: %@\nproxyClass: %@\ndependencies: %@\nreuseId: %@",NSStringFromSelector(_cmd), behaviours, proxyClass, dependencies, reuseId);

    if (dependencies) {
        // mapping is a dict with
        // key: parentClass
        // val: corresponding parent behaviour object
        NSMutableDictionary *mapping = [@{} mutableCopy];
        // a note about behaviours: we know that parent behaviours will
        // always appear BEFORE child behaviours, and that each
        // behaviour will appear exactly one
        for (Class behaviourClass in behaviours) {
            // check if this behaviour Class is a parent behaviour class
            DDLogVerbose(@"is class: \"%@\" a parent or child? %@", NSStringFromClass(behaviourClass), [dependencies objectForKey:behaviourClass]);
            if ([[self class] isBehaviourClassAParent:behaviourClass fromDependencies:dependencies]) {
                // it is! so instantiate a concrete copy and save it
                id parentBehaviour = [rootCell addBehaviour:behaviourClass];
                DDLogVerbose(@"\"%@\" is a parent! so add [%@,%@] to mapping", NSStringFromClass(behaviourClass), NSStringFromClass(behaviourClass), parentBehaviour);
                mapping[(id<NSCopying>)behaviourClass] = parentBehaviour;
            } else if([[self class] isBehaviourClassAChild:behaviourClass fromDependencies:dependencies]) {
                // this is a child behaviour, so before instantiating it.. assign the parente dependency to it
                Class parentClass = dependencies[behaviourClass];
                id<VBViewBehaviourProtocol> parentBehaviour = mapping[parentClass];
                DDLogVerbose(@"\"%@\" is a child! so add it as a dependent to parent: %@", NSStringFromClass(behaviourClass), NSStringFromClass(parentClass));
                [rootCell addBehaviour:behaviourClass withParentBehaviour:parentBehaviour];
            } else {
                DDLogVerbose(@"\"%@\" is neither! so just add it as is",NSStringFromClass(behaviourClass));
                [rootCell addBehaviour:behaviourClass];
            }
        }
    } else {
        for (Class behaviourClass in behaviours) {
            [rootCell addBehaviour:behaviourClass];
        }
    }

    if (proxyClass) {
        NSAssert([proxyClass conformsToProtocol:@protocol(VBViewProxyProtocol)], @"proxyClass must conform to VBViewProxyProtocol");
        id<VBViewProxyProtocol> proxy = [proxyClass new];
        [((id<VBProxiableViewProtocol>)rootCell) setProxy:proxy];
        [proxy setProxiedView:rootCell];
    }

    return rootCell;
}

@end

