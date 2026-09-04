public import Byte
public import Coder
public import HTTP

extension HTTP {

    public static func success<Refusal: Swift.Error, Value: Coder.Codable>(
        _ status: HTTP.Status,
        _: Value.Type
    ) -> HTTP.Reply.Success<Refusal, HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Value.Coder>>>
    where
        Value.Coder.Input == ArraySlice<Byte>,
        Value.Coder.Output == Value,
        Value.Coder.Buffer == [Byte]
    {
        .init(HTTP.Reply.Status(status, HTTP.Content(Value.self)))
    }

    public static func success<Refusal: Swift.Error>(
        _ status: HTTP.Status
    ) -> HTTP.Reply.Success<Refusal, HTTP.Reply.Status<HTTP.Reply.Empty>> {
        .init(HTTP.Reply.Status(status, HTTP.Reply.Empty()))
    }

    public static func ok<Refusal: Swift.Error, Value: Coder.Codable>(
        _: Value.Type
    ) -> HTTP.Reply.Success<Refusal, HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Value.Coder>>>
    where
        Value.Coder.Input == ArraySlice<Byte>,
        Value.Coder.Output == Value,
        Value.Coder.Buffer == [Byte]
    {
        HTTP.success(.ok, Value.self)
    }

    public static func ok<Refusal: Swift.Error>() -> HTTP.Reply.Success<Refusal, HTTP.Reply.Status<HTTP.Reply.Empty>> {
        HTTP.success(.ok)
    }

    public static func created<Refusal: Swift.Error, Value: Coder.Codable>(
        _: Value.Type
    ) -> HTTP.Reply.Success<Refusal, HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Value.Coder>>>
    where
        Value.Coder.Input == ArraySlice<Byte>,
        Value.Coder.Output == Value,
        Value.Coder.Buffer == [Byte]
    {
        HTTP.success(.created, Value.self)
    }

    public static func created<Refusal: Swift.Error>() -> HTTP.Reply.Success<Refusal, HTTP.Reply.Status<HTTP.Reply.Empty>> {
        HTTP.success(.created)
    }

    public static func accepted<Refusal: Swift.Error, Value: Coder.Codable>(
        _: Value.Type
    ) -> HTTP.Reply.Success<Refusal, HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Value.Coder>>>
    where
        Value.Coder.Input == ArraySlice<Byte>,
        Value.Coder.Output == Value,
        Value.Coder.Buffer == [Byte]
    {
        HTTP.success(.accepted, Value.self)
    }

    public static func accepted<Refusal: Swift.Error>() -> HTTP.Reply.Success<Refusal, HTTP.Reply.Status<HTTP.Reply.Empty>> {
        HTTP.success(.accepted)
    }

    public static func noContent<Refusal: Swift.Error>() -> HTTP.Reply.Success<Refusal, HTTP.Reply.Status<HTTP.Reply.Empty>> {
        HTTP.success(.noContent)
    }
}
