//
//  APIManager+Delete.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 08/08/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya
import Result

extension APIManager {
    // delete record
    public func delete(recordJSON: RecordJSON, completionHandler: CompletionStatusHandler? = nil) -> Cancellable? {
        if let key = recordJSON.key {
            return self.deleteRecord(tableName: recordJSON.tableName, key: key, completionHandler: completionHandler)
        } else {
            completionHandler?(.success(Status(ok: false)))
            return nil
        }
    }
    public func deleteRecord(
        tableName: String,
        key: CustomStringConvertible,
        callbackQueue: DispatchQueue? = nil,
        completionHandler: CompletionStatusHandler? = nil) -> Cancellable {
        let target = base.record(from: tableName, key: key)
        target.restMethod(.delete)

        let completion: APIManager.Completion = { result in
            completionHandler?(result.map(to: Status.self))
        }

        return self.request(target, callbackQueue: callbackQueue, completion: completion)
    }

    // delete records
    public func deleteRecords(
        tableName: String,
        configure: ConfigureRecordsRequest? = nil,
        callbackQueue: DispatchQueue? = nil,
        completionHandler: CompletionStatusHandler? = nil) -> Cancellable {
        let target = base.records(from: tableName)
        target.restMethod(.delete)

        configure?(target)

        let completion: APIManager.Completion = { result in
            completionHandler?(result.map(to: Status.self))
        }

        return self.request(target, callbackQueue: callbackQueue, completion: completion)
    }

    // delete entity set
    public func delete(entitySet: EntitySet, callbackQueue: DispatchQueue? = nil, completionHandler: CompletionStatusHandler? = nil) -> Cancellable {
       return self.deleteEntitySet(tableName: entitySet.tableName, setID: entitySet.id, completionHandler: completionHandler)
    }
    public func deleteEntitySet(
        tableName: String,
        setID: String,
        callbackQueue: DispatchQueue? = nil,
        completionHandler: CompletionStatusHandler? = nil) -> Cancellable {
        let target = base.records(from: tableName).set(setID)
        target.restMethod(.delete)

        let completion: APIManager.Completion = { result in
            completionHandler?(result.map(to: Status.self))
        }

        return self.request(target, callbackQueue: callbackQueue, completion: completion)
    }

    // release entity set from cache

    public func release(entitySet: EntitySet, callbackQueue: DispatchQueue? = nil, completionHandler: CompletionStatusHandler? = nil) -> Cancellable {
        return self.releaseEntitySet(tableName: entitySet.tableName, setID: entitySet.id, completionHandler: completionHandler)
    }
    public func releaseEntitySet(
        tableName: String,
        setID: String,
        callbackQueue: DispatchQueue? = nil,
        completionHandler: CompletionStatusHandler? = nil) -> Cancellable {
        let target = base.records(from: tableName).set(setID)
        target.restMethod(.release)

        let completion: APIManager.Completion = { result in
            completionHandler?(result.map(to: Status.self))
        }

        return self.request(target, callbackQueue: callbackQueue, completion: completion)
    }
}
