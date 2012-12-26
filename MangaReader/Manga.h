//
//  Manga.h
//  MangaReader
//
//  Created by florian BUREL on 26/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Manga : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * mainURL;
@property (nonatomic, retain) NSSet *chapters;
@end

@interface Manga (CoreDataGeneratedAccessors)

- (void)addChaptersObject:(NSManagedObject *)value;
- (void)removeChaptersObject:(NSManagedObject *)value;
- (void)addChapters:(NSSet *)values;
- (void)removeChapters:(NSSet *)values;

@end
