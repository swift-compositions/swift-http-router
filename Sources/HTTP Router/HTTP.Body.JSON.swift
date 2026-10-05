#if Foundation
    public import Byte
    public import Coder
    public import Foundation
    public import HTTP
    public import JSON
    public import JSON_Foundation_Integration
    public import RFC_9110

    extension HTTP.Body {

        public struct JSON<Value: Swift.Codable>: Sendable {

            public init(_ type: Value.Type = Value.self) {}
        }
    }

    extension HTTP.Body.JSON: HTTP.Body.Coder.`Protocol` {

        public typealias Input = [Byte]

        public typealias Output = Value

        public typealias Buffer = [Byte]

        public typealias Failure = JSON::JSON.Foundation.Error

        public typealias Body = Never

        public var body: Never {
            borrowing get {
                return fatalError("leaf coder: parse(_:) and serialize(_:into:) are implemented directly")
            }
        }

        public static var contentType: HTTP.MediaType { HTTP.MediaType("application", "json") }

        public func parse(_ input: inout [Byte]) throws(Failure) -> Value {
            var data = Data(input.map(\.bitPattern))
            let value = try JSON::JSON.Foundation.Coder<Value>().parse(&data)
            input = []
            return value
        }

        public func serialize(_ output: Value, into buffer: inout [Byte]) throws(Failure) {
            var data = Data()
            try JSON::JSON.Foundation.Coder<Value>().serialize(output, into: &data)
            buffer.append(contentsOf: data.map(Byte.init(bitPattern:)))
        }
    }
#endif
