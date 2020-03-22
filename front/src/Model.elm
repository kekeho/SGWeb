module Model exposing (..)


import Browser.Navigation as Nav
import Url
import Url.Parser exposing ((</>))

import User.UserPageModel as UserPageModel
import User.UserPage as UserPage
import User.LoginModel as LoginModel
import User.LoginPage  as LoginPage
import Post.EditorModel as EditorModel

-- ROOT MODEL

type alias RootModel =
    { key : Nav.Key
    , url : Url.Url
    , userPage : UserPageModel.UserPageModel
    , login : LoginModel.LoginUserModel
    , editorPage : EditorModel.EditorModel
    , route : Route
    }


type Route
    = IndexPage
    | UserPage String
    | LoginPage
    | EditorPage


routeParser : Url.Parser.Parser (Route -> a) a
routeParser =
    Url.Parser.oneOf
        [ Url.Parser.map IndexPage Url.Parser.top
        , Url.Parser.map UserPage (Url.Parser.s "user" </> Url.Parser.string)
        , Url.Parser.map LoginPage (Url.Parser.s "login")
        , Url.Parser.map EditorPage (Url.Parser.s "post")
        ]
