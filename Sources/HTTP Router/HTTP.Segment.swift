public import Coder
public import HTTP
public import Parser
public import RFC_3986
public import RFC_9110
public import Serializer

extension HTTP {

    public struct Segment: Sendable, Hashable {

        public let value: Swift.String

        public init(_ value: Swift.String) {
            self.value = value
        }
    }
}

extension HTTP.Segment: Parsing, Serializing, Coding {

    public typealias Input = HTTP.Router.Request

    public typealias Output = Void

    public typealias Buffer = HTTP.Router.Request

    public typealias Failure = HTTP.Router.Error

    public typealias Body = Never

    public borrowing func parse(_ input: inout Input) throws(Failure) {
        guard try input.target.segment() == value else {
            throw .mismatch
        }
        try input.target.drop()
    }

    public func serialize(_ output: Void, into buffer: inout Buffer) throws(Failure) {
        try buffer.target.append(value)
    }
}

extension HTTP.Target {

    var remaining: (path: RFC_3986.URI.Path, query: RFC_3986.URI.Query?)? {
        guard case .resource(let uri) = self, let path = uri.path else { return nil }
        return (path, uri.query)
    }

    func segment() throws(HTTP.Router.Error) -> Swift.String {
        guard let segment = remaining?.path.firstSegment else {
            throw .mismatch
        }
        return Self.decoded(segment)
    }

    mutating func drop() throws(HTTP.Router.Error) {
        guard let (path, query) = remaining else { throw .mismatch }
        self = try .relative(Array(path.segments.dropFirst()), isAbsolute: path.isAbsolute, query: query)
    }

    mutating func append(_ segment: Swift.String) throws(HTTP.Router.Error) {
        let (path, query) = remaining ?? ([] as RFC_3986.URI.Path, nil)
        let encoded = Self.encoded(segment, allowing: .pathSegment)
        self = try .relative(path.segments + [encoded], isAbsolute: true, query: query)
    }

    static func relative(
        _ segments: [Swift.String],
        isAbsolute: Bool,
        query: RFC_3986.URI.Query?
    ) throws(HTTP.Router.Error) -> Self {
        let path: RFC_3986.URI.Path
        do throws(RFC_3986.URI.Path.Error) {
            path = try RFC_3986.URI.Path(segments: segments, isAbsolute: isAbsolute)
        } catch {
            throw .unprintable
        }
        return .resource(RFC_3986.URI(unchecked: query.map { "\(path)?\($0)" } ?? path.description))
    }

    static func decoded(_ raw: Swift.String) -> Swift.String {
        Swift.String(decoding: RFC_3986.percentDecode(Array(raw.utf8)), as: UTF8.self)
    }

    static func encoded(_ value: Swift.String, allowing allowed: RFC_3986.ByteSet) -> Swift.String {
        Swift.String(decoding: RFC_3986.percentEncode(Array(value.utf8), allowing: allowed), as: UTF8.self)
    }
}
