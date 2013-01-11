//
//  Chapter+MangaReaderFetcher.h
//  MangaReader
//
//  Created by florian BUREL on 26/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import "Chapter.h"
#import "MangaReaderFetcher.h"
#import "Page.h"

@interface Chapter (MangaReaderFetcher)

- (void) fetchImagesURL:(void (^) ())completion;
@end
