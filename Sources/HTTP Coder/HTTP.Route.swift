public import Byte
public import HTTP
public import RFC_9110

extension HTTP {

    public enum Route {}
}

extension HTTP.Route {

    public typealias Request = HTTP.Message.Request<[Byte]>

    public typealias Response = HTTP.Message.Response<[Byte]>
}
