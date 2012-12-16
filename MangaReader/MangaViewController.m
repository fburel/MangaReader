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
@end

@implementation MangaViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.imagesDictionnary = [NSMutableDictionary dictionary];
    
    UIBarButtonItem * btn = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self.pageScrollView action:@selector(deselectPageAnimated:)];
    self.navigationItem.rightBarButtonItem = btn;
    [btn release];
    
    if(!self.manga.imageURLs)
    {
        
        self.pageScrollView = [[[NSBundle mainBundle] loadNibNamed:@"HGPageScrollView" owner:self options:nil] lastObject];
        self.pageScrollView.delegate = self;
        self.pageScrollView.dataSource = self;
        self.pageScrollView.frame = self.view.bounds;
        [self.view addSubview:self.pageScrollView];
        
        UIView * waitView = [[UIView alloc]initWithFrame:self.view.bounds];
        
        
        waitView.backgroundColor = [UIColor redColor];
        
        [self.view addSubview:waitView];
        waitView.hidden = NO;
        
        dispatch_async(dispatch_get_global_queue(2, 0), ^{
            [self.manga fetchURLs];
            dispatch_async(dispatch_get_main_queue(), ^{
                [waitView removeFromSuperview];
                [self.pageScrollView reloadData];
            });
            
        });
        
        
    }
}


#pragma mark - PageScrollView

// This mechanism works the same as in UITableViewCells.
- (HGPageView *)pageScrollView:(HGPageScrollView *)scrollView viewForPageAtIndex:(NSInteger)index
{
    static NSString * CellIdentifier = @"PageCell";
    static NSInteger CellImageViewTag = 666;
    static NSInteger CellActivityIndicatorTag = 999;
    
    HGPageView * cell = [self.pageScrollView dequeueReusablePageWithIdentifier:CellIdentifier];
    
    if(!cell)
    {
        cell = [[[HGPageView alloc]initWithFrame:self.pageScrollView.bounds] autorelease];
        cell.backgroundColor = [UIColor blackColor];
        
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:cell.bounds];
        imageView.tag = CellImageViewTag;
        [cell addSubview:imageView];
        [imageView release];
        
        UIActivityIndicatorView * spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.hidesWhenStopped = YES;
        spinner.center = CGPointMake(cell.bounds.size.width  /2., cell.bounds.size.height  /2.);
        [cell addSubview:spinner];
        [spinner release];
    }
    UIImageView * imageView = (UIImageView *)[cell viewWithTag:CellImageViewTag];
    UIActivityIndicatorView * spinner = (UIActivityIndicatorView *)[cell viewWithTag:CellActivityIndicatorTag];
    UIImage * image = [self.imagesDictionnary objectForKey:[self.manga.imageURLs objectAtIndex:index]];
    
    if(!image)
    {
       
        
        [spinner startAnimating];
        imageView.hidden = YES;
        
        [self.manga fetchImageAtIndex:index andPerformBlock:^(NSData *imageData) {
            if(!imageData) return;
            [self.imagesDictionnary setObject:[UIImage imageWithData:imageData] forKey:[self.manga.imageURLs objectAtIndex:index]];
            [self.pageScrollView reloadPagesAtIndexes:[NSIndexSet indexSetWithIndex:index]];
        }];
 
    }
    else
    {
        [spinner stopAnimating];
        imageView.image = image;
        imageView.hidden = NO;
    }
    
    return cell;
    
}

- (NSInteger)numberOfPagesInScrollView:(HGPageScrollView *)scrollView
{
    return self.manga.imageURLs.count;
}

- (UIView *)pageScrollView:(HGPageScrollView *)scrollView headerViewForPageAtIndex:(NSInteger)index
{
    return nil;
}

- (NSString *)pageScrollView:(HGPageScrollView *)scrollView titleForPageAtIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"page %d", index];
}


@end
