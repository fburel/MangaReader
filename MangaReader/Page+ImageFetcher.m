//
//  Page+ImageFetcher.m
//  MangaReader
//
//  Created by florian BUREL on 26/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import "Page+ImageFetcher.h"

@implementation Page (ImageFetcher)

- (void)fetchImageData:(void (^)(NSData *))completion
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.serverURL]];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(imageData);
        });
    });
}
@end
