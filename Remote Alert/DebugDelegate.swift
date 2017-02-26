protocol DebugDelegate {
    func debug(_ silentChecker : SilentChecker, hasDebugInfo: String, withTimestamp: Date)
    func debug(_ alertNotifier: AlertNotifier, hasDebugInfo: String, withTimestamp: Date)
    func debug(_ alertManager: AlertManager, hasDebugInfo: String, withTimestamp: Date)
}
