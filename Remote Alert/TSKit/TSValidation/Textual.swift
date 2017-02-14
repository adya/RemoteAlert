/// Defines a type that can be represented as String.
protocol Textual : Countable {
    var text : String {get}
}

extension String : Textual {
    var text: String {
        return self
    }
}

extension Textual {
    var count: Int {
        return self.text.count
    }
}