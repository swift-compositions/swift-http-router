public import Client
public import HTTP
public import RFC_9110

extension HTTP {

    public typealias Client<Failure: Swift.Error> = Client::Client<
        HTTP.Route.Request,
        HTTP.Route.Response,
        Failure
    >

    public typealias Responder<Failure: Swift.Error> = Client::Client<
        HTTP.Route.Request,
        HTTP.Route.Response,
        Failure
    >
}
