public import Byte
public import Coder
public import HTTP

extension HTTP {

    public static func refusal<Reason: Swift.Error & Coder.Codable>(
        _ status: HTTP.Status,
        _: Reason.Type
    ) -> HTTP.Reply.Refusal<HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Reason.Coder>>>
    where
        Reason.Coder.Input == ArraySlice<Byte>,
        Reason.Coder.Output == Reason,
        Reason.Coder.Buffer == [Byte]
    {
        .init(HTTP.Reply.Status(status, HTTP.Content(Reason.self)))
    }

    public static func badRequest<Reason: Swift.Error & Coder.Codable>(
        _: Reason.Type
    ) -> HTTP.Reply.Refusal<HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Reason.Coder>>>
    where
        Reason.Coder.Input == ArraySlice<Byte>,
        Reason.Coder.Output == Reason,
        Reason.Coder.Buffer == [Byte]
    {
        HTTP.refusal(.badRequest, Reason.self)
    }

    public static func unauthorized<Reason: Swift.Error & Coder.Codable>(
        _: Reason.Type
    ) -> HTTP.Reply.Refusal<HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Reason.Coder>>>
    where
        Reason.Coder.Input == ArraySlice<Byte>,
        Reason.Coder.Output == Reason,
        Reason.Coder.Buffer == [Byte]
    {
        HTTP.refusal(.unauthorized, Reason.self)
    }

    public static func forbidden<Reason: Swift.Error & Coder.Codable>(
        _: Reason.Type
    ) -> HTTP.Reply.Refusal<HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Reason.Coder>>>
    where
        Reason.Coder.Input == ArraySlice<Byte>,
        Reason.Coder.Output == Reason,
        Reason.Coder.Buffer == [Byte]
    {
        HTTP.refusal(.forbidden, Reason.self)
    }

    public static func notFound<Reason: Swift.Error & Coder.Codable>(
        _: Reason.Type
    ) -> HTTP.Reply.Refusal<HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Reason.Coder>>>
    where
        Reason.Coder.Input == ArraySlice<Byte>,
        Reason.Coder.Output == Reason,
        Reason.Coder.Buffer == [Byte]
    {
        HTTP.refusal(.notFound, Reason.self)
    }

    public static func conflict<Reason: Swift.Error & Coder.Codable>(
        _: Reason.Type
    ) -> HTTP.Reply.Refusal<HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Reason.Coder>>>
    where
        Reason.Coder.Input == ArraySlice<Byte>,
        Reason.Coder.Output == Reason,
        Reason.Coder.Buffer == [Byte]
    {
        HTTP.refusal(.conflict, Reason.self)
    }

    public static func unprocessableContent<Reason: Swift.Error & Coder.Codable>(
        _: Reason.Type
    ) -> HTTP.Reply.Refusal<HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Reason.Coder>>>
    where
        Reason.Coder.Input == ArraySlice<Byte>,
        Reason.Coder.Output == Reason,
        Reason.Coder.Buffer == [Byte]
    {
        HTTP.refusal(.unprocessableContent, Reason.self)
    }
}
