module Data exposing (..)

import Browser
import Browser.Navigation as Nav
import Http
import Url



-- MODEL


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , user : User
    , route : Route
    }


type Route
    = IndexPage
    | UserPage String
    | LoginPage


type alias User =
    { token : Maybe String
    , login : Login
    }


type alias Login =
    { userName : String
    , password : String
    , error : Maybe Http.Error
    }



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
      --  User Login
    | LoginInputUsername String
    | LoginInputPassword String
    | LoginSubmit
    | GotJwtToken (Result Http.Error String)
