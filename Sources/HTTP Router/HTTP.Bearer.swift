public import Coder
public import HTTP
public import Parser
public import RFC_6750
public import RFC_9110
public import Serializer

extension HTTP {

    public struct Bearer: Sendable, Hashable {

        public init() {}
    }
}

extension HTTP.Bearer: Parsing, Serializing, Coding {

    public typealias Input = HTTP.Router.Request

    public typealias Output = RFC_6750.Bearer

    public typealias Buffer = HTTP.Router.Request

    public typealias Failure = HTTP.Router.Error

    public typealias Body = Never

    public var body: Never {
        borrowing get {
            return fatalError("leaf coder: parse(_:) and serialize(_:into:) are implemented directly")
        }
    }

    public borrowing func parse(_ input: inout Input) throws(Failure) -> RFC_6750.Bearer {
        guard let value = input.headers[.authorization].first else {
            throw .mismatch
        }
        let bearer: RFC_6750.Bearer
        do throws(RFC_6750.Bearer.Error) {
            bearer = try RFC_6750.Bearer.parse(from: value.rawValue)
        } catch {
            throw .mismatch
        }
        input.headers.remove(.authorization)
        return bearer
    }

    public func serialize(_ output: RFC_6750.Bearer, into buffer: inout Buffer) throws(Failure) {
        buffer.headers.remove(.authorization)
        buffer.headers.append(
            RFC_9110.Field(name: .authorization, value: .init(unchecked: output.authorizationHeaderValue()))
        )
    }
}
