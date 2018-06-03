//
//  VBRootCellIdentifier.m
//  Vibereel
//
//  Created by Abdullah Bakhach on 4/11/15.
//  Copyright (c) 2015 tohtt. All rights reserved.
//

#import "VBRootCellIdentifier.h"
#import "NSString+VBAddons.h"

NSString *const kVBRootCellTypeStandardIdentifier = @"kVBRootCellTypeStandardIdentifier";
NSString *const kVBRootCellTypeSwipableIdentifier = @"kVBRootCellTypeSwipableIdentifier";

@implementation VBRootCellIdentifier

+ (NSString *)getRootCellIdentifierStrWithType:(VBRootCellType)type
{

    NSString *rootCellIdentifierStr;
    switch (type) {
        case VBRootCellTypeStandard:
            rootCellIdentifierStr = kVBRootCellTypeStandardIdentifier;
            break;

        case VBRootCellTypeSwipable:
            rootCellIdentifierStr = kVBRootCellTypeSwipableIdentifier;
            break;

        default:
            rootCellIdentifierStr = kVBRootCellTypeStandardIdentifier;
            break;
    }
    return rootCellIdentifierStr;
}

+ (VBRootCellType)getRootCellTypeFromIdentifierStr:(NSString *)identifierStr
{
    if ([identifierStr containSubstring:kVBRootCellTypeStandardIdentifier])
        return VBRootCellTypeStandard;

    if ([identifierStr containSubstring:kVBRootCellTypeSwipableIdentifier])
        return VBRootCellTypeSwipable;

    return VBRootCellTypeStandard;
}

+ (BOOL)isIdentifierOfVBRootCellType:(NSString *)identifier
{
    NSArray *identifiers = @[kVBRootCellTypeStandardIdentifier, kVBRootCellTypeSwipableIdentifier];
    return [identifiers containsObject:identifier];
}

+ (NSString *)getListOfVBRootCellTypes
{
    NSArray *identifiers = @[kVBRootCellTypeStandardIdentifier, kVBRootCellTypeSwipableIdentifier];
    return [identifiers componentsJoinedByString:@"\n"];
}


+ (NSString *)standardIdentifier
{
    return kVBRootCellTypeStandardIdentifier;

}
+ (NSString *)swipableIdentifier
{
    return kVBRootCellTypeSwipableIdentifier;
}


@end
