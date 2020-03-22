module Post.Model exposing (..)

import Time

import User.UserPageModel exposing (..)

type alias PostModel =
    { id : String
    , author : User
    , content : String
    , tags : List Tag
    , like : Int
    , date_published : Time.Posix
    , result_stdout : String
    , result_stderr : String
    , result_image_url : String
    }


type alias Tag =
    String
