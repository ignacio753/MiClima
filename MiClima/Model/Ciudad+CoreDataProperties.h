//
//  Ciudad+CoreDataProperties.h
//  
//
//  Created by Ignacio Monge on 5/28/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Ciudad.h"

NS_ASSUME_NONNULL_BEGIN

@interface Ciudad (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSString *name;

@end

NS_ASSUME_NONNULL_END
