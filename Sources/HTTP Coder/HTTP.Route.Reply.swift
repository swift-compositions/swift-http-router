public import Coder
public import HTTP
public import Parser
public import RFC_9110
public import Serializer

extension HTTP.Route {

    public struct Reply<Content: Coding>: Coding
    where
        Content.Input == HTTP.Route.Response,
        Content.Buffer == HTTP.Route.Response,
        Content.Failure == HTTP.Route.Error
    {
        public typealias Input = HTTP.Route.Response

        public typealias Output = Content.Output

        public typealias Buffer = HTTP.Route.Response

        public typealias Failure = HTTP.Route.Error

        public let status: HTTP.Status

        public let content: Content

        public init(
            _ status: HTTP.Status,
            @Parser.Builder<HTTP.Route.Response> content: () -> Content
        ) {
            self.status = status
            self.content = content()
        }

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            try status.parse(&input)
            return try content.parse(&input)
        }

        public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
            try status.serialize((), into: &buffer)
            try content.serialize(output, into: &buffer)
        }
    }
}
