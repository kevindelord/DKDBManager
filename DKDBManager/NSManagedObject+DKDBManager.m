//
//  NSManagedObject+DKDBManager.m
//
//  Created by kevin delord on 20/05/14.
//  Copyright (c) 2014 Kevin Delord. All rights reserved.
//

#import "NSManagedObject+DKDBManager.h"

void        CRUDLog(BOOL logEnabled, NSString * _Nonnull format, ...) {
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

+ (instancetype _Nullable)createEntityFromDictionary:(NSDictionary * _Nullable)dictionary context:(NSManagedObjectContext * _Nonnull)context {
    return [self createEntityFromDictionary:dictionary context:context completion:nil];
}

+ (instancetype _Nullable)createEntityFromDictionary:(NSDictionary * _Nullable)dictionary context:(NSManagedObjectContext * _Nonnull)context completion:(void (^ _Nullable)(id _Nullable entity, DKDBManagedObjectState status))completion {

    // now create, save or update an entity
    DKDBManagedObjectState status = DKDBManagedObjectStateSave;

    // If the entity already exist then update it
	id entity = [self MR_findFirstWithPredicate:[self primaryPredicateWithDictionary:dictionary] inContext:context];
    // Else create a new entity in the given context.
    if (entity == nil) {
		entity = [self MR_createEntityInContext:context];
        [entity updateWithDictionary:dictionary];
        status = DKDBManagedObjectStateCreate;
    } else if (DKDBManager.needForcedUpdate || (DKDBManager.allowUpdate && [entity shouldUpdateEntityWithDictionary:dictionary])) {
        // update attributes
        [entity updateWithDictionary:dictionary];
        status = DKDBManagedObjectStateUpdate;
    }

    // Just keeping the valid and managed entities and ignored the unvalid, disabled, non-managed ones.
    if ([entity deleteIfInvalidInContext:context] == true) {
        entity = nil;
        status = DKDBManagedObjectStateDelete;
    }

    CRUDLog(DKDBManager.verbose && [self verbose] && status == DKDBManagedObjectStateCreate, @"Creating %@ %@", NSStringFromClass([self class]), entity);
    CRUDLog(DKDBManager.verbose && [self verbose] && status == DKDBManagedObjectStateUpdate, @"Updating %@ %@", NSStringFromClass([self class]), entity);

    // if entity exists then save the entity's id.
    [entity saveEntityAsNotDeprecated];

	if (completion != nil) {
		completion(entity, status);
	}
    return entity;
}

+ (NSArray * _Nullable)createEntitiesFromArray:(NSArray * _Nonnull)array context:(NSManagedObjectContext * _Nonnull)context {

	if (array == nil || array.count == 0) {
		return nil;
	}

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

- (id _Nonnull)uniqueIdentifier {
    return self.objectID;
}

- (void)saveEntityAsNotDeprecated {
    //
    // Method to save/store the current object and all its child relations as not deprecated.
    // See: DKDBManager
    //
    [DKDBManager saveEntityAsNotDeprecated:self];
}

- (NSString * _Nullable)invalidReason {
    // Check if the current entity is valid.
    // Return a NSString containing the reason, nil if the object is valid
    return nil;
}

- (BOOL)shouldUpdateEntityWithDictionary:(NSDictionary * _Nullable)dictionary {
    // will be ignored if needForcedUpdate == true OR if allowUpdate == true
    return true;
}

+ (BOOL)verbose {
    return false;
}

+ (NSPredicate * _Nullable)primaryPredicateWithDictionary:(NSDictionary * _Nullable)dictionary {
    // If returns nil will only take the first entity created (if any) and update it. By doing so only ONE entity will ever be created.
    // If returns a `false predicate` then a new entity will always be created.
    // Otherwise the CRUD process use the entity found by the predicate.
    return nil;
}

+ (NSString * _Nullable)sortingAttributeName {
    return nil;
}

+ (NSInteger)countInContext:(NSManagedObjectContext * _Nonnull)context {
    return [self MR_countOfEntitiesWithContext:context];
}

+ (NSInteger)count {
	return [self countInContext:NSManagedObjectContext.MR_defaultContext];
}

+ (NSArray * _Nullable)allInContext:(NSManagedObjectContext * _Nonnull)context {
	if (self.sortingAttributeName != nil) {
		return [self MR_findAllSortedBy:self.sortingAttributeName ascending:YES inContext:context];
	}
    return [self MR_findAllInContext:context];
}

+ (NSArray * _Nullable)all {
	return [self allInContext:NSManagedObjectContext.MR_defaultContext];
}

#pragma mark - UPDATE

- (void)updateWithDictionary:(NSDictionary * _Nullable)dictionary {
    // this method should be overridden on the subclass
}

#pragma mark - DELETE

- (BOOL)deleteIfInvalidInContext:(NSManagedObjectContext * _Nonnull)context {
    NSString *reason = [self invalidReason];
    if (reason != nil) {
        [self deleteEntityWithReason:reason inContext:context];
        return true;
    }
    return false;
}

- (void)deleteChildEntitiesInContext:(NSManagedObjectContext *)context {
    //
    // remove all the child of the current object
    // Example in Swift:
    // for page in book.pages {
    //      page.deleteEntityWithReason("parent book removed", context: context)
    // }
}

- (void)deleteEntityWithReason:(NSString * _Nullable)reason inContext:(NSManagedObjectContext * _Nonnull)context {
	CRUDLog(DKDBManager.verbose && self.class.verbose, @"delete %@: %@ Reason: %@", [self class], self, (reason != nil ? reason : @"n/a"));

    // remove all the child of the current object
    [self deleteChildEntitiesInContext:context];
    
    // remove the current object
	[self MR_deleteEntityInContext:context];
}

+ (void)deleteAllEntitiesInContext:(NSManagedObjectContext *)context {
    CRUDLog(DKDBManager.verbose && self.class.verbose, @"delete all %@ entities in context %@", [self class], context);
	NSPredicate *truePredicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
    [self MR_deleteAllMatchingPredicate:truePredicate inContext:context];
}

+ (void)removeDeprecatedEntitiesFromArray:(NSArray *)array inContext:(NSManagedObjectContext * _Nonnull)context {
    // check if all entities are still in the dictionary
    NSArray *allEntities = [self MR_findAllInContext:context];
    for (id entity in allEntities) {
        // if the entity is deprecated (no longer in the dictionary) then remove it !
        if ([entity respondsToSelector:@selector(uniqueIdentifier)]) {
            if ([array containsObject:[entity performSelector:@selector(uniqueIdentifier)]] == false) {
                [entity deleteEntityWithReason:@"deprecated" inContext:context];
            }
        }
    }
}

@end
