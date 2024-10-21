import UIKit

UIApplicationMain(CommandLine.argc,
                  CommandLine.unsafeArgv,
                  nil,
                  NSClassFromString("XCTestCase") != nil ? nil : NSStringFromClass(AppDelegate.self))
