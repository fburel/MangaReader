//
//  MangaViewController.m
//  MangaReader
//
//  Created by florian BUREL on 13/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import "MangaViewController.h"

@interface MangaViewController ()
@property (nonatomic, retain) UIView * waitView;
@property (nonatomic, retain) IBOutlet FBReaderView * readerView;
@property (nonatomic, retain) ThumbnailPickerView * thumbnailPickerView;
@property (nonatomic, retain) UILabel * loadingLabel;
@end

@implementation MangaViewController

@synthesize chapter = _chapter;
@synthesize waitView = _waitView;
@synthesize readerView = _readerView;
@synthesize thumbnailPickerView = _thumbnailPickerView;
@synthesize loadingLabel = _loadingLabel;

#define kTapDetectingImageViewTag        2202

#pragma mark - view lifecycle

-(void)dealloc
{
    [_chapter release];
    [_waitView release];
    [_readerView release];
    [_thumbnailPickerView release];
    [_loadingLabel release];
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.thumbnailPickerView removeFromSuperview];
    [self.loadingLabel removeFromSuperview];
}
- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = NO;
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
    [self.view addSubview:self.readerView];
    
    // Ajout de la waitView
    [self.view addSubview:self.waitView];
    
    // Texte de chargement
    [self.navigationController.toolbar addSubview:self.loadingLabel];

    [self.chapter fetchImagesURL:^{
        self.waitView.hidden = YES;
        [self.loadingLabel removeFromSuperview];
        [self.navigationController.toolbar addSubview:self.thumbnailPickerView];
        [self.readerView reloadData];
        [self downloadMissingImages];
    }];
}

- (void) downloadMissingImages
{
    dispatch_queue_t imageDLQ = dispatch_queue_create([self.chapter.subtitle UTF8String], NULL);
    
    [self.chapter.pages enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        Page * page = (Page *) obj;
        int i = page.number.intValue;
        
        NSData * imageData = [NSData dataWithContentsOfURL:[self urlForImageAtIndex:i]];
        
        if(!imageData)
        {
            
            dispatch_async(imageDLQ, ^{
                NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:page.serverURL]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [imageData writeToURL:[self urlForImageAtIndex:i] atomically:YES];
                    [self.readerView reloadViewAtIndex:i];
                    page.isDownloaded = [NSNumber numberWithBool:YES];
                    [self.thumbnailPickerView reloadThumbnailAtIndex:i];
                });
                
            });
        }
        else
        {
            [self.readerView reloadViewAtIndex:i];
            page.isDownloaded = [NSNumber numberWithBool:YES];
        }
    }];
    
    dispatch_release(imageDLQ);
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

- (UILabel *)loadingLabel
{
    if(!_loadingLabel)
    {
        _loadingLabel = [[UILabel alloc]initWithFrame:self.navigationController.toolbar.bounds];
        _loadingLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _loadingLabel.text = NSLocalizedString(@"Loading...", nil);
        _loadingLabel.textAlignment = NSTextAlignmentCenter;
        _loadingLabel.backgroundColor = [UIColor clearColor];

        
    }
    return _loadingLabel;
}

- (FBReaderView *)readerView
{
    if(!_readerView)
    {
        _readerView = [[FBReaderView alloc]initWithFrame:self.view.bounds];
        _readerView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        _readerView.dataSource = self;
        _readerView.delegate = self;
    }
    return _readerView;
}

- (ThumbnailPickerView *)thumbnailPickerView
{
    if(!_thumbnailPickerView)
    {
        _thumbnailPickerView = [[ThumbnailPickerView alloc]initWithFrame:self.navigationController.toolbar.bounds];
        _thumbnailPickerView.delegate = self;
        _thumbnailPickerView.dataSource = self;
        _thumbnailPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _thumbnailPickerView;
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

#pragma mark - FBReaderViewDelegate

- (void)readerView:(FBReaderView *)readerView willPresentViewAtIndex:(NSInteger)index
{
    self.thumbnailPickerView.selectedIndex = index;
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
                                                                
#pragma mark - ThumbnailPickerViewDataSource

- (NSUInteger)numberOfImagesForThumbnailPickerView:(ThumbnailPickerView *)thumbnailPickerView
{
    return self.chapter.pages.count;
}

- (UIImage *)thumbnailPickerView:(ThumbnailPickerView *)thumbnailPickerView imageAtIndex:(NSUInteger)index
{
    return [[[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:[self urlForImageAtIndex:index]]] autorelease];
}

#pragma mark - ThumbnailPickerViewDelegate

- (void)thumbnailPickerView:(ThumbnailPickerView *)thumbnailPickerView didSelectImageWithIndex:(NSUInteger)index
{
    [self.readerView presentViewAtIndex:index];
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

- (NSURL *) urlForImageAtIndex:(NSInteger)index
{
    NSFileManager * fm = [[NSFileManager alloc]init];
    NSURL * path = [[fm URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSString * imageName = [NSString stringWithFormat:@"%@ - %d", self.chapter.subtitle, index];
    path = [path URLByAppendingPathComponent:imageName isDirectory:NO];
    [fm release];
    return path;
    
}

@end


