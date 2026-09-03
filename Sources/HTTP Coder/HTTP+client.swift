public import Client
public import Either
public import HTTP
public import Operation
public import Optic
import Parser
public import RFC_9110

extension HTTP {

    public static func client<Domain: HTTP.Routable, Index: HTTP.Respondable, Failure: Swift.Error>(
        _: Domain.Type,
        _ prism: Optic<Domain.Call, Domain.Call, Operation.Application<Index>, Operation.Application<Index>>.Prism,
        transport: HTTP.Client<Failure>
    ) -> Client::Client<
        Index.Input,
        Index.Output,
        Either<Either<Failure, HTTP.Route.Error>, Index.Failure>
    >
    where Index.Input: Copyable & Escapable {
        .init(
            run: { input throws(Either<Either<Failure, HTTP.Route.Error>, Index.Failure>) in
                let request: HTTP.Route.Request
                do throws(HTTP.Route.Error) {
                    request = try HTTP.request(Domain.self, for: prism.embed(.init(input)))
                } catch {
                    throw .left(.right(error))
                }

                let received: HTTP.Route.Response
                do throws(Failure) {
                    received = try await transport(request)
                } catch {
                    throw .left(.left(error))
                }

                let result: Swift.Result<Index.Output, Index.Failure>
                do throws(HTTP.Route.Error) {
                    var input = received
                    result = try Index.response.parse(&input)
                    guard input.content == nil else {
                        throw .malformed
                    }
                } catch {
                    throw .left(.right(error))
                }

                switch result {
                case .success(let output):
                    return output
                case .failure(let refusal):
                    throw .right(refusal)
                }
            }
        )
    }
}
