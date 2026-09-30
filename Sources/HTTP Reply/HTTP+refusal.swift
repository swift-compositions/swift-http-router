public import Byte
public import Coder
public import HTTP
public import HTTP_Router
public import RFC_9110

extension HTTP {

    public static func refusal<Reason: Coding>(
        _ status: HTTP.Status,
        _ reason: Reason
    ) -> HTTP.Reply.Refusal<HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Reason>>>
    where
        Reason.Input == ArraySlice<Byte>,
        Reason.Output: Swift.Error,
        Reason.Buffer == [Byte]
    {
        .init(HTTP.Reply.Status(status, HTTP.Content(reason)))
    }

    public static func badRequest<Reason: Coding>(
        _ reason: Reason
    ) -> HTTP.Reply.Refusal<HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Reason>>>
    where
        Reason.Input == ArraySlice<Byte>,
        Reason.Output: Swift.Error,
        Reason.Buffer == [Byte]
    {
        HTTP.refusal(.badRequest, reason)
    }

    public static func unauthorized<Reason: Coding>(
        _ reason: Reason
    ) -> HTTP.Reply.Refusal<HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Reason>>>
    where
        Reason.Input == ArraySlice<Byte>,
        Reason.Output: Swift.Error,
        Reason.Buffer == [Byte]
    {
        HTTP.refusal(.unauthorized, reason)
    }

    public static func forbidden<Reason: Coding>(
        _ reason: Reason
    ) -> HTTP.Reply.Refusal<HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Reason>>>
    where
        Reason.Input == ArraySlice<Byte>,
        Reason.Output: Swift.Error,
        Reason.Buffer == [Byte]
    {
        HTTP.refusal(.forbidden, reason)
    }

    public static func notFound<Reason: Coding>(
        _ reason: Reason
    ) -> HTTP.Reply.Refusal<HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Reason>>>
    where
        Reason.Input == ArraySlice<Byte>,
        Reason.Output: Swift.Error,
        Reason.Buffer == [Byte]
    {
        HTTP.refusal(.notFound, reason)
    }

    public static func conflict<Reason: Coding>(
        _ reason: Reason
    ) -> HTTP.Reply.Refusal<HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Reason>>>
    where
        Reason.Input == ArraySlice<Byte>,
        Reason.Output: Swift.Error,
        Reason.Buffer == [Byte]
    {
        HTTP.refusal(.conflict, reason)
    }

    public static func unprocessableContent<Reason: Coding>(
        _ reason: Reason
    ) -> HTTP.Reply.Refusal<HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Reason>>>
    where
        Reason.Input == ArraySlice<Byte>,
        Reason.Output: Swift.Error,
        Reason.Buffer == [Byte]
    {
        HTTP.refusal(.unprocessableContent, reason)
    }
}
