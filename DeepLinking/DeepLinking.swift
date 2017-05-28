//
//  DeepLinking.swift
//  Created by Joshua Smith on 5/22/17.
//  Copyright (c) 2017 iJoshSmith. Licensed under the MIT License.
//

import Foundation

// MARK: - DeepLink
/// Adopted by a type whose values are matched and extracted from a URL.
public protocol DeepLink {
    /// Returns a template that describes how to match and extract values from a URL.
    static var template: DeepLinkTemplate { get }
    
    /// Initializes a new instance with values extracted from a URL.
    /// - Parameter values: Data values from a URL, whose keys are the names specified in a `DeepLinkTemplate`.
    init(values: DeepLinkValues)
}


// MARK: - DeepLinkValues
/// Data values extracted from a URL by a deep link template.
public struct DeepLinkValues {
    /// Values in the URL's path, whose keys are the names specified in a deep link template.
    public let path: [String: Any]
    
    /// Values in the URL's query string, whose keys are the names specified in a deep link template.
    public let query: [String: Any]
    
    /// The URL's fragment (i.e. text following a # symbol), if available.
    public let fragment: String?
    
    fileprivate init(path: [String: Any], query: [String: Any], fragment: String?) {
        self.path = path
        self.query = query
        self.fragment = fragment
    }
}


// MARK: - DeepLinkTemplate
/// Describes how to extract a deep link's values from a URL.
/// A template is considered to match a URL if all of its required values are found in the URL.
public struct DeepLinkTemplate {
    // MARK: - Public API
    public init() {
        self.init(pathParts: [], parameters: [])
    }
    
    /// A matching URL must include this constant string at the correct location in its path.
    public func term(_ symbol: String) -> DeepLinkTemplate {
        return appending(pathPart: .term(symbol: symbol))
    }
    
    /// A matching URL must include a string at the correct location in its path.
    /// - Parameter name: The key of this string in the `path` dictionary of `DeepLinkValues`.
    public func string(named name: String) -> DeepLinkTemplate {
        return appending(pathPart: .string(name: name))
    }
    
    /// A matching URL must include an integer at the correct location in its path.
    /// - Parameter name: The key of this integer in the `path` dictionary of `DeepLinkValues`.
    public func int(named name: String) -> DeepLinkTemplate {
        return appending(pathPart: .int(name: name))
    }
    
    /// A matching URL must include a double at the correct location in its path.
    /// - Parameter name: The key of this double in the `path` dictionary of `DeepLinkValues`.
    public func double(named name: String) -> DeepLinkTemplate {
        return appending(pathPart: .double(name: name))
    }
    
    /// A matching URL must include a boolean at the correct location in its path.
    /// - Parameter name: The key of this boolean in the `path` dictionary of `DeepLinkValues`.
    public func bool(named name: String) -> DeepLinkTemplate {
        return appending(pathPart: .bool(name: name))
    }
    
    /// An unordered set of query string parameters.
    /// - Parameter queryStringParameters: A set of parameters that may be required or optional.
    public func queryStringParameters(_ queryStringParameters: Set<QueryStringParameter>) -> DeepLinkTemplate {
        return DeepLinkTemplate(pathParts: pathParts, parameters: queryStringParameters)
    }
    
    /// A named value in a URL's query string.
    public enum QueryStringParameter {
        case requiredInt(named: String),    optionalInt(named: String)
        case requiredBool(named: String),   optionalBool(named: String)
        case requiredDouble(named: String), optionalDouble(named: String)
        case requiredString(named: String), optionalString(named: String)
    }
    
    // MARK: - Private creation methods
    private init(pathParts: [PathPart], parameters: Set<QueryStringParameter>) {
        self.pathParts = pathParts
        self.parameters = parameters
    }
    
    private func appending(pathPart: PathPart) -> DeepLinkTemplate {
        return DeepLinkTemplate(pathParts: pathParts + [pathPart], parameters: parameters)
    }
    
    // MARK: - State
    fileprivate enum PathPart {
        case int(name: String)
        case bool(name: String)
        case string(name: String)
        case double(name: String)
        case term(symbol: String)
    }
    fileprivate let pathParts: [PathPart]
    fileprivate let parameters: Set<QueryStringParameter>
}


// MARK: - DeepLinkRecognizer
/// Creates a deep link object that matches a URL.
public struct DeepLinkRecognizer {
    private let deepLinkTypes: [DeepLink.Type]
    
    /// Initializes a new recognizer with a list of available deep link types.
    /// - Parameter deepLinkTypes: An array of deep link types which can be created based on a URL.
    /// The template of each type is evaluated in the order the types appear in this array.
    public init(deepLinkTypes: [DeepLink.Type]) {
        self.deepLinkTypes = deepLinkTypes
    }
    
