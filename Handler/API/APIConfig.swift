//
//  ApiConfig.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 19/06/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit

struct APIConfig {
	static let rootURL = "http://handler-api-dev.eu-west-1.elasticbeanstalk.com/api/v1/"

}


struct Routes {
	static let messages = "/messages"
	static let oauth = "/oauth/authorize?client_id=9c3594fbb153aec6c70477a66229bca7786b7b7b5beb6b2c68c2997ab7ca1e4f&redirect_uri=handlerapp://oauth/success&response_type=token" //TODO fix
	

}