public import Either_Primitives
public import HTTP

extension Either: HTTP.Route.Error.Carrier
where Left: HTTP.Route.Error.Carrier, Right: HTTP.Route.Error.Carrier {

    public var route: HTTP.Route.Error {
        switch self {
        case .left(let left): left.route
        case .right(let right): right.route
        }
    }
}
