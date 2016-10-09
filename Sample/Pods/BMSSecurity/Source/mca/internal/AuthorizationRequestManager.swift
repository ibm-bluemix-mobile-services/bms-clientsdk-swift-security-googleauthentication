/*
*     Copyright 2015 IBM Corp.
*     Licensed under the Apache License, Version 2.0 (the "License");
*     you may not use this file except in compliance with the License.
*     You may obtain a copy of the License at
*     http://www.apache.org/licenses/LICENSE-2.0
*     Unless required by applicable law or agreed to in writing, software
*     distributed under the License is distributed on an "AS IS" BASIS,
*     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*     See the License for the specific language governing permissions and
*     limitations under the License.
*/

import Foundation
import BMSCore
import BMSAnalyticsAPI

#if swift(>=3.0)
    
// MARK: - AuthorizationRequestManager (Swift 3)

public class AuthorizationRequestManager {
    
    //MARK constants
    //MARK vars (private)
    
    var requestPath : String?
    var requestOptions : RequestOptions?
    
    var answers: [String : AnyObject]?
    
    public static var overrideServerHost: String?     
    
    private static let logger = Logger.logger(name: BMSSecurityConstants.authorizationRequestManagerLoggerName)
    
    internal var defaultCompletionHandler : BMSCompletionHandler
    
    internal init(completionHandler: BMSCompletionHandler?) {
        
        if let handler = completionHandler {
            defaultCompletionHandler = handler
        } else {
            defaultCompletionHandler = {(response: Response?, error: Error?) in
                AuthorizationRequestManager.logger.debug(message: "ResponseListener is not specified. Defaulting to empty listener.")
            }
            
        }
        
        AuthorizationRequestManager.logger.debug(message: "AuthorizationRequestAgent is initialized.")
    }
    
    internal func send(_ path:String , options:RequestOptions) throws {
        var rootUrl:String = ""
        var computedPath:String = path
        
        if path.hasPrefix(MCAAuthorizationManager.HTTP_SCHEME) && path.characters.index(of: ":") != nil {
            let url = URL(string: path)
            if let pathTemp = url?.path {
                rootUrl = (path as NSString).replacingOccurrences(of: pathTemp, with: "")
                computedPath = pathTemp
            }
            else {
                rootUrl = ""
            }
        }
        else {
            var bluemixRegion = MCAAuthorizationManager.sharedInstance.bluemixRegion
            if(bluemixRegion == nil) {
                bluemixRegion = BMSClient.sharedInstance.bluemixRegion
            }
    
            var MCATenantId = MCAAuthorizationManager.sharedInstance.tenantId
            if(MCATenantId == nil) {
                MCATenantId = BMSClient.sharedInstance.bluemixAppGUID
            }
    
            //path is relative
            var serverHost = MCAAuthorizationManager.defaultProtocol
            + "://"
            + BMSSecurityConstants.AUTH_SERVER_NAME
            + bluemixRegion!
    
            if let overrideServerHost = AuthorizationRequestManager.overrideServerHost {
                serverHost = overrideServerHost
            }
    
            rootUrl = serverHost
            + "/"
            + BMSSecurityConstants.AUTH_SERVER_NAME
            + "/"
            + BMSSecurityConstants.AUTH_PATH
            + MCATenantId!
        }
        try sendInternal(rootUrl, path: computedPath, options: options)
    
    }
    
