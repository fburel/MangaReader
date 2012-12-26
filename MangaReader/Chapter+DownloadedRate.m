//
//  Chapter+DownloadedRate.m
//  MangaReader
//
//  Created by florian BUREL on 26/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import "Chapter+DownloadedRate.h"

@implementation Chapter (DownloadedRate)

- (float)downloadedRate
{
    float nbPagesTotal = self.pages.count;
    float nbPagesDonwloaded = [[self.pages objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        return [[obj isDownloaded] boolValue];
    }] count];
    
    return nbPagesTotal != 0 ? nbPagesDonwloaded/nbPagesTotal : 0;
}
@end
