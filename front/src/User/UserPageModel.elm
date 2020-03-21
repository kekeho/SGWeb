module User.UserPageModel exposing (..)


type alias UserPageModel
    = Maybe User


type alias User =
    { userName : String
    , displayName : String
    , profile : String
    }