    internal static func isAuthorizationRequired(_ response: Response?) -> Bool {
        if let unwrappedResponse = response, let unWrappedheaders = unwrappedResponse.headers,
            let authHeader = unWrappedheaders[caseInsensitive : BMSSecurityConstants.WWW_AUTHENTICATE_HEADER] as? String,
            authHeader == BMSSecurityConstants.AUTHENTICATE_HEADER_VALUE {
            return true
        }
        return false
    }

    
    internal func sendInternal(_ rootUrl:String, path:String, options:RequestOptions?) throws {
        self.requestOptions = options != nil ? options : RequestOptions()
        
        requestPath = Utils.concatenateUrls(rootUrl, path: path)
        
        var request = AuthorizationRequest(url:requestPath!, method:self.requestOptions!.requestMethod)
        
        request.timeout = requestOptions!.timeout != 0 ? requestOptions!.timeout : BMSClient.sharedInstance.requestTimeout
        
        
        if let unwrappedHeaders = options?.headers {
            request.addHeaders(unwrappedHeaders)
        }
        
        if let unwrappedAnswers = answers {
            let ans = try Utils.JSONStringify(unwrappedAnswers as AnyObject)
            let authorizationHeaderValue = "\(BMSSecurityConstants.BEARER) \(ans)"
            request.addHeader(BMSSecurityConstants.AUTHORIZATION_HEADER, val: authorizationHeaderValue)
        }
        
        let callback: BMSCompletionHandler = { (response: Response?, error: Error?) in
            
            func isRedirect(_ response: Response?) -> Bool{
                return 300..<399 ~= (response?.statusCode)!
            }
            
            func processResponseWrapper(_ response:Response?, isFailure:Bool) {
                let isRedirectRequired:Bool = isRedirect(response)
                if isFailure || !isRedirectRequired {
                    self.processResponse(response)
                }
                else {
                    do {
                        try self.processRedirectResponse(response!)
                    } catch (let thrownError){
                        let nsError = NSError(domain: BMSSecurityConstants.BMSSecurityErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey:"\(thrownError)"])
                        AuthorizationRequestManager.logger.error(message: String(describing: error))
                        self.defaultCompletionHandler(response, nsError)
                    }
                }
            }
            
            if error != nil {
                if (AuthorizationRequestManager.isAuthorizationRequired(response)) {
                    processResponseWrapper(response,isFailure: true)
                } else {
                    self.defaultCompletionHandler(response, error)
                    return
                }
            }
            
            let successResponse = response?.isSuccessful
            if successResponse == true || isRedirect(response) {
                //process onSuccess
                processResponseWrapper(response!, isFailure: false)
            }
            else {
                //process onFailure
                if (AuthorizationRequestManager.isAuthorizationRequired(response)) {
                    processResponseWrapper(response,isFailure: true)
                } else {
                    self.defaultCompletionHandler(response, error)
                    return
                }
            }
        }
        
