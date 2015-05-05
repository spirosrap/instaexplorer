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
        static let BaseURL : String = "http://api.themoviedb.org/3/"
        static let BaseURLSecure : String = "https://api.themoviedb.org/3/"

        static let ClientID: String = "bd0da3c658554f279ec783ddc9c5f71a"
        static let AuthorizationURL : String = "https://api.instagram.com/oauth/authorize/"
        static let RedirectURI: String = "instaplaces://auth/instagram"
        static let ClientSecret: String = "8673c1be285b486d993aa588086574f2"
        
    }
    
    // MARK: - Methods
    struct Methods {
        
        // MARK: Account
        static let Account = "account"
        static let AccountIDFavoriteMovies = "account/{id}/favorite/movies"
        static let AccountIDFavorite = "account/{id}/favorite"
        static let AccountIDWatchlistMovies = "account/{id}/watchlist/movies"
        static let AccountIDWatchlist = "account/{id}/watchlist"
        static let AccountIDRatedList = "account/{id}/rated/movies"
        
        // MARK: Authentication
        static let AuthenticationTokenNew = "authentication/token/new"
        static let AuthenticationSessionNew = "authentication/session/new"
        
        // MARK: Search
        static let SearchMovie = "search/movie"
        
        // MARK: Config
        static let Config = "configuration"
        
        // MARK: Movie
        static let MovieIDRating = "movie/{id}/rating"

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
        static let Favorite = "favorite"
        static let Watchlist = "watchlist"
        
        static let ratingValue = "value"
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
        
        // MARK: Config
        static let ConfigBaseImageURL = "base_url"
        static let ConfigSecureBaseImageURL = "secure_base_url"
        static let ConfigImages = "images"
        static let ConfigPosterSizes = "poster_sizes"
        static let ConfigProfileSizes = "profile_sizes"
        
        // MARK: Movies
        static let MovieID = "id"
        static let MovieTitle = "title"        
        static let MoviePosterPath = "poster_path"
        static let MovieReleaseDate = "release_date"
        static let MovieReleaseYear = "release_year"
        static let MovieResults = "results"
        static let MovieRating = "rating"
        
    }
    
    // MARK: - Poster Sizes
    struct PosterSizes {
//        
//        static let RowPoster = InstaClient.sharedInstance().config.posterSizes[2]
//        static let DetailPoster = InstaClient.sharedInstance().config.posterSizes[4]
        
    }

}