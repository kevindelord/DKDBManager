//
//  NSManagedObject+DKDBManager.h
//  WhiteWall
//
//  Created by kevin delord on 20/05/14.
//  Copyright (c) 2014 Kevin Delord. All rights reserved.
//

#import "DKDBManager.h"

@protocol DKDBManagedObject <NSObject>
@required
- (NSString *)uniqueIdentifier;
@optional
- (NSString *)invalidReason;
- (void)deleteChildEntities;
+ (BOOL)shouldUpdateEntity:(id)entity withDictionary:(NSDictionary *)dictionary;
+ (BOOL)verbose;
+ (NSString *)sortingAttributeName;
+ (NSPredicate *)primaryPredicateWithDictionary:(NSDictionary *)dictionary;
@end

typedef enum : NSUInteger {
    DKDBManagedObjectStateCreate,
    DKDBManagedObjectStateUpdate,
    DKDBManagedObjectStateSave,
    DKDBManagedObjectStateDelete,
} DKDBManagedObjectState;

@interface NSManagedObject (DKDBManager)

#pragma mark - CREATE

+ (instancetype)createEntityFromDictionary:(NSDictionary *)dictionary completion:(void (^)(id entity, DKDBManagedObjectState status))completion;
+ (instancetype)createEntityFromDictionary:(NSDictionary *)dictionary;
+ (NSArray *)createEntitiesFromArray:(NSArray *)array;

#pragma mark - READ

- (void)save;
+ (NSArray *)all;
+ (NSInteger)count;

#pragma mark - UPDATE

- (void)updateWithDictionary:(NSDictionary *)dict;

#pragma mark - DELETE

- (void)deleteEntityWithReason:(NSString *)reason;
+ (void)removeDeprecatedEntitiesFromArray:(NSArray *)array;

#pragma mark - DKDBManagedObject Protocol

//
// As this class does NOT implement the DKDBManagedObject protocol we have to declare all methods in order to let the subclass overwrite them.
//

- (NSString *)invalidReason;
- (void)deleteChildEntities;
+ (BOOL)shouldUpdateEntity:(id)entity withDictionary:(NSDictionary *)dictionary;
+ (BOOL)verbose;
+ (NSString *)sortingAttributeName;
+ (NSPredicate *)primaryPredicateWithDictionary:(NSDictionary *)dictionary;

@end
