//
//  ViewController.m
//  MatchingCards
//
//  Created by Jeremy Ong on 11/04/2016.
//  Copyright © 2016 Jeremy Ong. All rights reserved.
//

#import "CardViewController.h"
#import "Card.h"
#import "CardImageView.h"

@interface CardViewController () <UIGestureRecognizerDelegate, CardImageViewDelegate>

@property NSMutableArray *cards; // card objectz
@property (weak, nonatomic) IBOutlet UITextView *rulesTextView;
@property (weak, nonatomic) IBOutlet UIStackView *cardStackView;
@property NSInteger timesFlipped;
@property NSMutableArray *flippedImageViews;
@property NSMutableArray *matchedCards;

@end

@implementation CardViewController


- (void)viewDidLoad {
	self.matchedCards = [[NSMutableArray alloc] init];
	self.flippedImageViews = [[NSMutableArray alloc] init];
	[self.rulesTextView setFrame:self.view.frame];
	[self.rulesTextView setHidden:YES];
	[self createCards];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	if ([userDefaults boolForKey:@"newUser"]){
		[self displayRules];
		[userDefaults setBool:NO forKey:@"newUser"];
	}
	[self.cardStackView setAxis:UILayoutConstraintAxisHorizontal];
	[self.cardStackView setDistribution:UIStackViewDistributionFillEqually];
	for (Card *card in self.cards){
		CardImageView *cardImageView;
		UIStackView *stackView;
		if ([self.cards indexOfObject:card] % 4 == 0){
			stackView = [[UIStackView alloc] init];
			[stackView setAxis:UILayoutConstraintAxisVertical];
			[stackView setContentMode:UIViewContentModeScaleAspectFit];
			[stackView setDistribution:UIStackViewDistributionFillEqually];
			[self.cardStackView addArrangedSubview:stackView];
		} else {
			stackView = self.cardStackView.subviews.lastObject;
		}
		
		
		cardImageView = [CardImageView new];
		cardImageView.image = [UIImage imageNamed:@"myface2"];
		cardImageView.highlightedImage = [UIImage imageNamed:card.imageName];
		cardImageView.layer.borderColor = [UIColor blackColor].CGColor;
		cardImageView.layer.borderWidth = 1;
		
		card.status = @"unflipped";
		cardImageView.card = card;
		
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:cardImageView action:@selector(showImage:)];
		tap.numberOfTapsRequired = 1;
		cardImageView.delegate = self;
		
		[cardImageView addGestureRecognizer:tap];
		[cardImageView setUserInteractionEnabled:YES];
		[stackView addArrangedSubview:cardImageView];
	}
	
	
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)showImage:(UITapGestureRecognizer*)tap{
	CardImageView *imageView = (CardImageView*)tap.view;
	[self.flippedImageViews addObject:imageView];
	CardImageView *firstCardImageView = [self.flippedImageViews firstObject];
	CardImageView *secondCardImageView;
	[imageView setHighlighted:YES];
	[imageView.card setStatus:@"flipped"];
	self.timesFlipped++;
	if (self.timesFlipped == 2 && [self.flippedImageViews count] == 2){
		secondCardImageView = [self.flippedImageViews lastObject];
		if([self checkMatchForImageViewOne:firstCardImageView andImageViewTwo:secondCardImageView]) {
			firstCardImageView.tag = 2;
			secondCardImageView.tag = 2;
			[firstCardImageView setUserInteractionEnabled:NO];
			[secondCardImageView setUserInteractionEnabled:NO];
			firstCardImageView.card.status = @"matched";
			secondCardImageView.card.status = @"matched";
			[self.matchedCards addObject:secondCardImageView.card];
			if([self checkWin]){
				UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Done" message:@"You win!" preferredStyle:UIAlertControllerStyleAlert];
				UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Restart Game" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
					for (UIStackView *stackView in self.cardStackView.subviews){
						for (CardImageView *cardImageView in stackView.subviews){
							[stackView removeArrangedSubview:cardImageView];
							[stackView removeFromSuperview];
						}
						[self.cardStackView removeArrangedSubview:stackView];
						[stackView removeFromSuperview];
						
					}
					[self viewDidLoad];
				}];
				[alert addAction:ok];
				[self presentViewController:alert animated:YES completion:nil];
			}
		} else {
			[firstCardImageView setUserInteractionEnabled:YES];
			[secondCardImageView setUserInteractionEnabled:YES];
			double delayInSeconds = 2.0;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				firstCardImageView.card.status = @"unflipped";
				secondCardImageView.card.status = @"unflipped";
				[self refreshStackView];
			});
		}
		[self.flippedImageViews removeAllObjects];
		self.timesFlipped = 0;
	}
	
	[self refreshStackView];
	//	sleep(2);
}

