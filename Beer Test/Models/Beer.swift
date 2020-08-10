/* 
Copyright (c) 2020 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
import ObjectMapper

struct Beer : Mappable {
	var id : Int?
	var name : String?
	var tagline : String?
	var first_brewed : String?
	var description : String?
	var image_url : String?
	var abv : Double?
	var ibu : Int?
	var target_fg : Int?
	var target_og : Int?
	var ebc : Int?
	var srm : Int?
	var ph : Double?
	var attenuation_level : Int?
	var volume : Volume?
	var boil_volume : Boil_volume?
	var method : Method?
	var ingredients : Ingredients?
	var food_pairing : [String]?
	var brewers_tips : String?
	var contributed_by : String?

	init?(map: Map) {

	}

	mutating func mapping(map: Map) {

		id <- map["id"]
		name <- map["name"]
		tagline <- map["tagline"]
		first_brewed <- map["first_brewed"]
		description <- map["description"]
		image_url <- map["image_url"]
		abv <- map["abv"]
		ibu <- map["ibu"]
		target_fg <- map["target_fg"]
		target_og <- map["target_og"]
		ebc <- map["ebc"]
		srm <- map["srm"]
		ph <- map["ph"]
		attenuation_level <- map["attenuation_level"]
		volume <- map["volume"]
		boil_volume <- map["boil_volume"]
		method <- map["method"]
		ingredients <- map["ingredients"]
		food_pairing <- map["food_pairing"]
		brewers_tips <- map["brewers_tips"]
		contributed_by <- map["contributed_by"]
	}

}
