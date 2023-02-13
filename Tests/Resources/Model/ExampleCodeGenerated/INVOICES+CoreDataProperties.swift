//
//  INVOICES+CoreDataProperties.swift
//  
//
//  Created by Eric Marchand on 29/03/2017.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

extension INVOICES {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<INVOICES> {
        return NSFetchRequest<INVOICES>(entityName: "INVOICES")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var id: Int32
    @NSManaged public var invoiceNumber: String?
    @NSManaged public var paid: Bool
    @NSManaged public var payementDate: NSDate?
    @NSManaged public var payementDelay: String?
    @NSManaged public var payementMethod: String?
    @NSManaged public var payementReference: String?
    @NSManaged public var proForma: Bool
    @NSManaged public var proformaNumber: String?
    @NSManaged public var subtotal: Double
    @NSManaged public var tax: Double
    @NSManaged public var total: Double

}
