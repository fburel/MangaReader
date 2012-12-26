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

#define kPullToRefreshHeaderViewLabel       1234
#define kPullToRefreshHeaderViewSpinner     1235
#define kPullToRefreshHeaderViewImage       1236

#pragma mark - enabling  / disabling

- (BOOL) pullDownToRefresh
{
    return [self.tableView viewWithTag:kPullToRefreshHeaderViewTag] != nil;
}

- (void) setPullDownToRefresh:(BOOL)pullDownToRefresh
{
    if(pullDownToRefresh && !self.pullDownToRefresh) [self.tableView addSubview:[self pullToRefreshHeaderView]];
    else if(!pullDownToRefresh) [[self pullToRefreshHeaderView]removeFromSuperview];
}


#pragma mark - getters & setters

- (UIView *) pullToRefreshHeaderView
{
    UIView * refreshHeaderView = [self.tableView viewWithTag:kPullToRefreshHeaderViewTag];
    if(!refreshHeaderView)
    {
        refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - kPullToRefreshHeaderHeight, 320, kPullToRefreshHeaderHeight)];
        refreshHeaderView.backgroundColor = [UIColor clearColor];
        refreshHeaderView.tag = kPullToRefreshHeaderViewTag;
        
        UILabel * refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, kPullToRefreshHeaderHeight)];
        refreshLabel.backgroundColor = [UIColor clearColor];
        refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
        refreshLabel.textAlignment = UITextAlignmentCenter;
        refreshLabel.tag = kPullToRefreshHeaderViewLabel;
        
        UIImageView * refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
        refreshArrow.frame = CGRectMake(floorf((kPullToRefreshHeaderHeight - 27) / 2),
                                        (floorf(kPullToRefreshHeaderHeight - 44) / 2),
                                        27, 44);
        refreshArrow.tag = kPullToRefreshHeaderViewImage;
        
        
        UIActivityIndicatorView * refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        refreshSpinner.frame = CGRectMake(floorf(floorf(kPullToRefreshHeaderHeight - 20) / 2), floorf((kPullToRefreshHeaderHeight - 20) / 2), 20, 20);
        refreshSpinner.hidesWhenStopped = YES;
        refreshSpinner.tag = kPullToRefreshHeaderViewSpinner;
        
        [refreshHeaderView addSubview:refreshLabel];
        [refreshHeaderView addSubview:refreshArrow];
        [refreshHeaderView addSubview:refreshSpinner];
        
        [refreshLabel release];
        [refreshArrow release];
        [refreshSpinner release];
        
        [refreshHeaderView autorelease];
    }
    return refreshHeaderView;
}

- (UILabel *) pullToRefreshLabel
{
    return (UILabel *)[[self pullToRefreshHeaderView]viewWithTag:kPullToRefreshHeaderViewLabel];
}

- (UIActivityIndicatorView *) pullToRefreshSpinner
{
    return (UIActivityIndicatorView *)[[self pullToRefreshHeaderView]viewWithTag:kPullToRefreshHeaderViewSpinner];

}

- (UIImageView *) pullToRefreshArrow
{
    return (UIImageView *)[[self pullToRefreshHeaderView]viewWithTag:kPullToRefreshHeaderViewImage];
}

#pragma mark - scrollViewDelegate methods (to detect the scrolling)

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView 
{
    if(isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (isLoading) 
    {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            self.tableView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -kPullToRefreshHeaderHeight)
            self.tableView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } 
    else if (isDragging && scrollView.contentOffset.y < 0) 
    {
        [UIView animateWithDuration:0.25 animations:^{
            if (scrollView.contentOffset.y < -kPullToRefreshHeaderHeight) {
                // User is scrolling above the header
                [self setPullDownToRefreshText:self.textRelease];
                [[self pullToRefreshArrow] layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            } else {
                // User is scrolling somewhere within the header
                [self setPullDownToRefreshText:self.textPull];
                [[self pullToRefreshArrow] layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
        }];
   
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate 
{
    if(isLoading) return;
    isDragging = NO;
    
    if (scrollView.contentOffset.y <= -kPullToRefreshHeaderHeight)
    {
           
        isLoading = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.contentInset = UIEdgeInsetsMake(kPullToRefreshHeaderHeight, 0, 0, 0);
            [self setPullDownToRefreshText:self.textLoading];
            [self pullToRefreshArrow].hidden = YES;
            [[self pullToRefreshSpinner] startAnimating];
        }];
        [self refresh]; 
    }
}

- (void) endRefreshing
{
    isLoading = NO;
    
    [UIView animateWithDuration:0.3
                     animations:^
    {
        self.tableView.contentInset = UIEdgeInsetsZero;
        [[self pullToRefreshArrow] layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    }
                     completion:^(BOOL finished)
    {
                         [self setPullDownToRefreshText:self.textPull];
                         [[self pullToRefreshArrow]setHidden:NO];
                         [[self pullToRefreshSpinner]stopAnimating];
    }];
}

- (void)refresh 
{
    [self endRefreshing];

}


#pragma mark - Text value changing management

- (void) setPullDownToRefreshText:(NSString *)text
{
    [[self pullToRefreshLabel]setText:text];
}

#pragma mark - default value for the Strings

- (NSString *) textPull
{
    return NSLocalizedString(@"Pull to refresh...", nil);
}

- (NSString *) textRelease
{
    return NSLocalizedString(@"Release to refresh...", nil);
}

- (NSString *) textLoading
{
    return NSLocalizedString(@"Loading...", nil);
}


@end
