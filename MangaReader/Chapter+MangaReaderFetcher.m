//
//  Chapter+MangaReaderFetcher.m
//  MangaReader
//
//  Created by florian BUREL on 26/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import "Chapter+MangaReaderFetcher.h"

@implementation Chapter (MangaReaderFetcher)

- (void)fetchImagesURL:(void (^)())completion
{
    if(!self.pages.count)
    {
        dispatch_async(dispatch_get_global_queue(2, 0), ^{
            NSArray  * imagesURLString = [MangaReaderFetcher imagesURLFromMainPage:[NSURL URLWithString:self.url]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [imagesURLString enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    Page * page = [NSEntityDescription insertNewObjectForEntityForName:@"Page" inManagedObjectContext:self.managedObjectContext];
                    page.number = [NSNumber numberWithInteger:idx];
                    page.serverURL = obj;
                    page.localURL = nil;
                    page.chapter = self;
                }];
                if(completion)completion();
            });
        });
    }
    else if(completion) completion();
}
@end
