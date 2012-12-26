//
//  ChapterListViewController.h
//  MangaReader
//
//  Created by florian BUREL on 13/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Manga+MangaReaderFetcher.h"
#import "Chapter+MangaReaderFetcher.h"
#import "Chapter+DownloadedRate.h"
#import "MangaViewController.h"
#import "UITableViewController+PullDownToRefresh.h"

@interface ChapterListViewController : UITableViewController

@property (readwrite, nonatomic, retain) Manga * manga;

@end
