//
//  NSManagedObject+DKDBManager.h
//
//  Created by kevin delord on 20/05/14.
//  Copyright (c) 2014 Kevin Delord. All rights reserved.
//

#import "DKDBManager.h"

typedef NS_ENUM(NSInteger, DKDBManagedObjectState) {
    DKDBManagedObjectStateCreate,
    DKDBManagedObjectStateUpdate,
    DKDBManagedObjectStateSave,
    DKDBManagedObjectStateDelete,
} ;

@interface NSManagedObject (DKDBManager)

#pragma mark - CREATE

+ (instancetype)createEntityFromDictionary:(NSDictionary *)dictionary completion:(void (^)(id entity, DKDBManagedObjectState status))completion;
+ (instancetype)createEntityFromDictionary:(NSDictionary *)dictionary;
+ (NSArray *)createEntitiesFromArray:(NSArray *)array;

#pragma mark - READ

- (id)uniqueIdentifier;
- (void)save;
- (NSString *)invalidReason;
- (BOOL)shouldUpdateEntityWithDictionary:(NSDictionary *)dictionary;
+ (BOOL)verbose;
+ (NSString *)sortingAttributeName;
+ (NSPredicate *)primaryPredicateWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)all;
+ (NSInteger)count;

#pragma mark - UPDATE

- (void)updateWithDictionary:(NSDictionary *)dict;

#pragma mark - DELETE

- (void)deleteChildEntities;
- (void)deleteEntityWithReason:(NSString *)reason;
+ (void)deleteAllEntities;
+ (void)removeDeprecatedEntitiesFromArray:(NSArray *)array;

@end
