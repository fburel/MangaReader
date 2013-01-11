//
//  UITableViewController+PullDownToRefresh.h
//  
//
//  Created by Florian BUREL on 17/12/11.
//
//  Inspired by :
//  PullRefreshTableViewController.h
//  Plancast
//
//  Created by Leah Culver on 7/2/10.
//  Copyright (c) 2010 Leah Culver
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

// The tag number that will be given to the tableView header
// It is critical that no other view inside the tableView share this number
#define kPullToRefreshHeaderViewTag             40810

// The size for the headerView
#define kPullToRefreshHeaderHeight              52

@interface UITableViewController (PullDownToRefresh)


// The methods to overide :-)
- (void)refresh;

// You can call this methods once your done with your update method
- (void) endRefreshing;

// Overide those getters with your custom text for the "pull to refresh", "release to refresh" and "refreshing" NSStrings
@property (readonly) NSString * textPull;

@property (readonly) NSString * textRelease;

@property (readonly) NSString * textLoading;

// Setting this value to YES or NO will add the header View to your code
@property (assign, nonatomic) BOOL pullDownToRefresh;


@end
