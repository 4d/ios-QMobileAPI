//
//  APIManager+Create.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 08/08/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

extension APIManager {
    /// create new record
    public func createRecordJSON(
        table: Table,
        key: CustomStringConvertible,
        completionHandler: @escaping CompletionRecordJSONHandler) -> Cancellable {
        let target = base.record(from: table.name, key: key)
        target.restMethod(.update)

        return self.request(target, completion: completionHandler)
    }

    /// Create or update a record
    public func createOrUpdate(
        recordJSON: RecordJSON,
        callbackQueue: DispatchQueue? = nil,
        completionHandler: CompletionRecordJSONHandler? = nil) -> Cancellable {
        let target = base.records(from: recordJSON.tableName)
        target.restMethod(.update)
        target.parameters = recordJSON.dictionaryObject ?? [:]

        let completion: APIManager.Completion = { result in
            completionHandler?(result.map(to: RecordJSON.self))
        }

        return self.request(target, callbackQueue: callbackQueue, completion: completion)
    }

    /// Alias for [RecordJSON]
    public typealias CompletionRecordJSONsHandler = ((Result<[RecordJSON], APIError>) -> Void)
    public func createOrUpdate(
        recordJSONs: [RecordJSON],
        callbackQueue: DispatchQueue? = nil,
        completionHandler: CompletionRecordJSONsHandler? = nil) -> Cancellable {
        let cancellable = CancellableComposite()
        let byTable = recordJSONs.dictionaryBy { $0.tableName }
        for (tableName, records) in byTable {
            let target = base.records(from: tableName)
            target.restMethod(.update)
            target.parameters = ["": records.map { $0.dictionaryObject ?? [:] }] // TODO how to post a json array!

            let completion: APIManager.Completion = { result in
                // TODO check __ERROR in json result
                completionHandler?(result.map(to: [RecordJSON.self]))
            }

            let c = self.request(target, callbackQueue: callbackQueue, completion: completion)
            cancellable.append(c)
        }
        // TODO have a real completion and progress handler if multiple table..
        return cancellable
    }

    /// create a new entityset (could be done by using configuration of RecordsRequest of `loadPage``)
    public func createEntitySet(
        tableName: String,
        callbackQueue: DispatchQueue? = nil,
        configure: ConfigureRecordsRequest? = nil,
        completionHandler: @escaping CompletionPageHandler) -> Cancellable {
        let target = base.records(from: tableName)
        target.restMethod(.entityset)

        return self.recordPage(
            tableName: tableName,
            recursive: false,
            configure: configure,
            callbackQueue: callbackQueue,
            completionHandler: completionHandler)
    }
}
