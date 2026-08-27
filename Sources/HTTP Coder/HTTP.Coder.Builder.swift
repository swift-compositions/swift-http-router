public import Call_Algebra
public import Coder_Primitive
public import HTTP
public import Parser_Primitive
public import RFC_9110
public import Serializer_Primitive

extension HTTP.Coder {
    @resultBuilder
    public struct Builder<Domain: Call_Algebra.Call.Domain> {}
}

extension HTTP.Coder.Builder {
    public static func buildExpression<Value: Coder_Primitive.Coder.`Protocol`>(
        _ value: Value
    ) -> Value {
        value
    }

    public static func buildPartialBlock<Content, Value>(
        first value: Value
    ) -> HTTP.Coder.Leaf<
        Domain,
        Domain.Call.Operation,
        Content,
        Value
    >
    where
        Domain.Call: Call_Algebra.Call.Singleton,
        Value: Coder_Primitive.Coder.`Protocol`,
        Value.Input == HTTP.Message.Response<Content>?,
        Value.Output == Swift.Result<
            Domain.Call.Operation.Output,
            Domain.Call.Operation.Failure
        >,
        Value.Buffer == HTTP.Message.Response<Content>?
    {
        .init(value)
    }

    public static func buildExpression<Response: HTTP.Responses>(
        _ response: Response
    ) -> Response
    where Response.Domain == Domain {
        response
    }

    public static func buildPartialBlock<Response: HTTP.Responses>(
        first response: Response
    ) -> Response
    where Response.Domain == Domain {
        response
    }

    public static func buildPartialBlock<
        First: HTTP.Responses,
        Second: HTTP.Responses
    >(
        accumulated first: First,
        next second: Second
    ) -> HTTP.Coder.Sequence<Domain, First, Second>
    where
        First.Domain == Domain,
        Second.Domain == Domain,
        First.Content == Second.Content
    {
        .init(first, second)
    }

    public static func buildFinalResult<Response: HTTP.Responses>(
        _ response: Response
    ) -> Response
    where
        Response.Domain == Domain,
        Response.Coverage == Domain.Call.Coverage
    {
        response
    }
}
