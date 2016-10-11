//
//  HandlerError.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 11/10/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON

public class HandlerError: NSObject, ErrorType {
	public var detail: String = ""
	public var status: Int = 0
	public var title: String = ""
	public var errorType: ErrorType?
	public var userInfo: [String: AnyObject]?
	public var displayMessage: String = "An unknown error occurred"

	override public var description: String {
		get {
			return "Domain: \(title), Status: \(status), Detail: \(detail), Message: \(displayMessage)"
		}
	}

	public convenience init(json: JSON, requestURL: String? = nil){
		self.init()
		detail = json["detail"].stringValue
		status = json["status"].intValue
		title = json["title"].stringValue
		userInfo = json["meta"].dictionaryObject
		displayMessage = json["displayMessage"].string ?? displayMessage
		if let url = requestURL {
			displayMessage += " " + url
		}
	}

	public convenience init(errorType: ErrorType, requestURL: String? = nil){
		self.init()
		self.title = errorType._domain
		self.status = errorType._code
		self.detail = "No detailed error description given"
		self.errorType = errorType
		self.userInfo = (errorType as NSError).userInfo as? [String: AnyObject]
		if let url = requestURL {
			displayMessage += " " + url
		}
	}

	public convenience init(title: String, status: Int, detail: String, displayMessage: String, userInfo: [String: AnyObject] = [String: AnyObject](), requestURL: String? = nil){
		self.init()
		self.title = title
		self.status = status
		self.detail = detail
		self.userInfo = userInfo
		self.displayMessage = displayMessage
		if let url = requestURL {
			self.displayMessage += " " + url
		}
	}

//	class func fromApiError(apiError: APIError, var displayMessage: String? = nil, requestURL: String? = nil) -> HandlerError {
//		if let url = requestURL, let _ = displayMessage {
//			displayMessage! += " " + url
//		}
//		switch apiError{
//		case .ConfigurationError(let errorType):
//			guard let error = errorType as? HandlerError else {
//				let error = HandlerError(errorType: errorType)
//				error.displayMessage = displayMessage ?? error.displayMessage
//				return error
//			}
//			return error
//		case .ConnectionError(let nserror):
//			return HandlerError(title: nserror.domain, status: nserror.code, detail: nserror.localizedDescription, displayMessage: JSON(nserror.userInfo)["displayMessage"].stringValue)
//		case .InvalidBaseURL(let url):
//			return HandlerError(title: "Invalid base URL", status: 100, detail: "The given base URL seems to be invalid", displayMessage:"An invalid URL was requested, please contact the developer about this", userInfo: ["URL": url])
//		case .InvalidResponseStructure(let object):
//			return HandlerError(title: "Invalid response structure", status: 100, detail: "The given response seems to be invalid", displayMessage:"The response from the server was invalid, please contact the developer about this", userInfo: ["response": object])
//		case .NotHTTPURLResponse(let response):
//			var dict = [String:AnyObject]()
//			if let response = response {
//				dict["response"] = response
//			}
//			return HandlerError(title: "Invalid response structure", status: 100, detail: "The given response seems to be invalid", displayMessage:"The response from the server was invalid, please contact the developer about this", userInfo: dict)
//		case .RequestBodySerializationError(let errorType):
//			guard let error = errorType as? HandlerError else {
//				let error = HandlerError(errorType: errorType)
//				error.displayMessage = displayMessage ?? error.displayMessage
//				return error
//			}
//			return error
//		case .ResponseBodyDeserializationError(let errorType):
//			guard let error = errorType as? HandlerError else {
//				let error = HandlerError(errorType: errorType)
//				error.displayMessage = displayMessage ?? error.displayMessage
//				return error
//			}
//			return error
//		case .UnacceptableStatusCode(_, let errorType):
//			guard let error = errorType as? HandlerError else {
//				let error = HandlerError(errorType: errorType)
//				error.displayMessage = displayMessage ?? error.displayMessage
//				return error
//			}
//			return error
//		}
//	}
}