//
//  FBImageReaderView.h
//  MangaReader
//
//  Created by florian BUREL on 16/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FBReaderView;

@protocol FBReaderViewDatasource <NSObject>

- (NSInteger)numberOfPageInReaderView:(FBReaderView *)imageReaderView;
- (UIView *)readerView:(FBReaderView *)readerView viewAtIndex:(NSInteger)index;

@end

@protocol FBReaderViewDelegate <NSObject>
@optional
- (void)readerView:(FBReaderView *)readerView willPresentViewAtIndex:(NSInteger)index;

@end
@interface FBReaderView : UIView

@property (nonatomic, assign) id<FBReaderViewDatasource> dataSource;
@property (nonatomic, assign) id<FBReaderViewDelegate> delegate;

@property (nonatomic, assign) NSInteger indexForPresentedView;
- (void) reloadViewAtIndex:(NSInteger)index;
- (void)reloadData;

@end
