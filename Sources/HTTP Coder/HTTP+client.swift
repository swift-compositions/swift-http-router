public import Byte
public import Client
public import Coder
public import Either
public import HTTP
public import Operation
public import Optic
public import Parser
public import RFC_9110

extension HTTP {

    public static func client<Domain: HTTP.Routable, Index: Operation.Member, Failure: Swift.Error>(
        _: Domain.Type,
        _: Index.Type,
        transport: HTTP.Client<Failure>
    ) -> Client::Client<Index.Input, Index.Output, Either<Either<Failure, HTTP.Route.Error>, Index.Failure>>
    where
        Domain.Router.Output: ~Copyable,
        Index.Coproduct == Domain.Router.Output,
        Index.Case == Optic<Domain.Router.Output, Domain.Router.Output, Operation.Application<Index>, Operation.Application<Index>>.Case,
        Index.Input: Copyable & Escapable,
        Index.Output: Coder.Codable,
        Index.Output.Coder.Input == ArraySlice<Byte>,
        Index.Output.Coder.Output == Index.Output,
        Index.Output.Coder.Buffer == [Byte],
        Index.Failure: Swift.Error & Coder.Codable,
        Index.Failure.Coder.Input == ArraySlice<Byte>,
        Index.Failure.Coder.Output == Index.Failure,
        Index.Failure.Coder.Buffer == [Byte]
    {
        client(
            Domain.self,
            Index.self,
            transport: transport,
            output: { response throws(HTTP.Route.Error) in try response.decoded(as: Index.Output.self) },
            failure: { response throws(HTTP.Route.Error) in try response.decoded(as: Index.Failure.self) }
        )
    }

    public static func client<Domain: HTTP.Routable, Index: Operation.Member, Failure: Swift.Error>(
        _: Domain.Type,
        _: Index.Type,
        transport: HTTP.Client<Failure>
    ) -> Client::Client<Index.Input, Index.Output, Either<Either<Failure, HTTP.Route.Error>, Never>>
    where
        Domain.Router.Output: ~Copyable,
        Index.Coproduct == Domain.Router.Output,
        Index.Case == Optic<Domain.Router.Output, Domain.Router.Output, Operation.Application<Index>, Operation.Application<Index>>.Case,
        Index.Input: Copyable & Escapable,
        Index.Output: Coder.Codable,
        Index.Output.Coder.Input == ArraySlice<Byte>,
        Index.Output.Coder.Output == Index.Output,
        Index.Output.Coder.Buffer == [Byte],
        Index.Failure == Never
    {
        client(
            Domain.self,
            Index.self,
            transport: transport,
            output: { response throws(HTTP.Route.Error) in try response.decoded(as: Index.Output.self) },
            failure: { _ throws(HTTP.Route.Error) in throw .mismatch }
        )
    }

    public static func client<Domain: HTTP.Routable, Index: Operation.Member, Failure: Swift.Error>(
        _: Domain.Type,
        _: Index.Type,
        transport: HTTP.Client<Failure>
    ) -> Client::Client<Index.Input, Void, Either<Either<Failure, HTTP.Route.Error>, Index.Failure>>
    where
        Domain.Router.Output: ~Copyable,
        Index.Coproduct == Domain.Router.Output,
        Index.Case == Optic<Domain.Router.Output, Domain.Router.Output, Operation.Application<Index>, Operation.Application<Index>>.Case,
        Index.Input: Copyable & Escapable,
        Index.Output == Void,
        Index.Failure: Swift.Error & Coder.Codable,
        Index.Failure.Coder.Input == ArraySlice<Byte>,
        Index.Failure.Coder.Output == Index.Failure,
        Index.Failure.Coder.Buffer == [Byte]
    {
        client(
            Domain.self,
            Index.self,
            transport: transport,
            output: { _ throws(HTTP.Route.Error) in () },
            failure: { response throws(HTTP.Route.Error) in try response.decoded(as: Index.Failure.self) }
        )
    }

    public static func client<Domain: HTTP.Routable, Index: Operation.Member, Failure: Swift.Error>(
        _: Domain.Type,
        _: Index.Type,
        transport: HTTP.Client<Failure>
    ) -> Client::Client<Index.Input, Void, Either<Either<Failure, HTTP.Route.Error>, Never>>
    where
        Domain.Router.Output: ~Copyable,
        Index.Coproduct == Domain.Router.Output,
        Index.Case == Optic<Domain.Router.Output, Domain.Router.Output, Operation.Application<Index>, Operation.Application<Index>>.Case,
        Index.Input: Copyable & Escapable,
        Index.Output == Void,
        Index.Failure == Never
    {
        client(
            Domain.self,
            Index.self,
            transport: transport,
            output: { _ throws(HTTP.Route.Error) in () },
            failure: { _ throws(HTTP.Route.Error) in throw .mismatch }
        )
    }

    static func client<Domain: HTTP.Routable, Index: Operation.Member, Failure: Swift.Error>(
        _: Domain.Type,
        _: Index.Type,
        transport: HTTP.Client<Failure>,
        output: @escaping (HTTP.Route.Response) throws(HTTP.Route.Error) -> Index.Output,
        failure: @escaping (HTTP.Route.Response) throws(HTTP.Route.Error) -> Index.Failure
    ) -> Client::Client<Index.Input, Index.Output, Either<Either<Failure, HTTP.Route.Error>, Index.Failure>>
    where
        Domain.Router.Output: ~Copyable,
        Index.Coproduct == Domain.Router.Output,
        Index.Case == Optic<Domain.Router.Output, Domain.Router.Output, Operation.Application<Index>, Operation.Application<Index>>.Case,
        Index.Input: Copyable & Escapable,
        Index.Output: Copyable & Escapable,
        Index.Failure: Swift.Error
    {
        let prism = Domain.Router.Output.cases[keyPath: Index.keyPath].prism
        return .init(
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

                if received.status.isSuccessful {
                    do throws(HTTP.Route.Error) {
                        return try output(received)
                    } catch {
                        throw .left(.right(error))
                    }
                }

                if received.status.isClientError {
                    let refusal: Index.Failure
                    do throws(HTTP.Route.Error) {
                        refusal = try failure(received)
                    } catch {
                        throw .left(.right(error))
                    }
                    throw .right(refusal)
                }

                throw .left(.right(.mismatch))
            }
        )
    }
}
