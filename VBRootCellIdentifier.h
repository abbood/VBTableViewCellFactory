//
//  VBRootCellIdentifier.h
//  Vibereel
//
//  Created by Abdullah Bakhach on 4/11/15.
//  Copyright (c) 2015 tohtt. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString *const kVBRootCellTypeStandardIdentifier;
FOUNDATION_EXTERN NSString *const kVBRootCellTypeSwipableIdentifier;

typedef NS_ENUM(NSUInteger, VBRootCellType){
    VBRootCellTypeStandard = 1,
    VBRootCellTypeSwipable
};


/**
 * This class is just to enforce the selection of a predefined root cell type
 * if obj-c had string enums.. this class wouldn't be necessary
 */
@interface VBRootCellIdentifier : NSObject

+ (NSString *)getRootCellIdentifierStrWithType:(VBRootCellType)type;
+ (VBRootCellType)getRootCellTypeFromIdentifierStr:(NSString *)identifierStr;
+ (BOOL)isIdentifierOfVBRootCellType:(NSString *)identifier;
+ (NSString *)getListOfVBRootCellTypes;

// identifier strings
+ (NSString *)standardIdentifier;
+ (NSString *)swipableIdentifier;


@end
