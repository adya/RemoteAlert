/// Defines generic way to count things.
protocol Countable {
    var count : Int {get}
}

extension Array : Countable {}

extension Set : Countable {}

extension Dictionary : Countable {}

extension String : Countable {
    var count : Int {
        return self.characters.count
    }
}