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
@end

@implementation MangaViewController

@synthesize manga = _manga;
@synthesize waitView = _waitView;
@synthesize readerView = _readerView;



#pragma mark - view lifecycle

-(void)dealloc
{
    [_manga release];
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
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // Ajout du reader
    if(!self.readerView) self.readerView = [[[FBReaderView alloc]initWithFrame:self.view.bounds] autorelease];
    self.readerView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.readerView.dataSource = self;
    self.readerView.delegate = self;
    [self.view addSubview:self.readerView];
    
    // Ajout de la waitView
    [self.view addSubview:self.waitView];
    
    
    // Affichage des bar de nav sur dblClick
//    UITapGestureRecognizer * dbTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toogleBarVisibility)];
//    [self.view addGestureRecognizer:dbTap];
//    dbTap.numberOfTapsRequired = 1;
//    [dbTap release];
    
    
    if(!self.manga.imageURLs)
    {
        self.waitView.hidden = NO;
        dispatch_async(dispatch_get_global_queue(2, 0), ^{
            [self.manga fetchURLs];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.waitView.hidden = YES;
                [self.readerView reloadData];
                [self startLoadingImages];
            });
            
        });
        
        
    }
}

- (NSURL *) urlForImageAtIndex:(NSInteger)index
{
    NSFileManager * fm = [[NSFileManager alloc]init];
    NSURL * path = [[fm URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSString * imageName = [NSString stringWithFormat:@"%@ - %d", self.manga.chapterTitle, index];
    path = [path URLByAppendingPathComponent:imageName isDirectory:NO];
    [fm release];
    return path;
    
}
- (void) startLoadingImages
{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for(int i = 0; i < self.manga.imageURLs.count; i++)
        {
            NSData * imageData = [NSData dataWithContentsOfURL:[self urlForImageAtIndex:i]];
            if(!imageData)
            {
                [self.manga fetchImageAtIndex:i andPerformBlock:^(NSData *imageData) {
                    [imageData writeToURL:[self urlForImageAtIndex:i] atomically:YES];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.readerView reloadViewAtIndex:i];
                    });
                }];
            }
            
        }
    });
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
    return self.manga.imageURLs.count;
}

- (UIView *)readerView:(FBReaderView *)readerView viewAtIndex:(NSInteger)index
{
    UIView * cell = [[[UIView alloc]initWithFrame:self.readerView.bounds] autorelease];
    
    cell.backgroundColor = [UIColor blackColor];
    
    UIActivityIndicatorView * spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = cell.center;
    [spinner startAnimating];
    
    [cell addSubview:spinner];
    
    [spinner release];
    
    NSData * imageData = [NSData dataWithContentsOfURL:[self urlForImageAtIndex:index]];
    
    if(imageData)
    {
        FBZoomableImageView * imageView = [[FBZoomableImageView alloc]initWithFrame:cell.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage imageWithData:imageData];
        [cell addSubview:imageView];
        [imageView release];
    }
    
    return cell;
    
}

- (void)readerView:(FBReaderView *)readerView willPresentViewAtIndex:(NSInteger)index
{
    self.title = [NSString stringWithFormat:@"page %d / %d", index + 1, self.manga.imageURLs.count];
}
@end
