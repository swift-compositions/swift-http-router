public import HTTP

extension HTTP.Route.Error {

    /// A failure whose route meaning survives composition.
    ///
    /// Generic combinators nest their constituents' failures; a router
    /// speaks `HTTP.Route.Error`. A carrier projects a composed failure
    /// back onto the route taxonomy, so a branch built from leaves
    /// normalizes without use-site ceremony.
    public protocol Carrier: Swift.Error {

        var route: HTTP.Route.Error { get }
    }
}

extension HTTP.Route.Error: HTTP.Route.Error.Carrier {

    public var route: HTTP.Route.Error { self }
}
