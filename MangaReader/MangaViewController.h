//
//  MangaViewController.h
//  MangaReader
//
//  Created by florian BUREL on 13/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Manga.h"
#import "FBReaderView.h"
#import "TapDetectingImageView.h"

@interface MangaViewController : UIViewController
<FBReaderViewDatasource, FBReaderViewDelegate, TapDetectingImageViewDelegate, UIScrollViewDelegate>

@property (nonatomic, retain) Manga * manga;


@end
