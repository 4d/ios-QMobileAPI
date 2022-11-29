//
//  RestErrors.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 31/08/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation

public struct RestErrors: Swift.Error, JSONDecodable, ErrorWithCause {
    public var statusText: String?
    public let errors: [RestError]

    public init?(json: JSON) {
        statusText = json["statusText"].string
        if let array = json["__ERROR"].array ?? json["errors"].array {
            errors = array.compactMap { RestError(json: $0) }
        } else if let string = json["__ERROR"].string {
            errors = [RestError(code: .login_failed,
                                message: string)]
        } else if !statusText.isEmpty {
            errors = []
        } else {
            return nil
        }
    }

    // Return true if one error match the code
    public func match(_ code: RestErrorCode) -> Bool {
        for error in errors {
            if error.match(code) {
                return true
            }
        }
        return false
    }

    public var error: Swift.Error? {
        return errors.first
    }
}

extension RestErrors: Equatable {}
extension RestErrors: Codable {}

extension RestErrors: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary["errors"] = self.errors.map { $0.dictionary }
        return dictionary
    }
}

public struct RestError: Swift.Error, JSONDecodable {
    public let message: String
    public let componentSignature: String
    public let errCode: Int

    public init?(json: JSON) {
        message = json["message"].stringValue
        componentSignature = json["componentSignature"].string ?? json["parameter"].stringValue
        errCode = json["errCode"].int ?? json["code"].intValue
    }

    public init(code: RestErrorCode, message: String = "", componentSignature: String = "") {
        self.message = message
        self.componentSignature = componentSignature
        self.errCode = code.rawValue
    }
}

extension RestError {
    /// Return the rest error error code.
    public var code: RestErrorCode? {
        return RestErrorCode(rawValue: self.errCode)
    }

    /// Check if matching the rest error code.
    public func match(_ code: RestErrorCode) -> Bool {
        return code.rawValue == self.errCode
    }
}

extension RestError: Equatable {}

extension RestError: Codable {}

extension RestError: DictionaryConvertible {
    public var dictionary: DictionaryConvertible.Dico {
        var dictionary: DictionaryConvertible.Dico = [:]
        dictionary["message"] = self.message
        dictionary["componentSignature"] = self.componentSignature
        dictionary["errCode"] = self.errCode
        return dictionary
    }
}

extension RestError: LocalizedError {
    public var errorDescription: String? {
        if message.isEmpty {
            return self.code?.localizedMessage
        }
        return message
    }
}

public enum RestErrorCode: Int {
    // web
    case entity_not_found = 1_800
    case unsupported_format = 1_801
    case dataset_not_found = 1_802
    case dataset_not_matching_entitymodel = 1_803
    case cannot_build_list_of_attribute = 1_804
    case cannot_build_list_of_attribute_for_expand = 1_805
    case url_is_malformed = 1_806
    case ampersand_instead_of_questionmark = 1_807
    case expecting_closing_single_quote = 1_808
    case expecting_closing_double_quote = 1_809
    case wrong_list_of_attribute_to_order_by = 1_810
    case unknown_rest_query_keyword = 1_811
    case unknown_rest_method = 1_812
    case method_not_applicable = 1_813
    case uag_db_does_not_exist = 1_814
    case subentityset_cannot_be_applied_here = 1_815
    case empty_attribute_list = 1_816
    case compute_action_does_not_exist = 1_817
    case wrong_logic_operator = 1_818
    case missing_other_collection_ref = 1_819
    case wrong_other_collection_ref = 1_820
    case wrong_transaction_command = 1_821
    case login_failed = 1_822
    case max_number_of_sessions_reached = 1_823
    case unknown_picture_mime_type = 1_824
    case missing_picture_ref = 1_825
    case missing_blob_ref = 1_826
    case method_name_is_unknown = 1_827
    case limited_alterations = 1_828
    case method_called_on_a_HTTP_GET = 1_829

    // db
    case wrong_comp_operator = 1_112
    case invalid_query = 1_162
    case cannot_complete_query = 1_200
    case cannot_analyze_query = 1_201
    case cannot_complete_complexquery = 1_203
    case cannot_analyze_complexquery = 1_204
    case query_placeholder_is_missing_or_null = 1_279
    case query_placeholder_wrongtype = 1_280

    // db entity model
    case entity_attribute_not_found = 1_500

    // mobile app
    case mobile_malformed_json = 1_901
    case mobile_function_not_defined = 1_902
    case mobile_error_4dfunction = 1_903
    case mobile_bad_request = 1_904
    case mobile_error_main_thread = 1_905
    case mobile_forbidden = 1_906
    case mobile_unauthorized = 1_907
    case mobile_max_number_sessions_reached = 1_908
    case mobile_malformed_url = 1_909
    case mobile_method_not_applicable = 1_910
    case mobile_method_called_with_get = 1_911
    case mobile_success_false  = 1_912
    case mobile_no_licenses = 1_913

    public var message: String {
        return String(describing: self)
    }

    public var localizedMessage: String {
        return "api.rest.\(message)".localized
    }
}