        if let method = options?.requestMethod, method == HttpMethod.GET{
            request.queryParameters = options?.parameters
            request.send(callback)
        } else {
            request.sendWithCompletionHandler((options?.parameters)!, callback: callback)
        }
    }
    
    /**
     Processes authentication failures.
     
     - parameter jsonFailures: Collection of authentication failures
     */
    internal func processFailures(_ jsonFailures: [String:AnyObject]?) {
        
        guard let failures = jsonFailures else {
            return
        }
        
        let mcaAuthManager = MCAAuthorizationManager.sharedInstance
        for (realm, challenge) in failures {
            if let handler = mcaAuthManager.challengeHandlerForRealm(realm), let unWrappedChallenge = challenge as? [String : AnyObject] {
                handler.handleFailure(unWrappedChallenge)
            }
            else {
                AuthorizationRequestManager.logger.error(message: "Challenge handler for realm: \(realm), is not found")
            }
        }
    }
    
    internal func requestFailed(_ info:[String:AnyObject]?) {
        AuthorizationRequestManager.logger.error(message: "BaseRequest failed with info: \(info == nil ? "info is nil" : String(describing: info))")
        defaultCompletionHandler(nil, NSError(domain: BMSSecurityConstants.BMSSecurityErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey:"\(info)"]))
    }
    
    
    internal func processSuccesses(_ jsonSuccesses: [String:AnyObject]?) {
        
        guard let successes = jsonSuccesses else {
            return
        }
        
        let mcaAuthManager = MCAAuthorizationManager.sharedInstance
        for (realm, challenge) in successes {
            if let handler = mcaAuthManager.challengeHandlerForRealm(realm), let unWrappedChallenge = challenge as? [String : AnyObject] {
                handler.handleSuccess(unWrappedChallenge)
            }
            else {
                AuthorizationRequestManager.logger.error(message: "Challenge handler for realm: \(realm), is not found")
            }
        }
    }
    
    enum ResponseError: Error {
        case noLocation(String)
        case challengeHandlerNotFound(String)
    }
    
    internal func processResponse(_ response: Response?) {
        // at this point a server response should contain a secure JSON with challenges
        do {
            let responseJson = try Utils.extractSecureJson(response)
            if let challenges = responseJson[caseInsensitive : BMSSecurityConstants.CHALLENGES_VALUE_NAME] as? [String: AnyObject]{
                try startHandleChallenges(challenges, response: response!)
            } else {
                defaultCompletionHandler(response, nil)
            }
        } catch (let error){
            if let responseError = error as? ResponseError {
                defaultCompletionHandler(response, NSError(domain: BMSSecurityConstants.BMSSecurityErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey:"\(responseError)"]))
            } else {
                defaultCompletionHandler(response, nil)
            }
        }
    }
    
    internal func startHandleChallenges(_ jsonChallenges: [String: AnyObject], response: Response) throws {
        let challenges = Array(jsonChallenges.keys)
        
        if (AuthorizationRequestManager.isAuthorizationRequired(response)) {
            setExpectedAnswers(challenges)
        }
        let mcaAuthManager = MCAAuthorizationManager.sharedInstance
        for (realm, challenge) in jsonChallenges {
            if let handler = mcaAuthManager.challengeHandlerForRealm(realm), let unWrappedChallenge = challenge as? [String : AnyObject] {
                handler.handleChallenge(self, challenge:  unWrappedChallenge)
            }
            else {
                throw ResponseError.challengeHandlerNotFound("Challenge handler for realm: \(realm), is not found")
            }
        }
    }
    
    internal func setExpectedAnswers(_ realms:[String]) {
        guard answers != nil else {
            return
        }
        
        for realm in realms {
            answers![realm] = "" as AnyObject?
        }
    }
    
    internal func removeExpectedAnswer(_ realm:String) {
        if answers != nil {
            answers!.removeValue(forKey: realm)
        }
        
        if isAnswersFilled() {
            do {
                try resendRequest()
            } catch {
                AuthorizationRequestManager.logger.error(message: "removeExpectedAnswer failed with error : \(error)")
            }
        }
        
    }
    
    /**
     Adds an expected challenge answer to collection of answers.
     
     - parameter answer: Answer to add.
     - parameter realm:  Authentication realm for the answer.
     */
    internal func submitAnswer(_ answer:[String:AnyObject]?, realm:String) {
        guard let unwrappedAnswer = answer else {
            AuthorizationRequestManager.logger.error(message: "Cannot submit nil answer for realm \(realm)")
            return
        }
        
        if answers == nil {
            answers = [String:AnyObject]()
        }
        
        answers![realm] = unwrappedAnswer as AnyObject?
        if isAnswersFilled() {
            do {
                try resendRequest()
            } catch {
                AuthorizationRequestManager.logger.error(message: "submitAnswer failed with error : \(error)")
            }
        }
    }
    
    internal func isAnswersFilled() -> Bool {
        guard answers != nil else {
            return true
        }
        
        for (_, value) in answers! {
            if let sVal:String = value as? String, sVal == "" {
                return false
            }
        }
        
        return true
    }
    
    internal func resendRequest() throws {
        try send(requestPath!, options: requestOptions!)
    }
    
    internal func processRedirectResponse(_ response:Response) throws {
        
        func getLocationString(_ locationHeader:AnyObject?) -> String? {
            guard locationHeader != nil else {
                return nil
            }
			
			if let locationHeader = locationHeader as? [String]{
				return locationHeader[0]
			} else if let locationHeader = locationHeader as? String{
				return locationHeader
			}
			
            return nil
        }
        
        guard let location = getLocationString(response.headers?[caseInsensitive : BMSSecurityConstants.LOCATION_HEADER_NAME] as AnyObject?) else {
            throw ResponseError.noLocation("Redirect response does not contain 'Location' header.")
        }
        
        // the redirect location url should contain "wl_result" value in query parameters.
        guard let url:URL = URL(string: location) else {
            throw ResponseError.noLocation("Could not create URL from 'Location' header.")
        }
        
        let query =  url.query
        
        if let q = query, q.lowercased().contains(BMSSecurityConstants.WL_RESULT.lowercased()) {
            if let result = Utils.getParameterValueFromQuery(query, paramName: BMSSecurityConstants.WL_RESULT, caseSensitive: false) {
                let jsonResult = try Utils.parseJsonStringtoDictionary(result)
                // process failures if any
                
                if let jsonFailures = jsonResult[caseInsensitive : BMSSecurityConstants.AUTH_FAILURE_VALUE_NAME] {
                    processFailures(jsonFailures as? [String : AnyObject])
                }
                
                if let jsonSuccesses = jsonResult[caseInsensitive : BMSSecurityConstants.AUTH_SUCCESS_VALUE_NAME] {
                    processSuccesses(jsonSuccesses as? [String: AnyObject])
                }
            }
        }
        
        defaultCompletionHandler(response, nil)
    }
}

