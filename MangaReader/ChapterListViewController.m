//
//  ChapterListViewController.m
//  MangaReader
//
//  Created by florian BUREL on 13/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import "ChapterListViewController.h"

@interface ChapterListViewController ()

@property (nonatomic, retain) NSArray * mangas;

@end

@implementation ChapterListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(update) forControlEvents:UIControlEventValueChanged];
    [self update];
}

- (void) update
{
    [Manga fetchMangaListAndPerformBlock:^(NSSet *mangas) {
        NSSortDescriptor * sd = [NSSortDescriptor sortDescriptorWithKey:@"chapterNumber" ascending:YES];
        self.mangas = [mangas sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]];;
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.mangas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell)
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.textLabel.text = [[self.mangas objectAtIndex:indexPath.row] mangaName];
    cell.detailTextLabel.text = [[[self.mangas objectAtIndex:indexPath.row] chapterNumber] stringValue];
    
    // Configure the cell...
    
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Manga * manga = [self.mangas objectAtIndex:indexPath.row];
    
}

@end
