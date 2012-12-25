//
//  FBZoomableImageView.m
//  MangaReader
//
//  Created by Florian BUREL on 25/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import "FBZoomableImageView.h"

@interface FBZoomableImageView ()

@property (assign, nonatomic, readwrite) UIImageView * imageView;

@end
@implementation FBZoomableImageView

@synthesize image = _image;
@synthesize imageView = _imageView;

-(void)dealloc
{
    [_image release];
    [super dealloc];
}

- (void)layoutSubviews
{

    if(!self.imageView)
    {
        UIImageView * imageView = [[UIImageView alloc]initWithImage:self.image];
        self.imageView = imageView;
        self.contentSize = self.imageView.bounds.size;
        [self addSubview:self.imageView];
        self.minimumZoomScale = self.bounds.size.width / self.imageView.frame.size.width;
        self.maximumZoomScale = 1.0;
        [imageView release];
        self.zoomScale = self.minimumZoomScale;
    }
   
    if(!self.delegate)
    {
        self.delegate = self;
        UITapGestureRecognizer * dbTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoomMinMax:)];
        dbTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:dbTap];
        [dbTap release];
    }
 
}

- (void) zoomMinMax:(id)sender
{
    
    if(self.zoomScale == self.minimumZoomScale)
        self.zoomScale = self.maximumZoomScale;
    else
        self.zoomScale = self.minimumZoomScale;
    
    CGRect zoomRect = [self zoomRectForScale:self.zoomScale withCenter:[sender locationInView:[sender view]]];
    [self zoomToRect:zoomRect animated:YES];
    
}

- (void)setImage:(UIImage *)image
{
    UIImage * newImage = [image copy];
    [_image release];
    _image = nil;
    _image = newImage;
    
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    
    [self setNeedsLayout];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.imageView.frame = [self centeredFrameForScrollView:self andUIView:self.imageView];;
}

#pragma mark Utility methods

- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView {
    CGSize boundsSize = scroll.bounds.size;
    CGRect frameToCenter = rView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
    {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2.;
    }
    else {
        frameToCenter.origin.x = 0;
    }
    // center vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2.;
    }
    else {
        frameToCenter.origin.y = 0;
    }
    return frameToCenter;
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [self frame].size.height / scale;
    zoomRect.size.width  = [self frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

@end