- (BOOL)checkMatchForImageViewOne:(UIImageView*)imageViewOne andImageViewTwo:(UIImageView*)imageViewTwo{
	if ([imageViewOne.highlightedImage isEqual:imageViewTwo.highlightedImage]){
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)checkWin{
	if ([self.matchedCards count] == 8){
		return YES;
	} else {
		return NO;
	}
}

- (void)displayRules{
	self.rulesTextView.restorationIdentifier = @"Rules";
	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self.rulesTextView action:@selector(removeFromSuperview)];
	gesture.numberOfTapsRequired = 2;
	[self.rulesTextView addGestureRecognizer:gesture];
	self.rulesTextView.textAlignment = NSTextAlignmentCenter;
	[self.rulesTextView setUserInteractionEnabled:YES];
	self.rulesTextView.backgroundColor = [UIColor whiteColor];
	[self.rulesTextView setHidden:NO];
}

- (void)createCards{
	NSString *dirPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"assets"];
	NSError * error;
	NSMutableArray * cards = [[NSMutableArray alloc] initWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:&error]];
	self.cards = [[NSMutableArray alloc] init];
	for (int times = 0; times < 8; times++){
		int random = arc4random_uniform([cards count]);
		for (int times = 0; times < 2; times++){
			Card *card = [Card new];
			NSString *randomCardImageName = [cards objectAtIndex:random];
			card.imageName = [[cards objectAtIndex:random] substringToIndex:[randomCardImageName length] - 4];
			card.status = @"Unflipped";
			[self.cards addObject:card];
		}
		[cards removeObjectAtIndex:random];
	}
	[self shuffleCardArray];
}

- (void)shuffleCardArray{
	NSUInteger count = [self.cards count];
	for (NSUInteger i = 0; i < count - 1; ++i) {
		NSInteger remainingCount = count - i;
		NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
		[self.cards exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
	}
}

- (IBAction)onShuffleButtonPressed:(id)sender {
	[self shuffleCardArray];
	[self refreshStackView];
	[self.view setNeedsDisplay];
}

- (void)refreshStackView{
	for (UIStackView *stackView in self.cardStackView.subviews){
		for (CardImageView *cardImageView in stackView.subviews){
			[stackView removeArrangedSubview:cardImageView];
			[stackView removeFromSuperview];
		}
		[self.cardStackView removeArrangedSubview:stackView];
		[stackView removeFromSuperview];
		
	}
	[self.cardStackView setAxis:UILayoutConstraintAxisHorizontal];
	[self.cardStackView setDistribution:UIStackViewDistributionFillEqually];
	for (Card *card in self.cards){
		CardImageView *cardImageView;
		UIStackView *stackView;
		cardImageView.card = card;
		if ([self.cards indexOfObject:card] % 4 == 0){
			stackView = [[UIStackView alloc] init];
			[stackView setAxis:UILayoutConstraintAxisVertical];
			[stackView setContentMode:UIViewContentModeScaleAspectFit];
			[stackView setDistribution:UIStackViewDistributionFillEqually];
			[self.cardStackView addArrangedSubview:stackView];
		} else {
			stackView = self.cardStackView.subviews.lastObject;
		}
		if ([card.status isEqualToString:@"unflipped"]){
			cardImageView = [CardImageView new];
			cardImageView.image = [UIImage imageNamed:@"myface2"];
			cardImageView.highlightedImage = [UIImage imageNamed:card.imageName];
			cardImageView.layer.borderColor = [UIColor blackColor].CGColor;
			cardImageView.layer.borderWidth = 1;
			[cardImageView setHighlighted:NO];
		} else {
			if ([card.status isEqualToString:@"flipped"]){
				cardImageView = [[CardImageView alloc] initWithImage:[UIImage imageNamed:card.imageName]];
				[cardImageView setContentMode:UIViewContentModeScaleAspectFit];
				[cardImageView setUserInteractionEnabled:NO];
			} else if ([card.status isEqualToString:@"matched"]) {
				cardImageView = [[CardImageView alloc] initWithImage:[UIImage imageNamed:card.imageName]];
				cardImageView.highlightedImage = [UIImage imageNamed:card.imageName];
				[cardImageView setContentMode:UIViewContentModeScaleAspectFit];
				[cardImageView setUserInteractionEnabled:NO];
				[cardImageView setHighlighted:YES];
			}
		}
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:cardImageView action:@selector(showImage:)];
		tap.numberOfTapsRequired = 1;
		cardImageView.card = card;
		cardImageView.delegate = self;
		[cardImageView addGestureRecognizer:tap];
		[cardImageView setUserInteractionEnabled:YES];
		[stackView addArrangedSubview:cardImageView];
	}
}

- (void)disableAllCards{
	for (UIStackView *cardStackView in self.cardStackView){
		for (CardImageView *cardImageView in cardStackView){
			[cardImageView setUserInteractionEnabled:NO];
		}
	}
	sleep(2);
}


@end