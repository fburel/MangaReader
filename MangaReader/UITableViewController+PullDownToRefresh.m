//
//  UITableViewController+PullDownToRefresh.m
//  FeedL
//
//  Created by Florian BUREL on 17/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UITableViewController+PullDownToRefresh.h"

@implementation UITableViewController (PullDownToRefresh)


#pragma mark - default values

BOOL isLoading = NO;

BOOL isDragging = NO;

BOOL _pullDownToRefresh = NO;

NSInteger _refreshHeaderHeight = 52.0;


#pragma mark - getters & setters

- (BOOL) pullDownToRefresh
{
    return _pullDownToRefresh;
}

- (void) setPullDownToRefresh:(BOOL)pullDownToRefresh
{
    _pullDownToRefresh = pullDownToRefresh;
}

- (NSInteger) refreshHeaderHeight
{
    return _refreshHeaderHeight;
}

- (void) setRefreshHeaderHeight:(NSInteger)refreshHeaderHeight
{
    _refreshHeaderHeight = refreshHeaderHeight;
}


#pragma mark - scrollViewDelegate methods (to detect the scrolling)

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView 
{
    if(!_pullDownToRefresh || isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!_pullDownToRefresh) return;
   
    if (isLoading) 
    {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            self.tableView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -self.refreshHeaderHeight)
            self.tableView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } 
    else if (isDragging && scrollView.contentOffset.y < 0) 
    {
        if (scrollView.contentOffset.y < -self.refreshHeaderHeight)
            [self setPullDownToRefreshText:self.textRelease];
        else 
            [self setPullDownToRefreshText:self.textPull];        
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate 
{
    if(!_pullDownToRefresh || isLoading) return;
    isDragging = NO;
    
    if (scrollView.contentOffset.y <= -self.refreshHeaderHeight)
    {
        [self setPullDownToRefreshText:self.textPull];    
        isLoading = YES;
        [self refresh]; 
    }
}

- (void) didFinishLoading 
{
      
    isLoading = NO;
    [self setPullDownToRefreshText:self.textPull];
}

#pragma mark - Override those methods in you tableViewController

// Code to update the content of the tableView
// You are responsible for sending  the did finish loading message to self at the proper time.
- (void)refresh 
{
    [self didFinishLoading];

}

// Override this methods if you wich to inform the user about the different state of the process.
// The text received will be self.textPull, self.textRelease or self.textLoading
- (void) setPullDownToRefreshText:(NSString *)text
{
    self.title = text;
}

// You can override the NSString méthods with your custom text - this is the text of the normal state
- (NSString *) textPull
{
    return nil;
}

// You can override the NSString méthods with your custom text - this is displayed while user is dragging lower than the header
- (NSString *) textRelease
{
    return nil;
}

// You can override the NSString méthods with your custom text - this is the text displayed while the data are loading
- (NSString *) textLoading
{
    return nil;
}


@end
