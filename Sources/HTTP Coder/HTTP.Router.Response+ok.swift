public import Byte
public import Coder
public import HTTP
public import Parser
public import Serializer

extension HTTP.Message.Response where Content == [Byte] {

    public static func ok() -> Self {
        .init(status: .ok)
    }

    public static func ok<Value: Coder.Codable>(_ value: Value) throws(HTTP.Router.Error) -> Self
    where
        Value.Coder.Input == ArraySlice<Byte>,
        Value.Coder.Output == Value,
        Value.Coder.Buffer == [Byte]
    {
        try .init(.ok, value)
    }

    public static func badRequest<Value: Coder.Codable>(_ value: Value) throws(HTTP.Router.Error) -> Self
    where
        Value.Coder.Input == ArraySlice<Byte>,
        Value.Coder.Output == Value,
        Value.Coder.Buffer == [Byte]
    {
        try .init(.badRequest, value)
    }

    public init<Value: Coder.Codable>(_ status: HTTP.Status, _ value: Value) throws(HTTP.Router.Error)
    where
        Value.Coder.Input == ArraySlice<Byte>,
        Value.Coder.Output == Value,
        Value.Coder.Buffer == [Byte]
    {
        self.init(status: status)
        try HTTP.Content<Self, Value.Coder>(Value.self).serialize(value, into: &self)
    }

    public func decoded<Value: Coder.Codable>(as _: Value.Type) throws(HTTP.Router.Error) -> Value
    where
        Value.Coder.Input == ArraySlice<Byte>,
        Value.Coder.Output == Value,
        Value.Coder.Buffer == [Byte]
    {
        var input = self
        return try HTTP.Content<Self, Value.Coder>(Value.self).parse(&input)
    }
}
