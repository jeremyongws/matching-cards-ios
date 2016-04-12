//
//  Card.h
//  MatchingCards
//
//  Created by Jeremy Ong on 11/04/2016.
//  Copyright © 2016 Jeremy Ong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Card : NSObject

@property NSString *imageName;
@property NSString *status; //flipped, unflipped, matched
@property NSInteger index;

@end