#else
    
public class AuthorizationRequestManager {
    
    //MARK constants
    //MARK vars (private)
    
    var requestPath : String?
    var requestOptions : RequestOptions?
    
    var answers: [String : AnyObject]?
    
    public static var overrideServerHost: String?
    
    private static let logger = Logger.logger(name: BMSSecurityConstants.authorizationRequestManagerLoggerName)
    
    internal var defaultCompletionHandler : BMSCompletionHandler
    
    internal init(completionHandler: BMSCompletionHandler?) {
        
        if let handler = completionHandler {
            defaultCompletionHandler = handler
        } else {
            defaultCompletionHandler = {(response: Response?, error: NSError?) in
                AuthorizationRequestManager.logger.debug(message: "ResponseListener is not specified. Defaulting to empty listener.")
            }
            
        }
        
        AuthorizationRequestManager.logger.debug(message: "AuthorizationRequestAgent is initialized.")
    }
    
    internal func send(path:String , options:RequestOptions) throws {
        var rootUrl:String = ""
        var computedPath:String = path
        
        if path.hasPrefix(MCAAuthorizationManager.HTTP_SCHEME) && path.characters.indexOf(":") != nil {
            let url = NSURL(string: path)
            if let pathTemp = url?.path {
                rootUrl = (path as NSString).stringByReplacingOccurrencesOfString(pathTemp, withString: "")
                computedPath = pathTemp
            }
            else {
                rootUrl = ""
            }
        }
        else {
            var bluemixRegion = MCAAuthorizationManager.sharedInstance.bluemixRegion
            if(bluemixRegion == nil) {
                bluemixRegion = BMSClient.sharedInstance.bluemixRegion
            }
            
            var MCATenantId = MCAAuthorizationManager.sharedInstance.tenantId
            if(MCATenantId == nil) {
                MCATenantId = BMSClient.sharedInstance.bluemixAppGUID
            }
            
            //path is relative
            var serverHost = MCAAuthorizationManager.defaultProtocol
                + "://"
                + BMSSecurityConstants.AUTH_SERVER_NAME
                + bluemixRegion!
            
            if let overrideServerHost = AuthorizationRequestManager.overrideServerHost {
                serverHost = overrideServerHost
            }
            
            rootUrl = serverHost
                + "/"
                + BMSSecurityConstants.AUTH_SERVER_NAME
                + "/"
                + BMSSecurityConstants.AUTH_PATH
                + MCATenantId!
        }
        try sendInternal(rootUrl, path: computedPath, options: options)
        
    }
    
