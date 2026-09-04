public import HTTP
public import Parser
public import RFC_3986

extension Parser.Builder where Input == HTTP.Router.Request {

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
