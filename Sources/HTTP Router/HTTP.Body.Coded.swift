public import Byte
public import Coder
public import HTTP
public import Parser
public import RFC_9110
public import Serializer

extension HTTP.Body {

    public struct Coded<Coder: HTTP.Body.Coder.`Protocol`>: Sendable where Coder: Sendable {

        public let coder: Coder

        public init(_ coder: Coder) {
            self.coder = coder
        }
    }
}

extension HTTP.Body.Coded: Parsing, Serializing, Coding {

    public typealias Input = HTTP.Router.Request

    public typealias Output = Coder.Output

    public typealias Buffer = HTTP.Router.Request

    public typealias Failure = HTTP.Router.Error

    public typealias Body = Never

    public var body: Never {
        borrowing get {
            return fatalError("leaf coder: parse(_:) and serialize(_:into:) are implemented directly")
        }
    }

    public borrowing func parse(_ input: inout Input) throws(Failure) -> Coder.Output {
        guard var content = input.content else {
            throw .mismatch
        }
        let expected = Coder.contentType
        if let declared = input.headers[.contentType].first {
            guard declared.rawValue.lowercased().hasPrefix("\(expected.type)/\(expected.subtype)".lowercased()) else {
                throw .mismatch
            }
        }
        let output: Coder.Output
        do throws(Coder.Failure) {
            output = try coder.decode(&content, as: expected)
        } catch {
            throw .malformed
        }
        input.content = nil
        return output
    }

    public func serialize(_ output: Coder.Output, into buffer: inout Buffer) throws(Failure) {
        do throws(Coder.Failure) {
            try buffer.body(set: output, using: coder)
        } catch {
            throw .unprintable
        }
    }
}
