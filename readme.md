# Beers Pairing

An iOS app that communicates with the BrewDog REST API (https://punkapi.com/documentation/v2), and recommends beers based on the food we’re having for lunch

User Stories:
  
  - As a user, I want to type in the food I am having now, so that I get a list of the best beers to pair with my food, sorted by increasing ABV (Alcohol By Volume, %).
Each beer entry should show, at least, the following information: beer name, tagline, description, image, and ABV (Alcohol By Volume, %).

  - As a user, I want to reverse the sorting of the list of beers, so I can see the highest ABV beers at the top.
Without launching another REST request, sort the current list of beers in reverse order (decreasing ABV).

  - As a user, if I type in any food that I have previously searched for, I want to immediately see the same search results as before, so I can decide which beer to have faster.
For every search request, check first if there is a search result on disk already, and return it if that's the case. If not, send a request to the REST API, and store the response on disk, in whatever format you prefer, so the next time the same search term is submitted, the app could retrieve the search result from disk.

### 3rd party libraries

* [Alamofire](https://github.com/Alamofire/Alamofire) - Because is the best library to perform http requests
* [ObjectMapper](https://github.com/tristanhimmelman/ObjectMapper) - It's a very big helper to deal with json serialization and mapping objects
* [Kingfisher](https://github.com/onevcat/Kingfisher) - A lightweight and powerful library for retrieving and caching image from the web

