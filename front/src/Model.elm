module Model exposing (..)


import Browser.Navigation as Nav
import Url

import User

-- ROOT MODEL

type alias RootModel =
    { key : Nav.Key
    , url : Url.Url
    , user : User.UserPageModel
    , route : Route
    }


type Route
    = IndexPage
    | UserPage String
    | LoginPage