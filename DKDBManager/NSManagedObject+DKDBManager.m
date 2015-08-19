//
//  NSManagedObject+DKDBManager.m
//
//  Created by kevin delord on 20/05/14.
//  Copyright (c) 2014 Kevin Delord. All rights reserved.
//

#import "NSManagedObject+DKDBManager.h"

void        CRUDLog(BOOL logEnabled, NSString *format, ...) {
#if defined (DEBUG)
    if (logEnabled == true) {
        va_list args;
        va_start(args, format);
        NSString *content = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        NSLog(@"%@", content);
    }
#else
    // do nothing
#endif
}

@implementation NSManagedObject (DKDBManager)

#pragma mark - CREATE

+ (instancetype)createEntityFromDictionary:(NSDictionary *)dictionary {
    return [self createEntityFromDictionary:dictionary context:nil completion:nil];
}

+ (instancetype)createEntityFromDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context {
    return [self createEntityFromDictionary:dictionary context:context completion:nil];
}

+ (instancetype)createEntityFromDictionary:(NSDictionary *)dictionary completion:(void (^)(id entity, DKDBManagedObjectState status))completion {
    return [self createEntityFromDictionary:dictionary context:nil completion:completion];
}

+ (instancetype)createEntityFromDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context completion:(void (^)(id entity, DKDBManagedObjectState status))completion {

    // now create, save or update an entity
    DKDBManagedObjectState status = DKDBManagedObjectStateSave;

    // If the entity already exist then update it
    id entity = [self MR_findFirstWithPredicate:[self primaryPredicateWithDictionary:dictionary]];
    // Else create a new entity in the given context.
    if (entity == nil) {
        if (context != nil) {
            entity = [self MR_createEntityInContext:context];
        } else {
            // You should always specify a context. This line will be removed in the next versions.
            entity = [self MR_createEntity];
        }
        [entity updateWithDictionary:dictionary];
        status = DKDBManagedObjectStateCreate;
    } else if (DKDBManager.needForcedUpdate || (DKDBManager.allowUpdate && [entity shouldUpdateEntityWithDictionary:dictionary])) {
        // update attributes
        [entity updateWithDictionary:dictionary];
        status = DKDBManagedObjectStateUpdate;
    }

    // Just keeping the valid and managed entities and ignored the unvalid, disabled, non-managed ones.
    if ([entity deleteIfInvalid] == true) {
        entity = nil;
        status = DKDBManagedObjectStateDelete;
    }

    CRUDLog(DKDBManager.verbose && [self verbose] && status == DKDBManagedObjectStateCreate, @"Creating %@ %@", NSStringFromClass([self class]), entity);
    CRUDLog(DKDBManager.verbose && [self verbose] && status == DKDBManagedObjectStateUpdate, @"Updating %@ %@", NSStringFromClass([self class]), entity);

    // if entity exists then save the entity's id.
    [entity saveEntityAsNotDeprecated];

    if (completion) completion(entity, status);
    return entity;
}

+ (NSArray *)createEntitiesFromArray:(NSArray *)array {
    return [self createEntitiesFromArray:array context:nil];
}

+ (NSArray *)createEntitiesFromArray:(NSArray *)array context:(NSManagedObjectContext *)context {

    if (!array || !array.count) return nil;

    NSMutableArray *entities = [NSMutableArray new];
    for (NSDictionary *dictionary in array) {
        id entity = [self createEntityFromDictionary:dictionary context:context];
        if (entity != nil) {
            [entities addObject:entity];
        }
    }
    return entities;
}

#pragma mark - READ

- (id)uniqueIdentifier {
    return self.objectID;
}

- (void)saveEntityAsNotDeprecated {
    //
    // Method to save/store the current object and all its child relations as not deprecated.
    // See: DKDBManager
    //

    [DKDBManager saveEntityAsNotDeprecated:self];
}

- (NSString *)invalidReason {
    // Check if the current entity is valid.
    // Return a NSString containing the reason, nil if the object is valid
    return nil;
}

- (BOOL)shouldUpdateEntityWithDictionary:(NSDictionary *)dictionary {
    // will be ignored if needForcedUpdate == true OR if allowUpdate == true
    return true;
}

+ (BOOL)verbose {
    return false;
}

+ (NSPredicate *)primaryPredicateWithDictionary:(NSDictionary *)dictionary {
    // If returns nil will only take the first entity created (if any) and update it. By doing so only ONE entity will ever be created.
    // If returns a `false predicate` then a new entity will always be created.
    // Otherwise the CRUD process use the entity found by the predicate.
    return nil;
}

+ (NSString *)sortingAttributeName {
    return nil;
}

+ (NSInteger)count {
    return [self MR_countOfEntities];
}

+ (NSArray *)all {
    if (self.sortingAttributeName)
        return [self MR_findAllSortedBy:self.sortingAttributeName ascending:YES];
    return [self MR_findAll];
}

#pragma mark - UPDATE

- (void)updateWithDictionary:(NSDictionary *)dictionary {
    // this method should be overridden on the subclass
}

#pragma mark - DELETE

- (BOOL)deleteIfInvalid {
    NSString *reason = [self invalidReason];
    if (reason != nil) {
        [self deleteEntityWithReason:reason];
        return true;
    }
    return false;
}

- (void)deleteChildEntities {
    // remove all the child of the current object
}

- (void)deleteEntityWithReason:(NSString *)reason {
    CRUDLog(DKDBManager.verbose && self.class.verbose, @"delete %@: %@ Reason: %@", [self class], self, reason);
    
    // remove all the child of the current object
    [self deleteChildEntities];
    
    // remove the current object
    [self MR_deleteEntity];
}

+ (void)deleteAllEntities {
    CRUDLog(DKDBManager.verbose && self.class.verbose, @"delete all %@ entities", [self class]);
    [self MR_deleteAllMatchingPredicate:nil];
}

+ (void)removeDeprecatedEntitiesFromArray:(NSArray *)array {
    // check if all entities are still in the dictionary
    for (id entity in [self MR_findAll]) {
        // if the entity is deprecated (no longer in the dictionary) then remove it !
        if ([entity respondsToSelector:@selector(uniqueIdentifier)]) {
            if (![array containsObject:[entity performSelector:@selector(uniqueIdentifier)]]) {
                [entity deleteEntityWithReason:@"deprecated"];
            }
        }
    }
}

@end
