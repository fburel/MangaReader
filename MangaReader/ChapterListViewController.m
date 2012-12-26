//
//  ChapterListViewController.m
//  MangaReader
//
//  Created by florian BUREL on 13/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import "ChapterListViewController.h"

@interface ChapterListViewController ()

@property (nonatomic, retain) NSFetchedResultsController * fetcher;

@end

@implementation ChapterListViewController
@synthesize fetcher = _fetcher;
@synthesize manga = _manga;

- (void)dealloc
{
    [_manga release];
    [_fetcher release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.manga.title;
    
    // Preparation de la requete de recherche
    NSFetchRequest * request = [[NSFetchRequest alloc]initWithEntityName:@"Chapter"];
    request.predicate = [NSPredicate predicateWithFormat:@"manga == %@", self.manga];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"number" ascending:NO]];
    request.fetchBatchSize = 50;
    self.fetcher = [[[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.manga.managedObjectContext sectionNameKeyPath:nil cacheName:nil] autorelease];
    [request release];

    
    [self setPullDownToRefresh:YES];
    
    [self refresh];

}

- (void) refresh
{
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    
    [self.manga fetchChapters:^{
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        [self.fetcher performFetch:nil];
        [self.tableView reloadData];
        [self endRefreshing];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.fetcher.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.fetcher.sections objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell)
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    
    Chapter * chapter = [self.fetcher objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", self.manga.title, chapter.number];
    
    cell.detailTextLabel.text = chapter.subtitle;
    
    UIImage * image = chapter.downloaded.boolValue ?
    [UIImage imageNamed:@"12-eye"] : [UIImage imageNamed:@"40-inbox"];
    
    cell.accessoryView = [[[UIImageView alloc]initWithImage:image] autorelease];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Chapter * chapter = [self.fetcher objectAtIndexPath:indexPath];
    
    MangaViewController * vc = [[MangaViewController alloc]init];
    vc.chapter = chapter;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

@end
