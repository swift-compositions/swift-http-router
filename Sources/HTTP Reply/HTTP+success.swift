public import Byte
public import Coder
public import HTTP
public import HTTP_Router
public import RFC_9110

extension HTTP {

    public static func success<Value: Coding>(
        _ status: HTTP.Status,
        _ value: Value
    ) -> HTTP.Reply.Success<HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Value>>>
    where
        Value.Input == ArraySlice<Byte>,
        Value.Buffer == [Byte]
    {
        .init(HTTP.Reply.Status(status, HTTP.Content(value)))
    }

    public static func success(
        _ status: HTTP.Status
    ) -> HTTP.Reply.Success<HTTP.Reply.Status<HTTP.Reply.Empty>> {
        .init(HTTP.Reply.Status(status, HTTP.Reply.Empty()))
    }

    public static func ok<Value: Coding>(
        _ value: Value
    ) -> HTTP.Reply.Success<HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Value>>>
    where
        Value.Input == ArraySlice<Byte>,
        Value.Buffer == [Byte]
    {
        HTTP.success(.ok, value)
    }

    public static func ok() -> HTTP.Reply.Success<HTTP.Reply.Status<HTTP.Reply.Empty>> {
        HTTP.success(.ok)
    }

    public static func created<Value: Coding>(
        _ value: Value
    ) -> HTTP.Reply.Success<HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Value>>>
    where
        Value.Input == ArraySlice<Byte>,
        Value.Buffer == [Byte]
    {
        HTTP.success(.created, value)
    }

    public static func created() -> HTTP.Reply.Success<HTTP.Reply.Status<HTTP.Reply.Empty>> {
        HTTP.success(.created)
    }

    public static func accepted<Value: Coding>(
        _ value: Value
    ) -> HTTP.Reply.Success<HTTP.Reply.Status<HTTP.Content<HTTP.Router.Response, Value>>>
    where
        Value.Input == ArraySlice<Byte>,
        Value.Buffer == [Byte]
    {
        HTTP.success(.accepted, value)
    }

    public static func accepted() -> HTTP.Reply.Success<HTTP.Reply.Status<HTTP.Reply.Empty>> {
        HTTP.success(.accepted)
    }

    public static func noContent() -> HTTP.Reply.Success<HTTP.Reply.Status<HTTP.Reply.Empty>> {
        HTTP.success(.noContent)
    }
}
