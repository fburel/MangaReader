//
//  MangaViewController.m
//  MangaReader
//
//  Created by florian BUREL on 13/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import "MangaViewController.h"

@interface MangaViewController ()
@property (nonatomic, retain) NSMutableDictionary * imagesDictionnary;
@property (nonatomic, retain) UIView * waitView;
@property (nonatomic, retain) IBOutlet FBReaderView * readerView;
@end

@implementation MangaViewController

@synthesize manga = _manga;
@synthesize imagesDictionnary = _imagesDictionnary;
@synthesize waitView = _waitView;
@synthesize readerView = _readerView;



#pragma mark - view lifecycle

-(void)dealloc
{
    [_manga release];
    [_imagesDictionnary release];
    [_waitView release];
    [_readerView release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.imagesDictionnary = [NSMutableDictionary dictionary];
    
    
    // Ajout du reader
    if(!self.readerView) self.readerView = [[FBReaderView alloc]initWithFrame:self.view.bounds];
    self.readerView.dataSource = self;
    [self.view addSubview:self.readerView];
    
    // Ajout de la waitView
    [self.view addSubview:self.waitView];
    
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
    
    cell.backgroundColor = [UIColor redColor];
    
    UIActivityIndicatorView * spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = cell.center;
    [spinner startAnimating];
    
    [cell addSubview:spinner];
    
    NSData * imageData = [self.imagesDictionnary objectForKey:[self.manga.imageURLs objectAtIndex:index]];
    
    if(imageData)
    {
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:cell.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage imageWithData:imageData];
    }
    else
    {
        [self.manga fetchImageAtIndex:index andPerformBlock:^(NSData *imageData) {
            if(imageData)
                [self.imagesDictionnary setObject:imageData forKey:[self.manga.imageURLs objectAtIndex:index]];
            [self.readerView reloadViewAtIndex:index];
        }];
    }
    
    return cell;

}
@end
