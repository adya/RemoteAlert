protocol DebugDelegate {
    func debug(silentChecker : SilentChecker, hasDebugInfo: String, withTimestamp: NSDate)
    func debug(alertNotifier: AlertNotifier, hasDebugInfo: String, withTimestamp: NSDate)
    func debug(alertManager: AlertManager, hasDebugInfo: String, withTimestamp: NSDate)
}