//
//  CardImageView.h
//  MatchingCards
//
//  Created by Jeremy Ong on 11/04/2016.
//  Copyright © 2016 Jeremy Ong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"


@protocol CardImageViewDelegate

- (void)showImage:(UITapGestureRecognizer*)tapGesture;

@end

@interface CardImageView : UIImageView

@property (nonatomic, assign) id <CardImageViewDelegate> delegate;
@property Card *card;

@end
