//
//  APIManager+Load.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 13/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya
import Result

extension APIManager {
    public typealias CompletionStatusHandler = ((Result<Status, APIError>) -> Void)
    /// Get server status
    public func status(callbackQueue: DispatchQueue? = nil, progress: ProgressHandler? = nil, completionHandler: @escaping CompletionStatusHandler) -> Cancellable {
        return self.request(base.status, callbackQueue: callbackQueue, progress: progress, completion: completionHandler)
    }

    public typealias CompletionInfoHandler = ((Result<Info, APIError>) -> Void)
    /// Get server info
    public func info(callbackQueue: DispatchQueue? = nil, progress: ProgressHandler? = nil, completionHandler: @escaping CompletionInfoHandler) -> Cancellable {
        return self.request(base.info, callbackQueue: callbackQueue, progress: progress, completion: completionHandler)
    }

    public typealias CompletionSessionInfoHandler = ((Result<[SessionInfo], APIError>) -> Void)
    /// Get server session info
    public func sessionInfo(callbackQueue: DispatchQueue? = nil, progress: ProgressHandler? = nil, completionHandler: @escaping CompletionSessionInfoHandler) -> Cancellable {
        return self.request(base.info.sessionInfo, callbackQueue: callbackQueue, progress: progress, completion: completionHandler)
    }

    public typealias CompletionProgressInfoHandler = ((Result<[ProgressInfo], APIError>) -> Void)
    /// Get server Progress Info
    public func progressInfo(callbackQueue: DispatchQueue? = nil, progress: ProgressHandler? = nil, completionHandler: @escaping CompletionProgressInfoHandler) -> Cancellable {
        return self.request(base.info.progressInfo, callbackQueue: callbackQueue, progress: progress, completion: completionHandler)
    }

    public typealias CompletionCacheInfoHandler = ((Result<[CacheInfo], APIError>) -> Void)
    /// Get server Cache Info
    public func cacheInfo(callbackQueue: DispatchQueue? = nil, progress: ProgressHandler? = nil, completionHandler: @escaping CompletionCacheInfoHandler) -> Cancellable {
        return self.request(base.info.cacheInfo, callbackQueue: callbackQueue, progress: progress, completion: completionHandler)
    }

    public typealias CompletionEntitySetInfoHandler = ((Result<EntitySetInfo, APIError>) -> Void)
    /// Get server Entity Set
    public func entitySetInfo(callbackQueue: DispatchQueue? = nil, progress: ProgressHandler? = nil, completionHandler: @escaping CompletionEntitySetInfoHandler) -> Cancellable {
        return self.request(base.info.entitySetInfo, callbackQueue: callbackQueue, progress: progress, completion: completionHandler)
    }

    public typealias CompletionCatalogHandler = ((Result<[Catalog], APIError>) -> Void)
    /// Get the catalog, list description of URI for tables and records
    public func catalog(callbackQueue: DispatchQueue? = nil, progress: ProgressHandler? = nil, completionHandler: @escaping CompletionCatalogHandler) -> Cancellable {
        return self.request(base.catalog, callbackQueue: callbackQueue, progress: progress, completion: completionHandler)
    }

    public typealias CompletionTablesHandler = ((Result<[Table], APIError>) -> Void)
    /// Get all tables
    public func tables(callbackQueue: DispatchQueue? = nil, progress: ProgressHandler? = nil, completionHandler: @escaping CompletionTablesHandler) -> Cancellable {
        return self.request(base.catalog.all, callbackQueue: callbackQueue, progress: progress, completion: completionHandler)
    }

    public typealias CompletionTableHandler = ((Result<Table, APIError>) -> Void)
    /// Get one table by name
    /// @param table     the wanted table name
    public func table(name: String, callbackQueue: DispatchQueue? = nil, progress: ProgressHandler? = nil, completionHandler: @escaping CompletionTableHandler) -> Cancellable {
        return self.request(base.catalog.table(name), callbackQueue: callbackQueue, progress: progress, completion: completionHandler)
    }

