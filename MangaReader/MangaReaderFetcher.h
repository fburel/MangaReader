//
//  MangaReaderFetcher.h
//  MangaReader
//
//  Created by florian BUREL on 12/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MangaReaderFetcher : NSObject

// Retourne une NSArray de String correspondant aux chapitres disponibles
+ (NSSet *) chaperList;

@end
