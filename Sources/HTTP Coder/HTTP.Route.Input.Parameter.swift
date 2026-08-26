public import HTTP

extension HTTP.Route.Input {

    /// One ordered query pair, percent-decoded.
    public struct Parameter: Equatable, Sendable {

        public var name: String

        public var value: String?

        public init(name: String, value: String?) {
            self.name = name
            self.value = value
        }
    }
}
