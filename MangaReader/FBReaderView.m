//
//  FBImageReaderView.m
//  MangaReader
//
//  Created by florian BUREL on 16/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import "FBReaderView.h"

@implementation FBReaderView

@synthesize indexForPresentedView = _indexForPresentedView;
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;

- (void)reloadData
{
    [self reloadViewAtIndex:self.indexForPresentedView];
}

- (void)reloadViewAtIndex:(NSInteger)index
{
    if(index == self.indexForPresentedView)
         [self presentPageAtIndex:self.indexForPresentedView animated:NO];
}

- (void) presentPageAtIndex:(NSInteger)index animated:(BOOL)animated;
{
    
    if(index < 0 || index >= [self.dataSource numberOfPageInReaderView:self])
        return;
    
    
    BOOL isBeforeCurrentView = index < self.indexForPresentedView;
    
    self.indexForPresentedView = index;
    
    
    [self.delegate readerView:self willPresentViewAtIndex:self.indexForPresentedView];
    
    UIView * viewToPresent = [self.dataSource readerView:self viewAtIndex:self.indexForPresentedView];
    

    void(^animationBlock)() = ^{
        [self addSubview:viewToPresent];
    };
    
    void(^completionBlock)(BOOL finished) = ^(BOOL finished) {
        [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if(obj != viewToPresent) [obj removeFromSuperview];
        }];
    };
    
    
    UIViewAnimationOptions animation = isBeforeCurrentView ? UIViewAnimationOptionTransitionCurlDown : UIViewAnimationOptionTransitionCurlUp;
    
    if(animated)
        [UIView transitionWithView:self duration:1 options:animation animations:animationBlock completion:completionBlock];
    else
    {
        animationBlock();
        completionBlock(true);
    }
        
}

- (void)layoutSubviews
{
    
    if(!self.gestureRecognizers)
    {
        UISwipeGestureRecognizer * swipeL = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipe:)];
        swipeL.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipeL];
        [swipeL release];
        UISwipeGestureRecognizer * swipeR = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipe:)];
        swipeR.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipeR];
        [swipeR release];
    }
       
    [self presentPageAtIndex:self.indexForPresentedView animated:NO];
    
}

- (void) handleSwipe:(UISwipeGestureRecognizer *)sender
{
    if(sender.direction == UISwipeGestureRecognizerDirectionLeft)
        [self presentPageAtIndex:(self.indexForPresentedView + 1) animated:YES];
    if(sender.direction == UISwipeGestureRecognizerDirectionRight)
        [self presentPageAtIndex:(self.indexForPresentedView - 1) animated:YES];
}

- (void) presentViewAtIndex:(NSInteger)index
{
    [self presentPageAtIndex:index animated:NO];
}
@end
