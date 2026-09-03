public import HTTP
public import RFC_9110

extension HTTP.Message {

    public protocol `Protocol` {

        associatedtype Content

        var content: Content? { get set }

        static var blank: Self { get }
    }
}

extension HTTP.Message.Request: HTTP.Message.`Protocol` {

    public static var blank: Self {
        .init(method: .get, target: .asterisk)
    }
}

extension HTTP.Message.Response: HTTP.Message.`Protocol` {

    public static var blank: Self {
        .init(status: .ok)
    }
}
