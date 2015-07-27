//
//  Runner+Helpers.m
//  DBTest
//
//  Created by kevin delord on 01/10/14.
//  Copyright (c) 2014 kevin delord. All rights reserved.
//

#import "Runner+Helpers.h"

@implementation Runner (Helpers)

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ : %@ - %@", self.objectID.URIRepresentation.lastPathComponent, self.name, self.position];
}

- (id)uniqueIdentifier {
    return self.objectID;
}

- (void)updateWithDictionary:(NSDictionary *)dict {
    self.name = GET_STRING(dict, @"name");
    self.position = GET_NUMBER(dict, @"position");
}

- (NSString *)invalidReason {
    return nil;
}

- (void)deleteChildEntities {
    [super deleteChildEntities];
}

- (void)saveEntityAsNotDeprecated {
    [super saveEntityAsNotDeprecated];
}

+ (BOOL)verbose {
    return true;
}

+ (NSString *)sortingAttributeName {
      return @"position";
}

+ (NSPredicate *)primaryPredicateWithDictionary:(NSDictionary *)dictionary {
    return [NSPredicate predicateWithFormat:@"name ==[c] %@", GET_STRING(dictionary, @"name")];
}

- (BOOL)shouldUpdateEntityWithDictionary:(NSDictionary *)dictionary {
    return true;
}

+ (void)countEntity {
    NSLog(@"%@", Runner.MR_findAll);
}

@end
