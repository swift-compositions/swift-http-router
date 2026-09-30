public import Byte
public import HTTP
public import HTTP_Router
public import Parser
public import RFC_9110
public import Serializer

extension HTTP.Message.Response where Content == [Byte] {

    public static func ok() -> Self {
        .init(status: .ok)
    }

    public static func ok<Representation: Serializing & ~Copyable>(
        _ value: borrowing Representation.Output,
        using representation: borrowing Representation
    ) throws(HTTP.Router.Error) -> Self
    where
        Representation.Output: ~Copyable,
        Representation.Buffer == [Byte]
    {
        try .init(.ok, value, using: representation)
    }

    public static func badRequest<Representation: Serializing & ~Copyable>(
        _ value: borrowing Representation.Output,
        using representation: borrowing Representation
    ) throws(HTTP.Router.Error) -> Self
    where
        Representation.Output: ~Copyable,
        Representation.Buffer == [Byte]
    {
        try .init(.badRequest, value, using: representation)
    }

    public init<Representation: Serializing & ~Copyable>(
        _ status: HTTP.Status,
        _ value: borrowing Representation.Output,
        using representation: borrowing Representation
    ) throws(HTTP.Router.Error)
    where
        Representation.Output: ~Copyable,
        Representation.Buffer == [Byte]
    {
        var content: [Byte] = []
        do throws(Representation.Failure) {
            try representation.serialize(value, into: &content)
        } catch {
            throw .unprintable
        }
        self.init(status: status)
        self.content = content
    }

    public func decoded<Representation: Parsing & ~Copyable>(
        using representation: borrowing Representation
    ) throws(HTTP.Router.Error) -> Representation.Output
    where
        Representation.Input == ArraySlice<Byte>,
        Representation.Output: ~Copyable
    {
        guard let content else {
            throw .malformed
        }
        var cursor = content[...]
        let output: Representation.Output
        do throws(Representation.Failure) {
            output = try representation.parse(&cursor)
        } catch {
            throw .malformed
        }
        guard cursor.isEmpty else {
            throw .malformed
        }
        return output
    }
}
