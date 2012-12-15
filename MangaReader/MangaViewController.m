//
//  MangaViewController.m
//  MangaReader
//
//  Created by florian BUREL on 13/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import "MangaViewController.h"

@interface MangaViewController ()

@end

@implementation MangaViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if(!self.manga.imageURLs)
    {
        UIView * waitView = [[UIView alloc]initWithFrame:self.collectionView.bounds];
        waitView.backgroundColor = [UIColor redColor];
        
        [self.collectionView addSubview:waitView];
        
        dispatch_async(dispatch_get_global_queue(2, 0), ^{
            [self.manga fetchURLs];
            [self.collectionView reloadData];
            [waitView removeFromSuperview];
        });
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.toolbarHidden = NO;
}

@end
