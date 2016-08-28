import Foundation
import GCDWebServer

class WebServer : NSObject {
    private let webserver : GCDWebServer!
    private let portNumber : UInt
    
    private let handlers = [ ["method":"POST","path":"/simulator/launch", "handler":LaunchRequestHandler()],
        ["method":"POST","path":"/simulator/kill", "handler" : KillRequestHandler()],
    ["method":"PUT","path":"/control", "handler" : ControlHandler()]]
    
    init(port: UInt) {
        webserver = GCDWebServer()
        portNumber = port
        super.init()
        self.addHandlers()
    }
    
    private func addHandlers()  {
        for handlerMapping in handlers {
            let method = handlerMapping["method"] as! String
            let path = handlerMapping["path"] as! String
            let handler = handlerMapping["handler"] as! RequestHandler
            self.addHandler(method, path: path, handler: handler)
        }
    }
    
    private func addHandler(method: String, path: String, handler: RequestHandler) {
        webserver.addHandlerForMethod(method, path: path, requestClass: GCDWebServerDataRequest.self) { (request, completionCallback) -> Void in
            self .handleRequest(request, handler: handler, completionBlock: completionCallback)
        }
    }
    
    private func handleRequest(request : GCDWebServerRequest, handler : RequestHandler, completionBlock : GCDWebServerCompletionBlock) {
        
        let dataRequest = request as! GCDWebServerDataRequest
        do {
            if let map = try NSJSONSerialization.JSONObjectWithData(dataRequest.data, options: NSJSONReadingOptions()) as? Map {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let response = handler.handle(map)
                    var dataResponse  : GCDWebServerDataResponse
                    if response.isLeft() {
                        do {
                        dataResponse = try GCDWebServerDataResponse(data: NSJSONSerialization.dataWithJSONObject(response.left!, options: NSJSONWritingOptions()) , contentType: "application/json")
                        dataResponse.statusCode = 200;
                        } catch let error as NSError {
                            dataResponse = self.dataResponseForError(error)
                        }
                    } else {
                        dataResponse = self.dataResponseForError(response.right!)
                    }
                    completionBlock(dataResponse)
                })
            }
        } catch let error as NSError {
            completionBlock(self.dataResponseForError(error))
        }
    }
    
    private func dataResponseForError(error :NSError) -> GCDWebServerDataResponse {
        let errorResponse = ["success":"false","error":error.localizedDescription]
        
        do {
        let dataResponse =  try GCDWebServerDataResponse(data: NSJSONSerialization.dataWithJSONObject(errorResponse, options: NSJSONWritingOptions()) , contentType: "application/json")
            dataResponse.statusCode = 500
            return dataResponse
        } catch {
            return GCDWebServerDataResponse()
        }
    }
    
    func startServer()  {
        webserver.startWithPort(portNumber, bonjourName: "FBSimulatorClient")
    }
    
}


