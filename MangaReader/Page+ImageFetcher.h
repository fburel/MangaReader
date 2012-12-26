//
//  Page+ImageFetcher.h
//  MangaReader
//
//  Created by florian BUREL on 26/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import "Page.h"

@interface Page (ImageFetcher)

- (void) fetchImageData:(void(^)(NSData * imageData))completion;

@end
