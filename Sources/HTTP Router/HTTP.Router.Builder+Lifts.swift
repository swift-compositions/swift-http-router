public import HTTP
public import Coder
public import RFC_3986
public import RFC_9110

extension Coder::Builder where Input == HTTP.Router.Request, Buffer == HTTP.Router.Request {

    public static func buildExpression(_ method: HTTP.Method) -> HTTP.Method {
        method
    }

    public static func buildExpression(_ target: HTTP.Target) -> HTTP.Target {
        target
    }

    public static func buildExpression(_ uri: RFC_3986.URI) -> HTTP.Target {
        .resource(uri)
    }
}
