//
//  DeepLinkingTests.swift
//  DeepLinkingTests
//
//  Created by Joshua Smith on 5/18/17.
//  Copyright © 2017 iJoshSmith. All rights reserved.
//

import XCTest
@testable import DeepLinking

class DeepLinkingTests: XCTestCase {
    
    // MARK: - Path tests
    func test_path_termA_matches() {
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [ADeepLink.self])
        if let result = recognizer.deepLink(matching: URL(string: "test://a")!) {
            XCTAssertTrue(result is ADeepLink)
        }
        else {
            XCTFail()
        }
    }
    
    func test_path_termA_doesNotMatch() {
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [ADeepLink.self])
        let result = recognizer.deepLink(matching: URL(string: "test://b")!)
        XCTAssertNil(result)
    }
    
    func test_path_termsAB_matches() {
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [ABDeepLink.self])
        if let result = recognizer.deepLink(matching: URL(string: "test://a/b/")!) {
            XCTAssertTrue(result is ABDeepLink)
        }
        else {
            XCTFail()
        }
    }
    
    func test_path_termsAB_doesNotMatch() {
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [ABDeepLink.self])
        let result = recognizer.deepLink(matching: URL(string: "test://b/a/")!)
        XCTAssertNil(result)
    }
    
    func test_path_int_matches() {
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [IntDeepLink.self])
        if let result = recognizer.deepLink(matching: URL(string: "test://42")!) as? IntDeepLink {
            XCTAssertEqual(result.number, 42)
        }
        else {
            XCTFail()
        }
    }
    
    func test_path_int_doesNotMatch() {
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [IntDeepLink.self])
        let result = recognizer.deepLink(matching: URL(string: "test://thisIsNotAnInt/")!)
        XCTAssertNil(result)
    }
    
    func test_path_bool_matches() {
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [BoolDeepLink.self])
        if let result = recognizer.deepLink(matching: URL(string: "test://true")!) as? BoolDeepLink {
            XCTAssertEqual(result.boolean, true)
        }
        else {
            XCTFail()
        }
    }
    
    func test_path_bool_doesNotMatch() {
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [BoolDeepLink.self])
        let result = recognizer.deepLink(matching: URL(string: "test://thisIsNotABool/")!)
        XCTAssertNil(result)
    }
    
    func test_path_double_matches() {
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [DoubleDeepLink.self])
        if let result = recognizer.deepLink(matching: URL(string: "test://3.14")!) as? DoubleDeepLink {
            XCTAssertEqual(result.number, 3.14)
        }
        else {
            XCTFail()
        }
    }
    
    func test_path_double_doesNotMatch() {
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [DoubleDeepLink.self])
        let result = recognizer.deepLink(matching: URL(string: "test://thisIsNotADouble/")!)
        XCTAssertNil(result)
    }
    
    func test_path_string_matches_text() {
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [StringDeepLink.self])
        if let result = recognizer.deepLink(matching: URL(string: "test://hello")!) as? StringDeepLink {
            XCTAssertEqual(result.text, "hello")
        }
        else {
            XCTFail()
        }
    }
    
    func test_path_string_matches_number() {
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [StringDeepLink.self])
        if let result = recognizer.deepLink(matching: URL(string: "test://123")!) as? StringDeepLink {
            XCTAssertEqual(result.text, "123")
        }
        else {
            XCTFail()
        }
    }
    
    func test_path_string_doesNotMatch_missing_value() {
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [StringDeepLink.self])
        let result = recognizer.deepLink(matching: URL(string: "test://?param=foo")!)
        XCTAssertNil(result)
    }
    
    func test_path_stringAndInt_matches() {
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [StringAndIntDeepLink.self])
        if let result = recognizer.deepLink(matching: URL(string: "test://foo/42")!) as? StringAndIntDeepLink {
            XCTAssertEqual(result.text, "foo")
            XCTAssertEqual(result.number, 42)
        }
        else {
            XCTFail()
        }
    }
    
    func test_path_stringAndInt_doesNotMatch() {
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [StringAndIntDeepLink.self])
        let result = recognizer.deepLink(matching: URL(string: "test://42/foo")!)
        XCTAssertNil(result)
    }
    
    // MARK: - Query tests
    func test_query_requiredInt_matches() {
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [QueryRequiredIntDeepLink.self])
        if let result = recognizer.deepLink(matching: URL(string: "test://?number=42")!) as? QueryRequiredIntDeepLink {
            XCTAssertEqual(result.number, 42)
        }
        else {
            XCTFail()
        }
    }
    
    func test_query_requiredInt_doesNotMatchDouble() {
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [QueryRequiredIntDeepLink.self])
        let result = recognizer.deepLink(matching: URL(string: "test://?notAnInt=3.14")!)
        XCTAssertNil(result)
    }
    
    func test_query_optionalInt_matches() {
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [QueryOptionalIntDeepLink.self])
        if let result = recognizer.deepLink(matching: URL(string: "test://?number=42")!) as? QueryOptionalIntDeepLink {
            XCTAssertEqual(result.number, 42)
        }
        else {
            XCTFail()
        }
    }
    
    func test_query_optionalInt_parameterNotIncluded() {
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [QueryOptionalIntDeepLink.self])
        if let result = recognizer.deepLink(matching: URL(string: "test://?someOtherParameter=hello")!) as? QueryOptionalIntDeepLink {
            XCTAssertNil(result.number)
        }
        else {
            XCTFail()
        }
    }
    
    // MARK: - Path and Query test
    struct DisplayMessageDeepLink: DeepLink {
        static let template = DeepLinkTemplate()
            .term("display")
            .string(named: "messageType")
            .queryStringParameters([
                .optionalString(named: "username"),
                .requiredBool(named: "mustAccept")
                ])
        
        init(values: DeepLinkValues) {
            self.messageType = values.path["messageType"] as! String
            self.mustAccept = values.query["mustAccept"] as! Bool
            self.username = values.query["username"] as? String
        }
        
        let messageType: String
        let mustAccept: Bool
        let username: String?
    }
    
    func test_display_message_deep_link() {
        // A deep link recognizer that knows about the custom deep link type.
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [DisplayMessageDeepLink.self])
        
        // A URL which conforms to the "display message" deep link schema.
        let url = URL(string: "test://display/upgrade?mustAccept=true&username=Billy%20Bob")!
        
        // Verify that the recognizer creates a properly configured deep link.
        if let deepLink = recognizer.deepLink(matching: url) as? DisplayMessageDeepLink {
            XCTAssertEqual(deepLink.messageType, "upgrade")
            XCTAssertEqual(deepLink.mustAccept, true)
            XCTAssertEqual(deepLink.username, "Billy Bob")
        }
        else {
            XCTFail()
        }
    }
    
    // MARK: - Searches through deep link types
    func test_searches_through_deep_link_types() {
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [IntDeepLink.self,
                                                            BoolDeepLink.self,
                                                            DoubleDeepLink.self,
                                                            StringDeepLink.self])
        let url = URL(string: "test://3.14")!
        if let deepLink = recognizer.deepLink(matching: url) as? DoubleDeepLink {
            XCTAssertEqual(deepLink.number, 3.14)
        }
        else {
            XCTFail()
        }
    }
}


