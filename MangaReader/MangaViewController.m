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
    if(!self.readerView) self.readerView = [[FBReaderView alloc]initWithFrame:self.view.bounds];
    self.readerView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.readerView.dataSource = self;
    self.readerView.delegate = self;
    [self.view addSubview:self.readerView];
    
    // Ajout de la waitView
    [self.view addSubview:self.waitView];
    
    
    // Affichage des bar de nav sur dblClick
    UITapGestureRecognizer * dbTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toogleBarVisibility)];
    dbTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:dbTap];
    [dbTap release];
    

    if(!self.manga.imageURLs)
    {
        self.waitView.hidden = NO;
        dispatch_async(dispatch_get_global_queue(2, 0), ^{
            [self.manga fetchURLs];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.waitView.hidden = YES;
                [self.readerView reloadData];
            });
            
        });
        
        
    }
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
    UIView * cell = [[UIView alloc]initWithFrame:self.readerView.bounds];
    
    cell.backgroundColor = [UIColor blackColor];
    
    UIActivityIndicatorView * spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = cell.center;
    [spinner startAnimating];
    
    [cell addSubview:spinner];
    
    NSFileManager * fileManager = [[NSFileManager alloc]init];
    NSURL * pathURL = [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    
    
    NSString * img = [NSString stringWithFormat:@"%@ - img%d.jpeg", self.manga.chapterTitle ,index];
    
    pathURL = [pathURL URLByAppendingPathComponent:img isDirectory:NO];
    
    NSData * imageData = [NSData dataWithContentsOfURL:pathURL];
    
    if(imageData)
    {
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:cell.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage imageWithData:imageData];
        [cell addSubview:imageView];
    }
    else
    {
        [self.manga fetchImageAtIndex:index andPerformBlock:^(NSData *imageData) {
            if(imageData)
                [imageData writeToURL:pathURL atomically:YES];
            [self.readerView reloadViewAtIndex:index];
        }];
    }
    
    return cell;

}

- (void)readerView:(FBReaderView *)readerView willPresentViewAtIndex:(NSInteger)index
{
    self.title = [NSString stringWithFormat:@"page %d / %d", index + 1, self.manga.imageURLs.count];
}
@end
