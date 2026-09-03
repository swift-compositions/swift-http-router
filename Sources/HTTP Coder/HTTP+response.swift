public import Client
public import HTTP
public import Operation
public import RFC_9110
import Serializer

extension HTTP {

    public static func response<Index: HTTP.Respondable>(
        _: Index.Type,
        to input: Index.Input,
        using client: Client::Client<Index.Input, Index.Output, Index.Failure>
    ) async throws(HTTP.Route.Error) -> HTTP.Route.Response
    where Index.Input: Copyable & Escapable {
        let result: Swift.Result<Index.Output, Index.Failure>
        do throws(Index.Failure) {
            result = .success(try await client(input))
        } catch {
            result = .failure(error)
        }
        var buffer = HTTP.Route.Response.blank
        try Index.response.serialize(result, into: &buffer)
        return buffer
    }
}

extension Operation._Application
where
    Index: HTTP.Respondable,
    Input: Copyable & Escapable
{

    public func respond(
        _ arrow: @escaping (Index.Input) async throws(Index.Failure) -> Index.Output
    ) async throws(HTTP.Route.Error) -> HTTP.Route.Response {
        try await HTTP.response(Index.self, to: input, using: .init(run: arrow))
    }
}
