public import Coder
public import HTTP
public import Parser
public import RFC_3986
public import RFC_9110
public import Serializer

extension HTTP.Query {

    public struct Field<Wrapped: LosslessStringConvertible & Equatable & Sendable>: Sendable {

        public let name: Swift.String

        public let `default`: Wrapped?

        public init(_ name: Swift.String, default: Wrapped? = nil) {
            self.name = name
            self.default = `default`
        }
    }
}

extension HTTP.Query.Field: Parsing, Serializing, Coding {

    public typealias Input = HTTP.Router.Request

    public typealias Output = Wrapped

    public typealias Buffer = HTTP.Router.Request

    public typealias Failure = HTTP.Router.Error

    public typealias Body = Never

    public var body: Never {
        borrowing get {
            return fatalError("leaf coder: parse(_:) and serialize(_:into:) are implemented directly")
        }
    }

    public borrowing func parse(_ input: inout Input) throws(Failure) -> Wrapped {
        let name = self.name
        guard
            let (path, query) = input.target.remaining,
            let query,
            let index = query.parameters.firstIndex(where: { HTTP.Target.decoded($0.key) == name })
        else {
            guard let value = self.default else { throw .mismatch }
            return value
        }
        guard let raw = query.parameters[index].value, let value = Wrapped(HTTP.Target.decoded(raw)) else {
            throw .mismatch
        }
        var rest = query.parameters.map { ($0.key, $0.value) }
        rest.remove(at: index)
        input.target = try .relative(path.segments, isAbsolute: path.isAbsolute, query: try HTTP.Target.query(rest))
        return value
    }

    public func serialize(_ output: Wrapped, into buffer: inout Buffer) throws(Failure) {
        guard output != self.default else { return }
        let (path, query) = buffer.target.remaining ?? ([] as RFC_3986.URI.Path, nil)
        let parameters = (query?.parameters.map { ($0.key, $0.value) } ?? []) + [(
            HTTP.Target.encoded(name, allowing: .queryComponent),
            HTTP.Target.encoded(output.description, allowing: .queryComponent)
        )]
        buffer.target = try .relative(path.segments, isAbsolute: path.isAbsolute, query: try HTTP.Target.query(parameters))
    }
}

extension HTTP.Target {

    static func query(_ parameters: [(Swift.String, Swift.String?)]) throws(HTTP.Router.Error) -> RFC_3986.URI.Query? {
        guard !parameters.isEmpty else { return nil }
        do throws(RFC_3986.URI.Query.Error) {
            return try RFC_3986.URI.Query(parameters)
        } catch {
            throw .unprintable
        }
    }
}
