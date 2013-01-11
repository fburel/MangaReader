//
//  Manga+MangaReaderFetcher.h
//  MangaReader
//
//  Created by florian BUREL on 26/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import "Manga.h"
#import "Chapter.h"
#import "MangaReaderFetcher.h"

@interface Manga (MangaReaderFetcher)

- (void) fetchChapters:(void (^)())completion;

@end
