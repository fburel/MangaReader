//
//  MangaViewController.m
//  MangaReader
//
//  Created by florian BUREL on 13/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import "MangaViewController.h"


@interface Page (ImageFetcher)

- (void) fetchImageData:(void(^)(NSData * imageData))completion;

@end

@interface MangaViewController ()
@property (nonatomic, retain) UIView * waitView;
@property (nonatomic, retain) IBOutlet FBReaderView * readerView;
@end

@implementation MangaViewController

@synthesize chapter = _chapter;
@synthesize waitView = _waitView;
@synthesize readerView = _readerView;

#define kTapDetectingImageViewTag        2202

#pragma mark - view lifecycle

-(void)dealloc
{
    [_chapter release];
    [_waitView release];
    [_readerView release];
    [super dealloc];
}

- (void)toogleBarVisibility
{
    self.navigationController.navigationBarHidden = !self.navigationController.navigationBarHidden;
    self.navigationController.toolbarHidden = !self.navigationController.toolbarHidden;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = self.chapter.subtitle;
    self.view.backgroundColor = [UIColor blackColor];
    
    // Ajout du reader
    if(!self.readerView) self.readerView = [[[FBReaderView alloc]initWithFrame:self.view.bounds] autorelease];
    self.readerView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.readerView.dataSource = self;
    self.readerView.delegate = self;
    [self.view addSubview:self.readerView];
    
    // Ajout de la waitView
    [self.view addSubview:self.waitView];
    
    
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    [self.chapter fetchImagesURL:^{
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        self.waitView.hidden = YES;
        [self.readerView reloadData];
        [self startLoadingImages];
    }];
}

- (NSURL *) urlForImageAtIndex:(NSInteger)index
{
    NSFileManager * fm = [[NSFileManager alloc]init];
    NSURL * path = [[fm URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSString * imageName = [NSString stringWithFormat:@"%@ - %d", self.chapter.subtitle, index];
    path = [path URLByAppendingPathComponent:imageName isDirectory:NO];
    [fm release];
    return path;
    
}
- (void) startLoadingImages
{

    [self.chapter.pages enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        Page * page = (Page *) obj;
        int i = page.number.intValue;
        
        NSData * imageData = [NSData dataWithContentsOfURL:[self urlForImageAtIndex:i]];
        
        if(!imageData)
        {
            
            [page  fetchImageData:^(NSData * imageData){
                [imageData writeToURL:[self urlForImageAtIndex:i] atomically:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.readerView reloadViewAtIndex:i];
                    page.isDownloaded = [NSNumber numberWithBool:YES];
                });
            }];
        }
        else [self.readerView reloadViewAtIndex:i];
    }];
}

#pragma mark - lazy getter

- (UIView *)waitView
{
    if(!_waitView)
    {
        _waitView = [[UIView alloc]initWithFrame:self.view.bounds];
        _waitView.backgroundColor = [UIColor blackColor];
        UIActivityIndicatorView * spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.center = _waitView.center;
        [spinner startAnimating];
        spinner.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
        _waitView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        [_waitView addSubview:spinner];
        [spinner release];
    }
    
    return _waitView;
}

#pragma mark - FBReaderViewDataSource

- (NSInteger)numberOfPageInReaderView:(FBReaderView *)imageReaderView
{
    return self.chapter.pages.count;
}

- (UIView *)readerView:(FBReaderView *)readerView viewAtIndex:(NSInteger)index
{
    UIView * cell = [[[UIView alloc]initWithFrame:self.readerView.bounds] autorelease];
    
    cell.backgroundColor = [UIColor blackColor];
    
    UIActivityIndicatorView * spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = cell.center;
    [spinner startAnimating];
    
    [cell addSubview:spinner];
    
    
    
    NSData * imageData = [NSData dataWithContentsOfURL:[self urlForImageAtIndex:index]];
    
    if(imageData)
    {
        [spinner removeFromSuperview];
        TapDetectingImageView * imageView = [[TapDetectingImageView alloc]initWithImage:[UIImage imageWithData:imageData]];
        imageView.delegate = self;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tag = kTapDetectingImageViewTag;
        
        
        UIScrollView * scroolView = [[UIScrollView alloc]initWithFrame:cell.bounds];
        scroolView.delegate = self;
        [scroolView addSubview:imageView];
        [imageView release];
        
        float minimumScale = [scroolView frame].size.width  / [imageView frame].size.width;
        [scroolView setMinimumZoomScale:minimumScale];
        [scroolView setMaximumZoomScale:1];
        [scroolView setZoomScale:minimumScale];
        
        [cell addSubview:scroolView];
        [scroolView release];
    }
    
    [spinner release];
    
    return cell;
    
}

- (void)readerView:(FBReaderView *)readerView willPresentViewAtIndex:(NSInteger)index
{
    self.title = [NSString stringWithFormat:@"page %d / %d", index + 1, self.chapter.pages.count];
}

#pragma mark - TapDetectingImageViewDelegate

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotSingleTapAtPoint:(CGPoint)tapPoint
{
    [self toogleBarVisibility];
}
- (void)tapDetectingImageView:(TapDetectingImageView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint
{
    UIScrollView * zoomIV = (UIScrollView *)[view superview];
    if(zoomIV.zoomScale != zoomIV.minimumZoomScale)
    {
        zoomIV.zoomScale = zoomIV.minimumZoomScale;
        view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
        
    }
    else
    {
        zoomIV.zoomScale = zoomIV.maximumZoomScale;
        [zoomIV zoomToRect:[self zoomRectForScrollView:zoomIV withCenter:tapPoint] animated:NO];
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView viewWithTag:kTapDetectingImageViewTag];
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [scrollView viewWithTag:kTapDetectingImageViewTag].frame = [self centeredFrameForScrollView:scrollView andUIView:[scrollView viewWithTag:kTapDetectingImageViewTag]];
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


- (CGRect)zoomRectForScrollView:(UIScrollView *)scrollView withCenter:(CGPoint)center
{
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [scrollView frame].size.height / scrollView.zoomScale;
    zoomRect.size.width  = [scrollView frame].size.width  / scrollView.zoomScale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}


@end



@implementation Page (ImageFetcher)

- (void)fetchImageData:(void (^)(NSData *))completion
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.serverURL]];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(imageData);
        });
    });
}
@end


