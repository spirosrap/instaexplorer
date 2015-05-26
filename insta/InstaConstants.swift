//
//  TMDBConstants.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

extension InstaClient {
    
    // MARK: - Constants
    struct Constants {
        
        // MARK: API Key
        static let ApiKey : String = "066cb1a895d1a55b958a6317a5bba53a"
        
        // MARK: URLs
        static let BaseURLSecure : String = "https://api.instagram.com/v1/"

        static let ClientID: String = "bd0da3c658554f279ec783ddc9c5f71a"
        static let AuthorizationURL : String = "https://api.instagram.com/oauth/authorize/"
        static let RedirectURI: String = "instaplaces://auth/instagram"
        static let ClientSecret: String = "8673c1be285b486d993aa588086574f2"
        
    }
    
    // MARK: - Methods
    struct Methods {
        
        // MARK: Account
        static let Locations = "locations/search"
        static let MediaLocation = "locations/{id}/media/recent"
        static let MediaSearch = "media/search"
        static let TagsSearch = "tags/search"
        static let MediaTag = "tags/{tag-name}/media/recent"
        
    }
    
    struct LocationKeys{
        static let LocationID = "id"
    }

    // MARK: - URL Keys
    struct URLKeys {
        
        static let UserID = "id"
        
    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        
        static let ApiKey = "api_key"
        static let SessionID = "session_id"
        static let RequestToken = "request_token"
        static let Query = "query"
        
    }
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        
        static let MediaType = "media_type"
        static let MediaID = "media_id"
    }

    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
      
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        
        // MARK: Authorization
        static let RequestToken = "request_token"
        static let SessionID = "session_id"
        
        // MARK: Account
        static let UserID = "id"
        
    }
    

}