    internal static func isAuthorizationRequired(response: Response?) -> Bool {
        if let unwrappedResponse = response, unWrappedheaders = unwrappedResponse.headers,
            authHeader = unWrappedheaders[caseInsensitive : BMSSecurityConstants.WWW_AUTHENTICATE_HEADER] as? String
            where authHeader == BMSSecurityConstants.AUTHENTICATE_HEADER_VALUE {
            return true
        }
        return false
    }
    
    
    internal func sendInternal(rootUrl:String, path:String, options:RequestOptions?) throws {
        self.requestOptions = options != nil ? options : RequestOptions()
        
        requestPath = Utils.concatenateUrls(rootUrl, path: path)
        
        var request = AuthorizationRequest(url:requestPath!, method:self.requestOptions!.requestMethod)
        
        request.timeout = requestOptions!.timeout != 0 ? requestOptions!.timeout : BMSClient.sharedInstance.requestTimeout
        
        
        if let unwrappedHeaders = options?.headers {
            request.addHeaders(unwrappedHeaders)
        }
        
        if let unwrappedAnswers = answers {
            let ans = try Utils.JSONStringify(unwrappedAnswers)
            let authorizationHeaderValue = "\(BMSSecurityConstants.BEARER) \(ans)"
            request.addHeader(BMSSecurityConstants.AUTHORIZATION_HEADER, val: authorizationHeaderValue)
        }
        
        let callback: BMSCompletionHandler = { (response: Response?, error: NSError?) in
            
            func isRedirect(response: Response?) -> Bool{
                return 300..<399 ~= (response?.statusCode)!
            }
            
            func processResponseWrapper(response:Response?, isFailure:Bool) {
                let isRedirect:Bool = isRedirect(response)
                if isFailure || !isRedirect {
                    self.processResponse(response)
                }
                else {
                    do {
                        try self.processRedirectResponse(response!)
                    } catch (let thrownError){
                        let nsError = NSError(domain: BMSSecurityConstants.BMSSecurityErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey:"\(thrownError)"])
                        AuthorizationRequestManager.logger.error(message: String(error))
                        self.defaultCompletionHandler(response, nsError)
                    }
                }
            }
            if error != nil {
                if (AuthorizationRequestManager.isAuthorizationRequired(response)) {
                    processResponseWrapper(response,isFailure: true)
                } else {
                    self.defaultCompletionHandler(response, error)
                    return
                }
            }
            
            let successResponse = response?.isSuccessful
            if successResponse == true || isRedirect(response) {
                //process onSuccess
                processResponseWrapper(response!, isFailure: false)
            }
            else {
                //process onFailure
                if (AuthorizationRequestManager.isAuthorizationRequired(response)) {
                    processResponseWrapper(response,isFailure: true)
                } else {
                    self.defaultCompletionHandler(response, error)
                    return
                }
            }
        }
        
