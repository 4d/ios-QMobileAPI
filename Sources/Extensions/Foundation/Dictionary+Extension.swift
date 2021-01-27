//
//  Dictionary+Query.swift
//  QAPI
//
//  Created by Eric Marchand on 08/03/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

func dict<K, V>(_ tuples: [(K, V)]) -> [K: V] {
    var dict: [K: V] = [K: V]()
    tuples.forEach {dict[$0.0] = $0.1}
    return dict
}
