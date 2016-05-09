//
//  Storyboards.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 07/05/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit

struct Storyboards {

	static var Intro : UIStoryboard {
		get {
			return UIStoryboard(name: "Intro", bundle: nil)
		}
	}

	static var Main : UIStoryboard {
		get {
			return UIStoryboard(name: "Main", bundle: nil)
		}
	}

	static var Compose : UIStoryboard {
		get {
			return UIStoryboard(name : "Compose", bundle: nil)
		}
	}

	static var Contacts : UIStoryboard {
		get {
			return UIStoryboard(name: "Contacts", bundle: nil)
		}
	}
}
