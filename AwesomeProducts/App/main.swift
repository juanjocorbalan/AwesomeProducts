import UIKit

let appDelegateClass: AnyClass = NSClassFromString("AwesomeProductsTests.TestingAppDelegate") ?? AppDelegate.self
UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(appDelegateClass))
