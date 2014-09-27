//
//  NSManagedObject+DKDBManager.m
//
//  Created by kevin delord on 20/05/14.
//  Copyright (c) 2014 Kevin Delord. All rights reserved.
//

#import "NSManagedObject+DKDBManager.h"

@implementation NSManagedObject (DKDBManager)

#pragma mark - CREATE

+ (instancetype)createEntityFromDictionary:(NSDictionary *)dictionary {
    return [self createEntityFromDictionary:dictionary completion:nil];
}

+ (instancetype)createEntityFromDictionary:(NSDictionary *)dictionary completion:(void (^)(id entity, DKDBManagedObjectState status))completion {

    // now create, save or update an entity
    DKDBManagedObjectState status = DKDBManagedObjectStateSave;

    // if the entity already exist then update it
    id entity = [self MR_findFirstWithPredicate:[self primaryPredicateWithDictionary:dictionary]];
    // else create a new entity in the current thread MOC
    if (!entity) {
        entity = [self MR_createEntity];
        [entity updateWithDictionary:dictionary];
        status = DKDBManagedObjectStateCreate;
    } else if ([self shouldUpdateEntity:entity withDictionary:dictionary]) {
        // update attributes
        [entity updateWithDictionary:dictionary];
        status = DKDBManagedObjectStateUpdate;
    }

    // Just keeping the valid and managed entities and ignored the unvalid, disabled, non-managed ones.
    if ([entity invalidReason]) {
        [entity deleteEntityWithReason:[entity invalidReason]];
        entity = nil;
        status = DKDBManagedObjectStateDelete;
    }

    DKLog(DKDBManager.verbose && [self verbose] && status == DKDBManagedObjectStateCreate, @"Creating %@ %@", NSStringFromClass([self class]), entity);
    DKLog(DKDBManager.verbose && [self verbose] && status == DKDBManagedObjectStateUpdate, @"Updating %@ %@", NSStringFromClass([self class]), entity);

    // if entity exists then save the entity's id.
    [entity save];

    if (completion) completion(entity, status);
    return entity;
}

+ (NSArray *)createEntitiesFromArray:(NSArray *)array {

    if (!array || !array.count) return nil;

    NSMutableArray *entities = [NSMutableArray new];
    for (NSDictionary *dictionary in array) {
        id entity = [self createEntityFromDictionary:dictionary];
        if (entity)
            [entities addObject:entity];
    }
    return entities;
}

#pragma mark - READ

+ (NSInteger)count {
    return [self MR_countOfEntities];
}

+ (NSArray *)all {
    if (self.sortingAttributeName)
        return [self MR_findAllSortedBy:self.sortingAttributeName ascending:YES];
    return [self MR_findAll];
}

- (void)save {
    //
    // Method to save/store the current object and all its child relations as not deprecated.
    // See: DKDBManager
    //

    [DKDBManager saveEntity:self];
}

#pragma mark - UPDATE

- (void)updateWithDictionary:(NSDictionary *)dict {
    // this method should be overridden on the subclass
}

#pragma mark - DELETE

- (void)deleteEntityWithReason:(NSString *)reason {
    DKLog(DKDBManager.verbose && self.class.verbose, @"delete %@: %@ Reason: %@", [self class], self, reason);
    
    // remove all the child of the current object
    [self deleteChildEntities];
    
    // remove the current object
    [self MR_deleteEntity];
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

#pragma mark - DKDBManagedObject Protocol

- (NSString *)invalidReason {
    // Check if the current entity is valid.
    // Return a NSString containing the reason, nil if the object is valid
    return nil;
}

- (void)deleteChildEntities {
    // remove all the child of the current object
}

+ (BOOL)shouldUpdateEntity:(id)entity withDictionary:(NSDictionary *)dictionary {
    return ((entity && DKDBManager.allowUpdate) || (entity && DKDBManager.needForcedUpdate));
}

+ (BOOL)verbose {
    return NO;
}

+ (NSPredicate *)primaryPredicateWithDictionary:(NSDictionary *)dictionary {
    return nil;
}

+ (NSString *)sortingAttributeName {
    return nil;
}

@end
