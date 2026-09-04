public import Byte
public import Coder
public import HTTP

extension HTTP {

    public static func refusal<Value, Reason: Swift.Error & Coder.Codable>(
        _ status: HTTP.Status,
        _: Reason.Type
    ) -> HTTP.Reply.Refusal<Value, HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Reason.Coder>>>
    where
        Reason.Coder.Input == ArraySlice<Byte>,
        Reason.Coder.Output == Reason,
        Reason.Coder.Buffer == [Byte]
    {
        .init(HTTP.Reply.Status(status, HTTP.Content(Reason.self)))
    }

    public static func badRequest<Value, Reason: Swift.Error & Coder.Codable>(
        _: Reason.Type
    ) -> HTTP.Reply.Refusal<Value, HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Reason.Coder>>>
    where
        Reason.Coder.Input == ArraySlice<Byte>,
        Reason.Coder.Output == Reason,
        Reason.Coder.Buffer == [Byte]
    {
        HTTP.refusal(.badRequest, Reason.self)
    }

    public static func unauthorized<Value, Reason: Swift.Error & Coder.Codable>(
        _: Reason.Type
    ) -> HTTP.Reply.Refusal<Value, HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Reason.Coder>>>
    where
        Reason.Coder.Input == ArraySlice<Byte>,
        Reason.Coder.Output == Reason,
        Reason.Coder.Buffer == [Byte]
    {
        HTTP.refusal(.unauthorized, Reason.self)
    }

    public static func forbidden<Value, Reason: Swift.Error & Coder.Codable>(
        _: Reason.Type
    ) -> HTTP.Reply.Refusal<Value, HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Reason.Coder>>>
    where
        Reason.Coder.Input == ArraySlice<Byte>,
        Reason.Coder.Output == Reason,
        Reason.Coder.Buffer == [Byte]
    {
        HTTP.refusal(.forbidden, Reason.self)
    }

    public static func notFound<Value, Reason: Swift.Error & Coder.Codable>(
        _: Reason.Type
    ) -> HTTP.Reply.Refusal<Value, HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Reason.Coder>>>
    where
        Reason.Coder.Input == ArraySlice<Byte>,
        Reason.Coder.Output == Reason,
        Reason.Coder.Buffer == [Byte]
    {
        HTTP.refusal(.notFound, Reason.self)
    }

    public static func conflict<Value, Reason: Swift.Error & Coder.Codable>(
        _: Reason.Type
    ) -> HTTP.Reply.Refusal<Value, HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Reason.Coder>>>
    where
        Reason.Coder.Input == ArraySlice<Byte>,
        Reason.Coder.Output == Reason,
        Reason.Coder.Buffer == [Byte]
    {
        HTTP.refusal(.conflict, Reason.self)
    }

    public static func unprocessableContent<Value, Reason: Swift.Error & Coder.Codable>(
        _: Reason.Type
    ) -> HTTP.Reply.Refusal<Value, HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Reason.Coder>>>
    where
        Reason.Coder.Input == ArraySlice<Byte>,
        Reason.Coder.Output == Reason,
        Reason.Coder.Buffer == [Byte]
    {
        HTTP.refusal(.unprocessableContent, Reason.self)
    }
}
