//
//  FBZoomableImageView.h
//  MangaReader
//
//  Created by Florian BUREL on 25/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBZoomableImageView : UIScrollView
<UIScrollViewDelegate>

@property (readwrite, nonatomic, copy) UIImage * image;
            
@end
