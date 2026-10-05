public import Coder
public import HTTP
public import Parser
public import RFC_3986
public import RFC_9110
public import Serializer

extension HTTP.Query.Field {

    public struct Optional: Sendable {

        public let name: Swift.String

        public init(_ name: Swift.String) {
            self.name = name
        }
    }
}

extension HTTP.Query.Field.Optional: Parsing, Serializing, Coding {

    public typealias Input = HTTP.Router.Request

    public typealias Output = Wrapped?

    public typealias Buffer = HTTP.Router.Request

    public typealias Failure = HTTP.Router.Error

    public typealias Body = Never

    public var body: Never {
        borrowing get {
            return fatalError("leaf coder: parse(_:) and serialize(_:into:) are implemented directly")
        }
    }

    public borrowing func parse(_ input: inout Input) throws(Failure) -> Wrapped? {
        let name = self.name
        guard
            let (_, query) = input.target.remaining,
            let query,
            query.parameters.contains(where: { HTTP.Target.decoded($0.key) == name })
        else {
            return nil
        }
        return try HTTP.Query.Field<Wrapped>(name).parse(&input)
    }

    public func serialize(_ output: Wrapped?, into buffer: inout Buffer) throws(Failure) {
        guard let output else { return }
        try HTTP.Query.Field<Wrapped>(name).serialize(output, into: &buffer)
    }
}
