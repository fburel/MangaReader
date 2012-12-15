//
//  Manga.h
//  MangaReader
//
//  Created by florian BUREL on 13/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Manga : NSObject

@property (nonatomic, retain) NSString * mangaName;
@property (nonatomic, retain) NSString * chapterTitle;
@property (nonatomic, retain) NSNumber * chapterNumber;
@property (nonatomic, retain) NSArray * imageURLs;
@property (nonatomic, retain) NSURL * mainPageURL;

@end

@interface Manga (MangaReaderFetcher)

+ (void) fetchMangaListAndPerformBlock:(void (^)(NSSet * mangas))mangaBlock;
- (void) fetchURLs;

@end
