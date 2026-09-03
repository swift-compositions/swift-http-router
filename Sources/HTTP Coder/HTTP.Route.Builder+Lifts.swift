public import HTTP
public import Parser
public import RFC_9110

extension Parser.Builder where Input: HTTP.Message.Requesting {

    public static func buildExpression(_ method: HTTP.Method) -> HTTP.Route.Method<Input> {
        .init(method)
    }

    public static func buildExpression(_ target: HTTP.Target) -> HTTP.Route.Target<Input> {
        .init(target)
    }
}

extension Parser.Builder where Input == HTTP.Route.Request {

    public static func buildExpression(_ method: HTTP.Method) -> HTTP.Route.Method<Input> {
        .init(method)
    }

    public static func buildExpression(_ target: HTTP.Target) -> HTTP.Route.Target<Input> {
        .init(target)
    }
}

extension Parser.Builder where Input: HTTP.Message.Responding {

    public static func buildExpression(_ status: HTTP.Status) -> HTTP.Route.Status<Input> {
        .init(status)
    }
}

extension Parser.Builder where Input == HTTP.Route.Response {

    public static func buildExpression(_ status: HTTP.Status) -> HTTP.Route.Status<Input> {
        .init(status)
    }
}
