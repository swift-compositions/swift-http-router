public import Coder
public import HTTP
public import Parser
public import RFC_9110
public import Serializer

extension HTTP.Segment {

    public struct Value<Wrapped: LosslessStringConvertible>: Sendable {

        public init() {}
    }
}

extension HTTP.Segment.Value: Parsing, Serializing, Coding {

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
        guard let value = Wrapped(try input.target.segment()) else {
            throw .mismatch
        }
        try input.target.drop()
        return value
    }

    public func serialize(_ output: Wrapped, into buffer: inout Buffer) throws(Failure) {
        try buffer.target.append(output.description)
    }
}
