public import Coder
public import HTTP
public import Parser
public import RFC_9110
public import Serializer

extension HTTP.Segment {

    public struct End: Sendable, Hashable {

        public init() {}
    }
}

extension HTTP.Segment.End: Parsing, Serializing, Coding {

    public typealias Input = HTTP.Router.Request

    public typealias Output = Void

    public typealias Buffer = HTTP.Router.Request

    public typealias Failure = HTTP.Router.Error

    public typealias Body = Never

    public borrowing func parse(_ input: inout Input) throws(Failure) {
        guard input.target.remaining?.path.isEmpty ?? true else {
            throw .mismatch
        }
    }

    public func serialize(_ output: Void, into buffer: inout Buffer) throws(Failure) {
        guard buffer.target.remaining == nil else { return }
        buffer.target = try .relative([], isAbsolute: true, query: nil)
    }
}
