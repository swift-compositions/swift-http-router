public import Byte_Primitive
public import HTTP
public import RFC_3986

extension HTTP.Route {

    /// The structured consumption record a router reads and writes.
    ///
    /// Components are split by `RFC_3986` before percent-decoding, so a
    /// `%2F` inside a segment is never a separator. Every stored component is
    /// percent-decoded; a leaf that consumes one removes it.
    public struct Input: Equatable, Sendable {

        /// Present until a method leaf consumes it.
        public var method: HTTP.Method?

        /// The remaining decoded path segments, in order.
        public var path: [String]

        /// The remaining decoded query pairs, in order.
        public var query: [Parameter]

        public var headers: HTTP.Headers

        public var body: [Byte]?

        public init(
            method: HTTP.Method? = nil,
            path: [String] = [],
            query: [Parameter] = [],
            headers: HTTP.Headers = [],
            body: [Byte]? = nil
        ) {
            self.method = method
            self.path = path
            self.query = query
            self.headers = headers
            self.body = body
        }
    }
}

extension HTTP.Route.Input {

    /// Reads a request into the consumption record.
    public init(_ request: HTTP.Request) {
        self.init(
            method: request.method,
            path: (request.path?.segments ?? []).map(Self.decoded),
            query: (request.query?.parameters ?? []).map { parameter in
                Parameter(
                    name: Self.decoded(parameter.key),
                    value: parameter.value.map(Self.decoded)
                )
            },
            headers: request.headers,
            body: request.body
        )
    }

    /// Prints the record back into a request.
    public func request() throws(HTTP.Route.Error) -> HTTP.Request {
        guard let method else {
            throw .unprintable
        }

        let path: RFC_3986.URI.Path
        do {
            path = try RFC_3986.URI.Path(
                segments: self.path.map { Self.encoded($0, allowing: .pathSegment) },
                isAbsolute: true
            )
        } catch {
            throw .unprintable
        }

        var query: RFC_3986.URI.Query?
        if !self.query.isEmpty {
            do {
                query = try RFC_3986.URI.Query(
                    self.query.map { parameter in
                        (
                            Self.encoded(parameter.name, allowing: .queryComponent),
                            parameter.value.map { Self.encoded($0, allowing: .queryComponent) }
                        )
                    }
                )
            } catch {
                throw .unprintable
            }
        }

        return HTTP.Request(
            method: method,
            target: .origin(path: path, query: query),
            headers: headers,
            body: body
        )
    }
}

extension HTTP.Route.Input {

    /// True once every component a router is responsible for has been consumed.
    public var isConsumed: Bool {
        method == nil && path.isEmpty && query.isEmpty && body == nil
    }
}

extension HTTP.Route.Input {

    private static func decoded(_ component: String) -> String {
        RFC_3986.percentDecode(component)
    }

    private static func encoded(
        _ component: String,
        allowing characters: RFC_3986.CharacterSet
    ) -> String {
        RFC_3986.percentEncode(component, allowing: characters)
    }
}
