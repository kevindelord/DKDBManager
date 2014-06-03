//
//  NSManagedObject+DKDBManager.m
//  WhiteWall
//
//  Created by kevin delord on 20/05/14.
//  Copyright (c) 2014 Smartmobilefactory. All rights reserved.
//

#import "NSManagedObject+DKDBManager.h"

@implementation NSManagedObject (DKDBManager)

#pragma mark - CREATE

+ (instancetype)createEntityFromDictionary:(NSDictionary *)dictionary {
    return [self createEntityFromDictionary:dictionary completion:nil];
}

+ (instancetype)createEntityFromDictionary:(NSDictionary *)dictionary completion:(void (^)(id entity, DKDBManagedObjectState status))completion {

    // now create or update an entity
    BOOL creating = false;
    // if the entity already exist then update it
    id entity = [self MR_findFirstWithPredicate:[self primaryPredicateWithDictionary:dictionary]];
    // else create a new entity in the current thread MOC
    if (!entity) {
        entity = [self MR_createEntity];
        creating = true;
    } else if ([self shouldNotUpdateEntity:entity withDictionary:dictionary]) {
        if ([entity invalidReason]) {
            [entity deleteEntityWithReason:[entity invalidReason]];
            if (completion) completion(entity, DKDBManagedObjectStateDelete);
            return nil;
        } else {
            // save the product as not deprecated and go on the next question
            [entity saveID];
            if (completion) completion(entity, DKDBManagedObjectStateSave);
            return entity;
        }
    }

    // update attributes
    [entity updateWithDictionary:dictionary];

    // Just keeping the valid and managed products and ignored the unvalid, disabled, non-managed ones.
    if ([entity invalidReason]) {
        [entity deleteEntityWithReason:[entity invalidReason]];
        if (completion) completion(entity, DKDBManagedObjectStateDelete);
        return nil;
    }
    DKLog(DKDBManager.verbose && [self verbose], @"%@ %@ %@", (creating ? @"Creating" : @"Updating"), NSStringFromClass([self class]), entity);
    [entity saveID];
    if (completion) completion(entity, creating? DKDBManagedObjectStateCreate : DKDBManagedObjectStateUpdate);
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

- (void)saveID {
    //
    // Method to save/store the current object and all its child relations as not deprecated.
    // See: DKDBManager
    //

    if ([self respondsToSelector:@selector(uniqueIdentifier)]) {
        [DKDBManager saveId:[self performSelector:@selector(uniqueIdentifier)] forEntity:NSStringFromClass([self class])];
    }
}

#pragma mark - UPDATE

- (void)updateWithDictionary:(NSDictionary *)dict {
    // this methid should be overwriten on the subclass
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

+ (BOOL)shouldNotUpdateEntity:(id)entity withDictionary:(NSDictionary *)dictionary {
    return ((!DKDBManager.allowUpdate) || (entity && !DKDBManager.needForcedUpdate));
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
