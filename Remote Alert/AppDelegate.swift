import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        AlertManager.sharedManager.notifier?.background = true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AlertManager.sharedManager.notifier?.background = false
        AlertManager.sharedManager.notifier?.notifyAlertsTriggered(AlertManager.sharedManager.triggeredAlerts)
    }
}