    /// Returns a new `DeepLink` object whose template matches the specified URL, if possible.
    public func deepLink(matching url: URL) -> DeepLink? {
        for deepLinkType in deepLinkTypes {
            if let values = DeepLinkRecognizer.extractValues(in: deepLinkType.template, from: url) {
                return deepLinkType.init(values: values)
            }
        }
        return nil
    }
    
    // MARK: - URL value extraction
    private static func extractValues(in template: DeepLinkTemplate, from url: URL) -> DeepLinkValues? {
        guard let pathValues = extractPathValues(in: template, from: url) else { return nil }
        guard let queryValues = extractQueryValues(in: template, from: url) else { return nil }
        return DeepLinkValues(path: pathValues, query: queryValues, fragment: url.fragment)
    }
    
    private static func extractPathValues(in template: DeepLinkTemplate, from url: URL) -> [String: Any]? {
        let allComponents = url.host.map { [$0] + url.pathComponents } ?? url.pathComponents
        let components = allComponents
            .filter { $0 != "/" }
            .map    { $0.removingPercentEncoding ?? "" }
        guard components.count == template.pathParts.count else { return nil }
        var values = [String: Any]()
        for (pathPart, component) in zip(template.pathParts, components) {
            switch pathPart {
            case let .int(name):
                guard let value = Int(component) else { return nil }
                values[name] = value
                
            case let .bool(name):
                guard let value = Bool(component) else { return nil }
                values[name] = value
                
            case let .double(name):
                guard let value = Double(component) else { return nil }
                values[name] = value
                
            case let .string(name):
                values[name] = component
                
            case let .term(symbol):
                guard symbol == component else { return nil }
            }
        }
        return values
    }
    
    private static func extractQueryValues(in template: DeepLinkTemplate, from url: URL) -> [String: Any]? {
        if template.parameters.isEmpty {
            return url.query == nil ? [:] : nil
        }
        
        let requiredParameters = template.parameters.filter { $0.isRequired }
        let optionalParameters = template.parameters.subtracting(requiredParameters)
        
        guard let query = url.query else {
            return requiredParameters.isEmpty ? [:] : nil
        }
        
        let queryMap = createMap(of: query)
        var values = [String: Any]()
        
        for parameter in requiredParameters {
            guard let value = value(of: parameter, in: queryMap) else { return nil }
            values[parameter.name] = value
        }
        
        for parameter in optionalParameters {
            if let value = value(of: parameter, in: queryMap) {
                values[parameter.name] = value
            }
        }
        
        return values
    }
    
    private typealias QueryMap = [String: String]
    private static func createMap(of query: String) -> QueryMap {
        // Transforms "a=b&c=d" to [(a, b), (c, d)]
        let keyValuePairs = query
            .components(separatedBy: "&")
            .map    { $0.components(separatedBy: "=") }
            .filter { $0.count == 2 }
            .map    { ($0[0], $0[1]) }
        
        var queryMap = QueryMap()
        for (key, value) in keyValuePairs {
            queryMap[key] = value
        }
        return queryMap
    }
    
    private static func value(of parameter: DeepLinkTemplate.QueryStringParameter, in queryMap: QueryMap) -> Any? {
        guard let value: String = queryMap[parameter.name] else { return nil }
        switch parameter.type {
        case .int:    return Int(value)
        case .bool:   return Bool(value)
        case .double: return Double(value)
        case .string: return value.removingPercentEncoding ?? ""
        }
    }
}


// MARK: - QueryStringParameter extension
extension DeepLinkTemplate.QueryStringParameter: Hashable, Equatable {
    public var hashValue: Int {
        return name.hashValue
    }
    
    public static func ==(lhs: DeepLinkTemplate.QueryStringParameter, rhs: DeepLinkTemplate.QueryStringParameter) -> Bool {
        return lhs.name == rhs.name
    }
    
    fileprivate var name: String {
        switch self {
        case let .requiredInt(name):    return name
        case let .requiredBool(name):   return name
        case let .requiredDouble(name): return name
        case let .requiredString(name): return name
        case let .optionalInt(name):    return name
        case let .optionalBool(name):   return name
        case let .optionalDouble(name): return name
        case let .optionalString(name): return name
        }
    }
    
    fileprivate enum ParameterType { case string, int, double, bool }
    fileprivate var type: ParameterType {
        switch self {
        case .requiredInt,    .optionalInt:    return .int
        case .requiredBool,   .optionalBool:   return .bool
        case .requiredDouble, .optionalDouble: return .double
        case .requiredString, .optionalString: return .string
        }
    }
    
    fileprivate var isRequired: Bool {
        switch self {
        case .requiredInt, .requiredBool, .requiredDouble, .requiredString: return true
        case .optionalInt, .optionalBool, .optionalDouble, .optionalString: return false
        }
    }
}
