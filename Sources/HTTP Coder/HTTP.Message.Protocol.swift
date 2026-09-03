public import HTTP
public import RFC_9110

extension HTTP.Message {

    public protocol `Protocol` {

        associatedtype Content

        var content: Content? { get set }

        static var blank: Self { get }
    }

    public protocol Requesting: HTTP.Message.`Protocol` {

        var method: HTTP.Method { get set }

        var target: HTTP.Target { get set }
    }

    public protocol Responding: HTTP.Message.`Protocol` {

        var status: HTTP.Status { get set }
    }
}

extension HTTP.Message.Request: HTTP.Message.Requesting {

    public static var blank: Self {
        .init(method: .get, target: .asterisk)
    }
}

extension HTTP.Message.Response: HTTP.Message.Responding {

    public static var blank: Self {
        .init(status: .ok)
    }
}
