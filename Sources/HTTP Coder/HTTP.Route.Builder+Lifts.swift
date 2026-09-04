public import HTTP
public import Parser
public import RFC_9110

extension Parser.Builder where Input == HTTP.Route.Request {

    public static func buildExpression(_ method: HTTP.Method) -> HTTP.Method {
        method
    }

    public static func buildExpression(_ target: HTTP.Target) -> HTTP.Target {
        target
    }
}