        if let method = options?.requestMethod where method == HttpMethod.GET{
            request.queryParameters = options?.parameters
            request.send(callback)
        } else {
            request.sendWithCompletionHandler((options?.parameters)!, callback: callback)
        }
    }
    
    /**
     Processes authentication failures.
     
     - parameter jsonFailures: Collection of authentication failures
     */
    internal func processFailures(jsonFailures: [String:AnyObject]?) {
        
        guard let failures = jsonFailures else {
            return
        }
        
        let mcaAuthManager = MCAAuthorizationManager.sharedInstance
        for (realm, challenge) in failures {
            if let handler = mcaAuthManager.challengeHandlerForRealm(realm), unWrappedChallenge = challenge as? [String : AnyObject] {
                handler.handleFailure(unWrappedChallenge)
            }
            else {
                AuthorizationRequestManager.logger.error(message: "Challenge handler for realm: \(realm), is not found")
            }
        }
    }
    
    internal func requestFailed(info:[String:AnyObject]?) {
        AuthorizationRequestManager.logger.error(message: "BaseRequest failed with info: \(info == nil ? "info is nil" : String(info))")
        defaultCompletionHandler(nil, NSError(domain: BMSSecurityConstants.BMSSecurityErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey:"\(info)"]))
    }
    
    
    internal func processSuccesses(jsonSuccesses: [String:AnyObject]?) {
        
        guard let successes = jsonSuccesses else {
            return
        }
        
        let mcaAuthManager = MCAAuthorizationManager.sharedInstance
        for (realm, challenge) in successes {
            if let handler = mcaAuthManager.challengeHandlerForRealm(realm), unWrappedChallenge = challenge as? [String : AnyObject]{
                handler.handleSuccess(unWrappedChallenge)
            }
            else {
                AuthorizationRequestManager.logger.error(message: "Challenge handler for realm: \(realm), is not found")
            }
        }
    }
    
    enum ResponseError: ErrorType {
        case NoLocation(String)
        case ChallengeHandlerNotFound(String)
    }
    
    internal func processResponse(response: Response?) {
        // at this point a server response should contain a secure JSON with challenges
        do {
            let responseJson = try Utils.extractSecureJson(response)
            if let challenges = responseJson[caseInsensitive : BMSSecurityConstants.CHALLENGES_VALUE_NAME] as? [String: AnyObject]{
                try startHandleChallenges(challenges, response: response!)
            } else {
                defaultCompletionHandler(response, nil)
            }
        } catch (let error){
            if let responseError = error as? ResponseError {
                defaultCompletionHandler(response, NSError(domain: BMSSecurityConstants.BMSSecurityErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey:"\(responseError)"]))
            } else {
                defaultCompletionHandler(response, nil)
            }
        }
    }
    
    internal func startHandleChallenges(jsonChallenges: [String: AnyObject], response: Response) throws {
        let challenges = Array(jsonChallenges.keys)
        
        if (AuthorizationRequestManager.isAuthorizationRequired(response)) {
            setExpectedAnswers(challenges)
        }
        let mcaAuthManager = MCAAuthorizationManager.sharedInstance
        for (realm, challenge) in jsonChallenges {
            if let handler = mcaAuthManager.challengeHandlerForRealm(realm), unWrappedChallenge = challenge as? [String : AnyObject] {
                handler.handleChallenge(self, challenge:  unWrappedChallenge)
            }
            else {
                throw ResponseError.ChallengeHandlerNotFound("Challenge handler for realm: \(realm), is not found")
            }
        }
    }
    
    internal func setExpectedAnswers(realms:[String]) {
        guard answers != nil else {
            return
        }
        
        for realm in realms {
            answers![realm] = ""
        }
    }
    
    internal func removeExpectedAnswer(realm:String) {
        if answers != nil {
            answers!.removeValueForKey(realm)
        }
        
        if isAnswersFilled() {
            do {
                try resendRequest()
            } catch {
                AuthorizationRequestManager.logger.error(message: "removeExpectedAnswer failed with error : \(error)")
            }
        }
        
    }
    
    /**
     Adds an expected challenge answer to collection of answers.
     
     - parameter answer: Answer to add.
     - parameter realm:  Authentication realm for the answer.
     */
    internal func submitAnswer(answer:[String:AnyObject]?, realm:String) {
        guard let unwrappedAnswer = answer else {
            AuthorizationRequestManager.logger.error(message: "Cannot submit nil answer for realm \(realm)")
            return
        }
        
        if answers == nil {
            answers = [String:AnyObject]()
        }
        
        answers![realm] = unwrappedAnswer
        if isAnswersFilled() {
            do {
                try resendRequest()
            } catch {
                AuthorizationRequestManager.logger.error(message: "submitAnswer failed with error : \(error)")
            }
        }
    }
    
    internal func isAnswersFilled() -> Bool {
        guard answers != nil else {
            return true
        }
        
        for (_, value) in answers! {
            if let sVal:String = value as? String where sVal == "" {
                return false
            }
        }
        
        return true
    }
    
    internal func resendRequest() throws {
        try send(requestPath!, options: requestOptions!)
    }
    
    internal func processRedirectResponse(response:Response) throws {
        
        func getLocationString(locationHeader:AnyObject?) -> String? {
            guard locationHeader != nil else {
                return nil
            }
            
            if let locationHeader = locationHeader as? [String]{
                return locationHeader[0]
            } else if let locationHeader = locationHeader as? String{
                return locationHeader
            }
            
            return nil
        }
        
        guard let location = getLocationString(response.headers?[caseInsensitive : BMSSecurityConstants.LOCATION_HEADER_NAME]) else {
            throw ResponseError.NoLocation("Redirect response does not contain 'Location' header.")
        }
        
        // the redirect location url should contain "wl_result" value in query parameters.
        guard let url:NSURL = NSURL(string: location)! else {
            throw ResponseError.NoLocation("Could not create URL from 'Location' header.")
        }
        
        let query =  url.query
        
        if let q = query where q.lowercaseString.containsString(BMSSecurityConstants.WL_RESULT.lowercaseString) {
            if let result = Utils.getParameterValueFromQuery(query, paramName: BMSSecurityConstants.WL_RESULT, caseSensitive: false) {
                let jsonResult = try Utils.parseJsonStringtoDictionary(result)
                // process failures if any
                
                if let jsonFailures = jsonResult[caseInsensitive : BMSSecurityConstants.AUTH_FAILURE_VALUE_NAME] {
                    processFailures(jsonFailures as? [String : AnyObject])
                }
                
                if let jsonSuccesses = jsonResult[caseInsensitive : BMSSecurityConstants.AUTH_SUCCESS_VALUE_NAME] {
                    processSuccesses(jsonSuccesses as? [String: AnyObject])
                }
            }
        }
        
        defaultCompletionHandler(response, nil)
    }
}

#endif
