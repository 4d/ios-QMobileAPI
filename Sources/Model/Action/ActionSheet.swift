//
//  ActionSheet.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 09/04/2019.
//  Copyright © 2019 Eric Marchand. All rights reserved.
//

import Foundation

/// Represent a list of actions.
public struct ActionSheet {
    public let title: String?
    public let subtitle: String?
    public let dismissLabel: String?

    public let actions: [Action]

    public init(title: String? = nil,
                subtitle: String? = nil,
                dismissLabel: String? = nil,
                actions: [Action] = []) {
        self.title = title
        self.subtitle = subtitle
        self.dismissLabel = dismissLabel
        self.actions = actions
    }
}

// MARK: - Codable
extension ActionSheet: Codable {}
