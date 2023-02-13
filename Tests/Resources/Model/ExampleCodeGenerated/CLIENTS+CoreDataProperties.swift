//
//  CLIENTS+CoreDataProperties.swift
//  
//
//  Created by Eric Marchand on 29/03/2017.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

extension CLIENTS {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CLIENTS> {
        return NSFetchRequest<CLIENTS>(entityName: "CLIENTS")
    }

    @NSManaged public var address1: String?
    @NSManaged public var address2: String?
    @NSManaged public var city: String?
    @NSManaged public var contact: String?
    @NSManaged public var country: String?
    @NSManaged public var discountRate: Double
    @NSManaged public var email: String?
    @NSManaged public var fax: String?
    @NSManaged public var id: Int32
    @NSManaged public var lat: Double
    @NSManaged public var lon: Double
    @NSManaged public var mobile: String?
    @NSManaged public var name: String?
    @NSManaged public var state: String?
    @NSManaged public var totalSales: Double
    @NSManaged public var webSite: String?
    @NSManaged public var zipCode: String?

}
