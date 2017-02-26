/// TSTOOLS: Description... date: 09/06/16
/// Modified : 09/23/16 (added TSIdentifiable)

protocol TSConfigurable {
    associatedtype TSPresenterDataSource
    func configure(with dataSource : TSPresenterDataSource)
}

protocol TSStylable {
    associatedtype TSStyleSoruce
    func style(with styleSource : TSStyleSoruce)
}

protocol TSIdentifiable {
    static var identifier : String {get}
}

extension TSIdentifiable {
    static var identifier : String {
        return String(describing: self)
    }
}
