public import Coder_Parser_Primitives
public import Coder_Primitive
public import HTTP
public import Optic_Primitives
public import Parser_Conversion_Primitives
public import Parser_Error_Primitives
public import Parser_Primitive
public import Parser_Take_Primitives
public import Serializer_Primitive

extension HTTP.Route {

    /// One branch of a router: a route body embedded into a call case
    /// through its derived prism.
    ///
    /// Parsing runs the body and embeds its output — total, since a prism
    /// always embeds. Printing extracts first, and a call belonging to a
    /// sibling case refuses as `noMatch`, so an alternation hands the
    /// buffer to the branch that owns the value.
    public struct Case<Root, Content: Coder.`Protocol`>
    where
        Content.Input == HTTP.Route.Input,
        Content.Buffer == HTTP.Route.Input,
        Content.Failure: HTTP.Route.Error.Carrier
    {

        public let body: Body

        public init(
            _ prism: Optic.Prism<Root, Content.Output>,
            body content: Content
        ) {
            self.body = Parser.Converted(
                upstream: content,
                downstream: Parser.Conversion.Case(
                    embed: prism.embed,
                    extract: prism.extract
                )
            ).error.map { failure in
                switch failure {
                case .left(let underlying): underlying.route
                case .right: .noMatch
                }
            }
        }

        public init(
            _ prism: Optic.Prism<Root, Content.Output>,
            @Parser.Take.Builder<HTTP.Route.Input> body build: () -> Content
        ) {
            self.init(prism, body: build())
        }
    }
}

extension HTTP.Route.Case: Coder.`Protocol` {

    public typealias Input = HTTP.Route.Input
    public typealias Output = Root
    public typealias Buffer = HTTP.Route.Input
    public typealias Failure = HTTP.Route.Error
    public typealias Body = Parser.Error.Map<
        Parser.Converted<Content, Parser.Conversion.Case<Root, Content.Output>>,
        HTTP.Route.Error
    >

    public borrowing func parse(
        _ input: inout HTTP.Route.Input
    ) throws(HTTP.Route.Error) -> Root {
        try body.parse(&input)
    }

    public borrowing func serialize(
        _ output: Root,
        into buffer: inout HTTP.Route.Input
    ) throws(HTTP.Route.Error) {
        try body.serialize(output, into: &buffer)
    }
}
