//
//  Punkapi.swift
//  Beer Test
//
//  Created by Alfredo Rinaudo on 09/03/2020.
//  Copyright © 2020 co.soprasteria. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

// UTILIZO ALAMOFIRE PORQUE CONSIDERO QUE ES LA BIBLIOTECA MAS COMPLETA PARA GESTIONAR PETICIONES HTTP https://github.com/Alamofire/Alamofire
// ADEMAS SE COMPLEMENTA MUY BIEN CON OBJECTMAPPER QUE ES, A MI ENTENDER, UNA DE LAS MEJORES BIBLIOTECAS PARA MAPPING DE OBJETOS JSON https://github.com/tristanhimmelman/ObjectMapper
// ADEMAS USO KINGFISHER PARA REQUEST Y CACHEO DE IMAGENES https://github.com/onevcat/Kingfisher

//protocol ApiSessionManager {
//    func request(_ urlRequest: URLRequestConvertible) -> DataRequest
//}
//
//extension SessionManager: ApiSessionManager {}

class ApiClient {
    
    let rootApi = "https://api.punkapi.com/v2"
    let allBeers = "/beers"
    let randomBeer = "/random"
    
    private let alamoManager: SessionManager
    init(manager: SessionManager = SessionManager.default) {
        self.alamoManager = manager
    }
    
    func getMeRandomBeer(completion: ((DefaultDataResponse) -> Void)!) {
        var urlRequest = URLRequest(url: URL(string: rootApi + allBeers + randomBeer)!)
        urlRequest.httpMethod = HTTPMethod.get.rawValue
        urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
        // AQUÍ NECESITO QUE LA RANDOM BEER DEVUELTA SEA SIEMPRE DISTINTA POR LO QUE IGNORO LA CACHE
        
        self.alamoManager.request(urlRequest).response { (response) in
            completion(response)
        }
    }
    
    func getAllBeers(byFood: String, fromPage: Int, perPage: Int, completion: ((DefaultDataResponse) -> Void)!) {
        var parameters: String = "?page=\(String(format: "%d", fromPage))&per_page=\(String(format: "%d", perPage))"
        if (byFood != "") {
            let food = byFood.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "_")
            // REEMPLAZO LOS ESPACIOS INTERNOS POR UNDERSCORES COMO ESPECIFICADO EN LAS APIs
            parameters += "&food=\(food)"
        }
        if let allowedParams = (parameters.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)) {
            parameters = allowedParams
        }
        
        // GUARDO LA REQUEST EN EL CASO FALLE FOR FALTA DE CONECTIVIDAD
        // PARA LUEGO PODER SER RELANZADA, UNA VEZ VUELTA LA CONEXION, DESDE EL VIEW CONTROLLER PRINCIPAL
        UserDefaultsManager().storeRequest(request: "\(rootApi)\(allBeers)\(parameters)")
        
        var urlRequest = URLRequest(url: URL(string: "\(rootApi)\(allBeers)\(parameters)")!)
        urlRequest.httpMethod = "GET"
        urlRequest.cachePolicy = .returnCacheDataElseLoad
        // CON ESTA POLITICA DE CACHING NO HAY NECESIDAD DE GUARDAR NINGUN RESULTADO EN UNA DB INTERNA O USER DEFAULTS
        // SI EL RESULTADO EXISTE EN CACHE, DEVOLVERA ESE SIN IMPORTAR LA FECHA DE EXPIRACION DE LA MISMA
        // DE LO CONTRARIO DEVOLVERA DESDE LA FUENTE DE ORÍGEN
        // CONSIDERO QUE ES SUFICIENTE PARA CUMPLIR CON LA TERCERA USER STORY DE LOS REQUERIMIENTOS
        // DE LO CONTRARIO LO QUE HABRÍA QUE HACER ES GUARDAR EN USER DEFAULTS UN DICTIONARY [[String: Any]]
        // DONDE EL KEY SEA EL TERMINO BUSCANDO Y EL VALUE SEA EL RESPONSEDATA SERIALIZADO.
        // DE ESTA FORMA, AL VOLVER A BUSCAR UN MISMO TERMINO PRIMERO SE HARÍA LA BÚSQUEDA EN USERDEFAULTS
        // Y LUEGO, DE NO EXISTIR EL DATO, SE EJECUTARIA EL REQUEST.
        
        self.alamoManager.request(urlRequest).response { (response) in
            completion(response)
        }
    }
    
    func getBeerDetails(beerId: Int, completion: ((DefaultDataResponse) -> Void)!) {
        var urlRequest = URLRequest(url: URL(string: rootApi + allBeers + "/\(beerId)")!)
        urlRequest.httpMethod = HTTPMethod.get.rawValue
        urlRequest.cachePolicy = .returnCacheDataElseLoad
        // NUEVAMENTE, SI EL DATO YA ESTA EN CACHE DEVUELVO ESE, DE LO CONTRARIO EL DE ORIGEN
        
        self.alamoManager.request(urlRequest).response { (response) in
            completion(response)
        }
    }
    
    func retryRequestAfterFail(request: String, completion: ((DefaultDataResponse) -> Void)!) {
        var urlRequest = URLRequest(url: URL(string: request)!)
        urlRequest.httpMethod = HTTPMethod.get.rawValue
        urlRequest.cachePolicy = .returnCacheDataElseLoad
        
        self.alamoManager.request(urlRequest).response { (response) in
            completion(response)
        }
    }
    
    func responseHandler(response: DefaultDataResponse, completion: (([Beer]?, String?) -> Void)!) {
        if (response.error != nil) {
            completion(nil, response.error?.localizedDescription)
        } else {
            if let items = self.serializeResponse(responseData: response.data!) {
                completion(sortBeers(beers: items), nil)
            } else {
                completion(nil, "Couldn't serialize response")
            }
        }
    }
    
    func serializeResponse(responseData: Data) -> [Beer]? {
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: responseData, options: []) as? [[String: AnyObject]] {
                return Mapper<Beer>().mapArray(JSONArray: jsonArray)
            }
            return nil
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func sortBeers(beers: [Beer]) -> [Beer] {
        var sortedBeers = beers
        sortedBeers.sort { (beerA, beerB) -> Bool in
            if let beerAabv = beerA.abv, let beerBabv = beerB.abv {
                return beerAabv < beerBabv
            }
            return false
        }
        return sortedBeers
    }
}
