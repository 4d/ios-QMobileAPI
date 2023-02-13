//
//  Cloudable.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 31/08/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import CloudKit
import Foundation
import Result

protocol Cloudable {}

extension Cloudable {
    #if swift(>=4.2)
    typealias CKRecordID = CKRecord.ID
    #endif

    // https://github.com/Thomvis/FutureProofing/blob/94d42367ab25938a13fe994cf9d6d0cf6ff16ab4/FutureProofing/CloudKit/CKContainer.swift
    func fetchUserRecordID(container: CKContainer = CKContainer.default(), completionHandler: @escaping (Result<CKRecordID, AnyError>) -> Void) {
        container.fetchUserRecordID { recordID, error in
            if let error = error {
                completionHandler(.failure(AnyError(error)))
            } else if let recordID = recordID {
                completionHandler(.success(recordID))
            } else {
                assertionFailure("error and recordID nil.")
            }
        }
    }
}
