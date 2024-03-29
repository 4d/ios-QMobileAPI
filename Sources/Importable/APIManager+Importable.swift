//
//  APIManager+Importable.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 09/06/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Moya

extension APIManager {
    /// Get records using specific object builder.
    /// This avoid passing by an intermediate object RecordObject which contains only JSON data.
    public func records<B: ImportableBuilder>(
        table: Table,
        attributes: [String: Any] = [:],
        setID: String? = nil,
        recursive: Bool = true,
        configure: ((RecordsRequest) -> Void)? = nil,
        initializer: B,
        queue: DispatchQueue? = nil,
        progress: ProgressHandler? = nil,
        completionHandler: @escaping ((Result<([B.Importable], PageInfo), APIError>) -> Void)) -> Cancellable {
        let cancellable = CancellableComposite()

        let completion: Moya.Completion = { [unowned self] result in
            switch result {
            case .success(let response):
                do {
                    let jsonObject = try response.mapJSON()
                    let json = JSON(jsonObject)

                    guard let page = PageInfo(json: json) else {
                        completionHandler(.failure(.jsonMappingFailed(json, PageInfo.self)))
                        return
                    }
                    do {
                        let records: [B.Importable] = try initializer.parseArray(json: json, using: .default)

                        if recursive && !page.isLast && !cancellable.isCancelled {
                            let nextConfigure: ((RecordsRequest) -> Void)? = { toConfigure in
                                configure?(toConfigure)
                                toConfigure.skip(page.next)
                            }
                            let newCancellable = self.records(table: table, attributes: attributes,
                                                                  setID: setID, configure: nextConfigure,
                                                                  initializer: initializer, queue: queue,
                                                                  progress: progress, completionHandler: completionHandler)
                            cancellable.append(newCancellable)
                        }
                        completionHandler(.success((records, page)))
                    } catch let error as ImportableParser.Error {
                        completionHandler(.failure(.recordsDecodingFailed(json, error)))
                    }
                } catch {
                    completionHandler(.failure(.jsonDecodingFailed(error)))
                }

            case .failure(let error):
                completionHandler(.failure(.moya(error)))
            }
        }

        let target = base.records(from: table.name, attributes: attributes)
        if let setID = setID {
            let targetSet = target.set(setID)
            configure?(targetSet)
            let requestCancellable = self.request(targetSet, queue: queue, progress: progress, completion: completion)
            cancellable.append(requestCancellable)
        } else {
            configure?(target)
            let requestCancellable = self.request(target, queue: queue, progress: progress, completion: completion)
            cancellable.append(requestCancellable)
        }
        return cancellable
    }

    public func loadRecord<B: ImportableBuilder>(
        table: Table,
        key: CustomStringConvertible,
        attributes: [String: Any] = [:],
        initializer: B,
        queue: DispatchQueue? = nil,
        configure: ((RecordsTargetType) -> Void)? = nil,
        progress: ProgressHandler? = nil,
        completionHandler: @escaping ((Result<B.Importable, APIError>) -> Void)) -> Cancellable {

            let target = base.records(from: table.name, attributes: attributes)
            configure?(target)
            if let string = key as? String, string.contains(" ") {
                target.appendToFilter("\(table.keys.first?.key ?? "")='\(key)'")
            } else {
                target.appendToFilter("\(table.keys.first?.key ?? "")=\(key)")
            }

            let completion: Moya.Completion = { result in
                switch result {
                case .success(let response):
                    do {
                        let jsonObject = try response.mapJSON()
                        let json = JSON(jsonObject)
                        do {
                            let records = try table.parser.parseArray(json: json, using: .default, with: initializer)
                            if let record = records.first {
                                completionHandler(.success(record))
                            } else {
                                completionHandler(.failure(.jsonMappingFailed(json, B.Importable.self)))
                            }
                        } catch let error as ImportableParser.Error {
                            completionHandler(.failure(.recordsDecodingFailed(json, error)))
                        }
                    } catch {
                        completionHandler(.failure(.jsonDecodingFailed(error)))
                    }

                case .failure(let error):
                    completionHandler(.failure(.moya(error)))
                }
            }

            return self.request(target, queue: queue, progress: progress, completion: completion)
        }
}
