public import Coder
public import HTTP
public import HTTP_Router

extension HTTP {

    public static func reply<Body: Coding>(
        @HTTP.Reply.Builder _ body: () -> Body
    ) -> Body
    where
        Body.Input == HTTP.Router.Response,
        Body.Buffer == HTTP.Router.Response,
        Body.Failure == HTTP.Router.Error
    {
        body()
    }
}
