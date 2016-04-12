//
//  CardImageView.m
//  MatchingCards
//
//  Created by Jeremy Ong on 11/04/2016.
//  Copyright © 2016 Jeremy Ong. All rights reserved.
//

#import "CardImageView.h"

@implementation CardImageView 

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
	if (self = [super initWithCoder:aDecoder]) {
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage:)];
		self.tag = 0;
		[self addGestureRecognizer:tap];
		[self setUserInteractionEnabled:YES];
	}
	
	return self;
}

- (void)showImage:(UITapGestureRecognizer*)tapGesture{
	[self.delegate showImage:(UITapGestureRecognizer*)tapGesture];
}

@end
