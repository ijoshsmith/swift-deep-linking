//
//  DeepLinks.swift
//  DeepLinking
//
//  Created by Joshua Smith on 5/18/17.
//  Copyright © 2017 iJoshSmith. All rights reserved.
//


/// Represents selecting a tab in the tab bar controller.
/// Example - demoapp://select/tab/1
struct SelectTabDeepLink: DeepLink {
    static let template = DeepLinkTemplate()
        .term("select")
        .term("tab")
        .int(named: "index")
    
    init(values: DeepLinkValues) {
        tabIndex = values.path["index"] as! Int
    }
    
    let tabIndex: Int
}


/// Represents presenting an image to the user.
/// Example - demoapp://show/photo?name=cat
struct ShowPhotoDeepLink: DeepLink {
    static let template = DeepLinkTemplate()
        .term("show")
        .term("photo")
        .queryStringParameters([
            .requiredString(named: "name")
            ])
    
    init(values: DeepLinkValues) {
        imageName = values.query["name"] as! String
    }
    
    let imageName: String
}
