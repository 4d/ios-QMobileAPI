//
//  PRODUCTS+CoreDataProperties.swift
//  
//
//  Created by Eric Marchand on 29/03/2017.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

extension PRODUCTS {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PRODUCTS> {
        return NSFetchRequest<PRODUCTS>(entityName: "PRODUCTS")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var quantity: Double
    @NSManaged public var reference: String?
    @NSManaged public var taxRate: Double
    @NSManaged public var unitPrice: Double

}
