import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        AlertManager.sharedManager.notifier?.background = true
    }

    func applicationDidBecomeActive(application: UIApplication) {
        AlertManager.sharedManager.notifier?.background = false
        AlertManager.sharedManager.notifier?.notifyAlertsTriggered(AlertManager.sharedManager.triggeredAlerts)
    }
}

