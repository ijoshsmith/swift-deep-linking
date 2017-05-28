# Simple Deep Linking in Swift
A simple way to consume custom deep link URLs in a Swift app.

It creates a data object from values in a URL, which can be used to perform an action in your app.

# Highlights
* An intuitive API that helps you easily work with custom deep link URLs
* Supports extracting values from a URL's path, query string, and fragment
* It's all contained in just one small Swift file
* Written in Swift 3
* This repository includes a demo app and unit tests

# How to add it to your project
Add the file [DeepLinking.swift](/DeepLinking/DeepLinking.swift) to your Xcode project.

# Conceptual overview
Your app is passed a deep link URL, inspects the URL to determine what it represents, and then performs the appropriate action for that deep link. Not all URLs represent a deep link your app knows how to handle, but all deep links can be expressed as a URL. The API presented here  figures out which deep link a URL matches, and extracts data values from the URL so that your app can perform the appropriate action.

# Simple example
Suppose that the URL `my.url.scheme://show/photo?name=cat` can be interpreted by your app as a command to `show` the `photo` in an image file whose `name` is `cat`. 

Using the Deep Linking API in this repository, here's how to declare that your app supports this deep link…

```swift
/// Represents presenting an image to the user.
/// Example - my.url.scheme://show/photo?name=cat
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
```
This struct adopts the `DeepLink` protocol, which requires it to have a `static` property named `template` and an initializer whose sole parameter is `DeepLinkValues`.

* `template` - A typed description of a URL from which an instance of the deep link type can be created.
* `init(values:)` - An initializer that receives values extracted from a URL, already converted to the template-specified data types.

# A more complicated example
Here's another example, from the [unit tests](/DeepLinking/DeepLinkingTests/DeepLinkingTests.swift). 
```swift
// Examples:
// my.url.scheme://display/upgrade?mustAccept=true&username=Josh
// my.url.scheme://display/upgrade?mustAccept=false
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
```
Notice that the `DeepLinkTemplate` includes a `term` and a `string`. 
* `term` - Represents a hard-coded string that must appear in the URL path, at the specified location, for a URL to match this deep link type. 
* `string` - Represents a string variable that must appear in the URL path, at the specified location, for a URL to match this deep link type. The value of the string will be included in the `DeepLinkValues` object passed to the deep link's initializer.

Aside from terms and strings, a URL path variable can be of type `int`, `double`, or `bool`.

Similarly, a deep link can declare what query string parameters must/can appear in a matching URL. A query string parameter can be required or optional. If a required parameter is not found in a URL, then that URL cannot be used to create the template's associated deep link type. A query parameter can be of type `int`, `double`, `bool`, or `string`.

# Deep link recognition
The job of detecting which kind of deep link a URL matches is handled by `DeepLinkRecognizer`. Here is how  `DisplayMessageDeepLink` from the previous section can be detected and created.
```swift
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
```
When your `AppDelegate` receives a deep link URL, a `DeepLinkRecognizer` can be used to create the appropriate `DeepLink` object, if any of your `DeepLink` types can handle that URL. This code is from the demo app's [AppDelegate](/DeepLinking/DemoApp/AppDelegate.swift):
```swift
private func executeDeepLink(with url: URL) -> Bool {
    // Create a recognizer with this app's custom deep link types.
    let recognizer = DeepLinkRecognizer(deepLinkTypes: [
        SelectTabDeepLink.self,
        ShowPhotoDeepLink.self])
    
    // Try to create a deep link object based on the URL.
    guard let deepLink = recognizer.deepLink(matching: url) else {
        print("Unable to match URL: \(url.absoluteString)")
        return false
    }
    
    // Navigate to the view or content specified by the deep link.
    switch deepLink {
    case let link as SelectTabDeepLink: return selectTab(with: link)
    case let link as ShowPhotoDeepLink: return showPhoto(with: link)
    default: fatalError("Unsupported DeepLink: \(type(of: deepLink))")
    }
}
```
The implementation details of how an app responds to a particular deep link is arbitrary, but here's an example just to help solidify the idea of where this deep linking API fits into an app.
```swift
private func showPhoto(with deepLink: ShowPhotoDeepLink) -> Bool {
    guard let tabBarController = prepareTabBarController() else {
        return false
    }
    
    // Load an image from the bundle with the provided name.
    guard let image = UIImage(named: deepLink.imageName) else {
        print("There is no image named '\(deepLink.imageName)'")
        return false
    }
    
    // Navigate to the specified image.
    tabBarController.showPhoto(image: image, animated: false)
    return true
}
```
# Short but sweet
There are other deep linking libraries for Swift developers, some of which have much more functionality and flexibility. Based on my experience developing iOS and tvOS apps that need deep linking, this suits my needs. Sometimes less is more.