    public typealias CompletionRecordJSONHandler = ((Result<RecordJSON, APIError>) -> Void)
    /// Get one record into simple structures
    /// @param table   the table
    /// @param key   the primary key of wanted record
    /// @param attribute   get only this attributes
    public func recordJSON(
        table: Table,
        key: CustomStringConvertible,
        attributes: [String] = [],
        callbackQueue: DispatchQueue? = nil,
        progress: ProgressHandler? = nil,
        completionHandler: @escaping CompletionRecordJSONHandler) -> Cancellable {
        let target = base.record(from: table.name, key: key, attributes: attributes)
        return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: completionHandler)
    }

    public typealias CompletionPageHandler = ((Result<Page, APIError>) -> Void)
    /// Get the records into simple structures.
    /// You must get information from page to configure next request.
    /// @param table   the table
    /// @param attribute   get only this attributes
    /// @param recursive   receive all page until last one (default: false)
    /// @param configure   closure to configure the request
    public func recordPage(
        table: Table,
        attributes: [String] = [],
        setID: EntitySetIdConvertible? = nil,
        recursive: Bool = false,
        configure: ConfigureRecordsRequest? = nil,
        callbackQueue: DispatchQueue? = nil,
        progress: ProgressHandler? = nil,
        completionHandler: @escaping CompletionPageHandler) -> Cancellable {
        return recordPage(tableName: table.name, attributes: attributes, setID: setID, recursive: recursive, configure: configure, callbackQueue: callbackQueue, progress: progress, completionHandler: completionHandler)
    }
    /// Get the records into simple structures. Only one page is loaded.
    /// You must get information from page to configure next request.
    /// @param tableName   the table name
    /// @param attribute   get only this attributes
    /// @param recursive   receive all page until last one (default: false)
    /// @param configure   closure to configure the request
    public func recordPage(
        tableName: String,
        attributes: [String] = [],
        setID: EntitySetIdConvertible? = nil,
        recursive: Bool = false,
        configure: ConfigureRecordsRequest? = nil,
        callbackQueue: DispatchQueue? = nil,
        progress: ProgressHandler? = nil,
        completionHandler: @escaping CompletionPageHandler) -> Cancellable {
        let cancellable = CancellableComposite()

        var progressHandler: ProgressHandler?
        if recursive {
            progressHandler = progress      // XXX change it to split
        } else {
            progressHandler = progress
        }

        let completion: CompletionPageHandler = { result in
            if case .success(let page) = result {
                if recursive && !cancellable.isCancelled {
                    if !page.info.isLast { // XXX maybe add a custom stop condition instead of isLast
                        let nextConfigure: ConfigureRecordsRequest? = { toConfigure in
                            configure?(toConfigure)
                            toConfigure.skip(page.info.next)
                        }
                        let newCancellable = self.recordPage(tableName: tableName, attributes: attributes,
                                                           setID: setID, configure: nextConfigure,
                                                           callbackQueue: callbackQueue, progress: progress, completionHandler: completionHandler)
                        cancellable.append(newCancellable)
                    }
                }
            }
            completionHandler(result)
        }

        let target = base.records(from: tableName, attributes: attributes)
        if let setID = setID {
            let targetSet = target.set(setID)
            configure?(targetSet)
            let requestCancellable = self.request(targetSet, callbackQueue: callbackQueue, progress: progressHandler, completion: completion)
            cancellable.append(requestCancellable)
        } else {
            configure?(target)
            let requestCancellable = self.request(target, callbackQueue: callbackQueue, progress: progressHandler, completion: completion)
            cancellable.append(requestCancellable)
        }
        return cancellable
    }

    /// Get the deleted records information into simple structures. Only one page is loaded.
    /// You must get information from page to configure next request.
    /// @param configure   closure to configure the request
    public func deletedRecordPage(
        configure: ConfigureRecordsRequest? = nil,
        callbackQueue: DispatchQueue? = nil,
        progress: ProgressHandler? = nil,
        completionHandler: @escaping CompletionPageHandler) -> Cancellable {
        let target = base.deletedRecords()
        configure?(target)
        return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: completionHandler)
    }

    public typealias CompletionComputeHandler = ((Result<Compute, APIError>) -> Void)
    /// Compute an operation on specific attribute of one table.
    /// @param table   the table
    /// @param attribute   the attribute
    /// @param operation   the operation to execute
    public func compute(table: String, attribute: String,
                        operation: ComputeOperation,
                        callbackQueue: DispatchQueue? = nil, progress: ProgressHandler? = nil, completionHandler: @escaping CompletionComputeHandler) -> Cancellable {
        if operation == .all {
            return self.request(base.records(from: table).compute(operation, for: attribute), completion: completionHandler)
        }
        let completion: Completion = { result in
            switch result {
            case .success(let response):
                do {
                    let result = try response.mapString()
                    let compute = Compute(attribute: attribute, operation: operation, result: result)
                    completionHandler(.success(compute))
                } catch {
                    completionHandler(.failure(.stringDecodingFailed(error)))
                }

            case .failure(let error):
                completionHandler(.failure(APIError.error(from: error)))
            }
        }
        let target: ComputeTarget = base.records(from: table).compute(operation, for: attribute)
        return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }

    public typealias CompletionUploadResultHandler = ((Result<UploadResult, APIError>) -> Void)

    // MARK: - Upload

    /// Upload data to the server. Could be an image or a blob.
    /// An id will be returned to use to associate this upload to record field or action parameters.
    public func upload(data: Data, image: Bool = false, mimeType: String?, completionHandler: @escaping CompletionUploadResultHandler) -> Cancellable {
        let target = base.upload(data: data, image: image, mimeType: mimeType)
        return self.request(target, completion: completionHandler)
    }

    /// Upload file url data to server.
    /// An id will be returned to use to associate this upload to record field or action parameters.
    public func upload(url: URL, callbackQueue: DispatchQueue? = nil, progress: ProgressHandler? = nil, completionHandler: @escaping CompletionUploadResultHandler) -> Cancellable {
        let target = base.upload(url: url)
        return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: completionHandler)
    }
    /*
     func load<T: TargetType, R: JSONable>(target: T, completionHandler: @escaping ((Result<R, APIError>) -> Void)) -> Cancellable {
     return self.request(target) { result in
     completionHandler(result.map(to: R.self))
     }
     }
     
     func loadArray<T: TargetType, R: JSONable>(target: T, completionHandler: @escaping ((Result<[R], APIError>) -> Void)) -> Cancellable {
     return self.request(target) { result in
     completionHandler(result.map(to: [R.self]))
     }
     }
     */
}