// MARK: - Deep Links
struct ADeepLink: DeepLink {
    public static let template = DeepLinkTemplate().term("a")
    public init(values: DeepLinkValues) {}
}

struct ABDeepLink: DeepLink {
    public static let template = DeepLinkTemplate().term("a").term("b")
    public init(values: DeepLinkValues) {}
}

struct IntDeepLink: DeepLink {
    public static let template = DeepLinkTemplate().int(named: "number")
    public init(values: DeepLinkValues) {
        self.number = values.path["number"] as! Int
    }
    let number: Int
}

struct BoolDeepLink: DeepLink {
    public static let template = DeepLinkTemplate().bool(named: "boolean")
    public init(values: DeepLinkValues) {
        self.boolean = values.path["boolean"] as! Bool
    }
    let boolean: Bool
}

struct DoubleDeepLink: DeepLink {
    public static let template = DeepLinkTemplate().double(named: "number")
    public init(values: DeepLinkValues) {
        self.number = values.path["number"] as! Double
    }
    let number: Double
}

struct StringDeepLink: DeepLink {
    public static let template = DeepLinkTemplate().string(named: "text")
    public init(values: DeepLinkValues) {
        self.text = values.path["text"] as! String
    }
    let text: String
}

struct StringAndIntDeepLink: DeepLink {
    public static let template = DeepLinkTemplate().string(named: "text").int(named: "number")
    public init(values: DeepLinkValues) {
        self.text = values.path["text"] as! String
        self.number = values.path["number"] as! Int
    }
    let text: String
    let number: Int
}

struct QueryRequiredIntDeepLink: DeepLink {
    public static let template = DeepLinkTemplate().queryStringParameters([.requiredInt(named: "number")])
    public init(values: DeepLinkValues) {
        self.number = values.query["number"] as! Int
    }
    let number: Int
}

struct QueryOptionalIntDeepLink: DeepLink {
    public static let template = DeepLinkTemplate().queryStringParameters([.optionalInt(named: "number")])
    public init(values: DeepLinkValues) {
        self.number = values.query["number"] as? Int
    }
    let number: Int?
}
