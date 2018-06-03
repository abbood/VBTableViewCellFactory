//
//  VBTableViewCellFactory.h
//  Vibereel
//
//  Created by Abdullah Bakhach on 4/13/15.
//  Copyright (c) 2015 tohtt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBRootCellIdentifier.h"

/**
 * This is a UITableViewCell Factory class that outputs cells with custom behaviours, proxies and a base class
 *
 * example

     _songCellReuseId = [VBTableViewCellFactory reuseIdentifierWithRootType:VBRootCellTypeSwipable
                                                                 behaviours:@[[VBSongCellBehaviour class],[VBSwipableAccessoryCellBehaviour class]]
                                                                 proxyClass:[VBSongCellProxy class]];


     [self.tableView registerClass:[VBTableViewCellFactory class]
            forCellReuseIdentifier:_songCellReuseId];
 *
 *
 *
 *
 * to perform any "protocol" specific actions on the cell later on.. you simply retrieve its behaviour that matches that protocol
 *
 * example

     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
     id<VBSimpleTableViewCellProtocol> behaviour = (id<VBSimpleTableViewCellProtocol>)[cell getBehaviour:[VBSimpleCellBehaviour class]];

     [behaviour setTitle:[user name]];
     [behaviour setImage:[user profileImage]];
     [behaviour setSubtitle:[VBStringFormatter masteredVibereelsTextWithNumOfVibereels:user.numberOfVibereelsMastered
                                                                             andTracks:user.numberOfAddedTracks]];
 *
 * specials thanks goes to @arithma for doing the harder part of this task, and for @fantastik for providing insightful feedback
 */
@interface VBTableViewCellFactory : UITableViewCell

/**
 * Provides a standard way of creating UITableViewCell reusable identifiers based on a selection of
 * - base cell type
 * - behaviours
 * - proxies
 *
 * @param type type of root cell, currently either a standard type (VBRootCellTypeStandard) or a swipable one (VBRootCellTypeSwipable)
 * @param behaviours array of objects that must conform to VBViewBehaviourProtocol. These objects define the behaviour of the cell
 * @param proxyClass class of proxy object.. notice that this must be singular (ie as opposed to behaviours) b/c multiple proxies
 *        are very likely to cause conflicts
 *
 * @note Difference between a proxy and a behaviour: a behaviour is anything that can be slapped on the cell *after* its creation..
 * a proxy, in the other hand.. overrides methods that are specific to UITableViewCell and can only be done upon instantiation
 * ie overriding the setSelected:animated method
 */
+ (NSString *)reuseIdentifierWithRootType:(VBRootCellType)type
                               behaviours:(NSArray *)behaviours
                               proxyClass:(Class)proxyClass;

/**
 * Provides a standard way of creating UITableViewCell reusable identifiers based on a selection of
 * - base cell type
 * - behaviours
 * - proxies
 *
 * @param type type of root cell, currently either a standard type (VBRootCellTypeStandard) or a swipable one (VBRootCellTypeSwipable)
 * @param behaviours array of objects that must conform to VBViewBehaviourProtocol. These objects define the behaviour of the cell
 *        note: parent behaviours MUST appear before their children (see the dependencies param)
 * @param proxyClass class of proxy object.. notice that this must be singular (ie as opposed to behaviours) b/c multiple proxies
 *        are very likely to cause conflicts
 * @param dependencies: a dictionary that maps the behaviour dependency structure.. with the key being the child (dependent) 
 *        behaviour and the value being the parent (depended upon) behaviour
 *        note: a parent behaviour can have multiple children.. but a child cannot have multiple parents
 *
 * @note Difference between a proxy and a behaviour: a behaviour is anything that can be slapped on the cell *after* its creation..
 * a proxy, in the other hand.. overrides methods that are specific to UITableViewCell and can only be done upon instantiation
 * ie overriding the setSelected:animated method
 */
+ (NSString *)reuseIdentifierWithRootType:(VBRootCellType)type
                               behaviours:(NSArray *)behaviours
                               proxyClass:(Class)proxyClass
                             dependencies:(NSDictionary *)dependencies;

@end
