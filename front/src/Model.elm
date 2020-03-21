module Model exposing (..)


import Browser.Navigation as Nav
import Url

import User.UserPageModel as UserPageModel
import User.UserPage as UserPage
import User.LoginModel as LoginModel
import User.LoginPage  as LoginPage

-- ROOT MODEL

type alias RootModel =
    { key : Nav.Key
    , url : Url.Url
    , userPage : UserPageModel.UserPageModel
    , login : LoginModel.LoginUserModel
    , route : Route
    }


type Route
    = IndexPage
    | UserPage String
    | LoginPage