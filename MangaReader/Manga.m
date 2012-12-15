//
//  Manga.m
//  MangaReader
//
//  Created by florian BUREL on 13/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import "Manga.h"
#import "MangaReaderFetcher.h"

@implementation Manga (MangaReaderFetcher)

+ (void) fetchMangaListAndPerformBlock:(void (^)(NSSet * mangas))mangaBlock
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        NSSet * chapters = [MangaReaderFetcher chaperListForMangaURL:nil];
        
        NSMutableSet * mangas = [NSMutableSet setWithCapacity:chapters.count];
        
        
        [chapters enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            Manga * manga = [[Manga alloc]init];
            manga.mangaName = @"One Piece";
            manga.chapterNumber = [NSNumber numberWithInt:[[obj objectForKey:kMangaURLDictionaryDescriptionKey] intValue]];
            manga.mainPageURL = [obj objectForKey:kMangaURLDictionaryURLKey];
            
            [mangas addObject:manga];
            [manga release];
            
        }];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            mangaBlock([NSSet setWithSet:mangas]);
        });
        
    });
}
- (void) fetchURLs
{
    if(!self.imageURLs)
        self.imageURLs = [MangaReaderFetcher imagesURLFromMainPage:self.mainPageURL];
}


@end

@implementation Manga


@end