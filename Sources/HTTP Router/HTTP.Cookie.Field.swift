public import Byte
public import Coder
public import HTTP
public import Parser
public import RFC_6265
public import RFC_9110
public import Serializer

extension HTTP.Cookie {

    public struct Field<Coder: HTTP.Body.Coder.`Protocol`>: Sendable where Coder: Sendable {

        public let name: Swift.String

        public let coder: Coder

        public init(_ name: Swift.String, _ coder: Coder) {
            self.name = name
            self.coder = coder
        }
    }
}

extension HTTP.Cookie.Field: Parsing, Serializing, Coding {

    public typealias Input = HTTP.Router.Request

    public typealias Output = Coder.Output

    public typealias Buffer = HTTP.Router.Request

    public typealias Failure = HTTP.Router.Error

    public typealias Body = Never

    public borrowing func parse(_ input: inout Input) throws(Failure) -> Coder.Output {
        let name = self.name
        let pairs = input.headers
            .filter { $0.name.rawValue.lowercased() == "cookie" }
            .flatMap { RFC_6265.Cookie.parse(skippingInvalidPairs: $0.value.rawValue).pairs }
        guard let pair = pairs.first(where: { $0.name == name }) else {
            throw .mismatch
        }
        var bytes = pair.value.utf8.map(Byte.init(bitPattern:))
        do throws(Coder.Failure) {
            return try coder.decode(&bytes, as: Coder.contentType)
        } catch {
            throw .malformed
        }
    }

    public func serialize(_ output: Coder.Output, into buffer: inout Buffer) throws(Failure) {
        var bytes: [Byte] = []
        do throws(Coder.Failure) {
            _ = try coder.encode(output, into: &bytes)
        } catch {
            throw .unprintable
        }
        let pair = RFC_6265.Cookie.Pair(name: name, value: Swift.String(decoding: bytes.map(\.bitPattern), as: UTF8.self))
        let existing = buffer.headers.first { $0.name.rawValue.lowercased() == "cookie" }
        let field: RFC_9110.Field
        do throws(RFC_9110.Field.Error) {
            field = try RFC_9110.Field(
                name: "Cookie",
                value: existing.map { "\($0.value.rawValue); \(pair.serialized)" } ?? pair.serialized
            )
        } catch {
            throw .unprintable
        }
        if let existing { buffer.headers.remove(existing.name) }
        buffer.headers.append(field)
    }
}
