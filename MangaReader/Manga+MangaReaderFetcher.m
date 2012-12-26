//
//  Manga+MangaReaderFetcher.m
//  MangaReader
//
//  Created by florian BUREL on 26/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import "Manga+MangaReaderFetcher.h"

@implementation Manga (MangaReaderFetcher)

- (void) fetchChapters:(void (^)())completion
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        NSSet * chapters = [MangaReaderFetcher chaperListForMangaURL:[NSURL URLWithString:self.mainURL]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [chapters enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                
                NSString * chapterURL = [obj objectForKey:kMangaURLDictionaryURLKey];
                NSString * chapterTitle = [obj objectForKey:kMangaURLDictionaryDescriptionKey];
                NSNumber * chapterNumber = [NSNumber numberWithInteger:[[chapterTitle substringFromIndex:(chapterTitle.length - 4)] integerValue]];
                
                BOOL already = [[self.chapters objectsPassingTest:^BOOL(id obj, BOOL *stop) {
                    Chapter * tested = (Chapter *)obj;
                    *stop = ([tested.url isEqualToString:chapterURL]);
                    return *stop;
                }] count];
                
                if(!already)
                {
                    Chapter * chapter = (Chapter *) [NSEntityDescription insertNewObjectForEntityForName:@"Chapter" inManagedObjectContext:self.managedObjectContext];
                    chapter.manga = self;
                    chapter.subtitle = chapterTitle;
                    chapter.number = chapterNumber;
                    chapter.url = chapterURL;

                }
            }];
            
            [self.managedObjectContext save:nil];
            
            if(completion) completion();
        });
    });
    
}

@end
