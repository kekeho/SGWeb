module User.LoginModel exposing (..)

import Http
import Json.Decode  as Decode


type alias LoginUserModel =
    { token : Maybe String
    , loginPage : LoginPage
    , authUser : Maybe AuthUser
    }


type alias LoginPage =
    { userName : String
    , password : String
    , error : Maybe Http.Error
    }


type alias AuthUser =
    { userName : String
    , displayName : String
    , firstName : String
    , lastName : String
    , email : String
    , profile : String
    }




-- JSON DECODER

jwtTokenDecoder : Decode.Decoder String
jwtTokenDecoder =
    Decode.field "token" Decode.string


authUserDecoder : Decode.Decoder AuthUser
authUserDecoder =
    Decode.map6 AuthUser
        (Decode.field "username" Decode.string)
        (Decode.field "display_name" Decode.string)
        (Decode.field "first_name" Decode.string)
        (Decode.field "last_name" Decode.string)
        (Decode.field "email" Decode.string)
        (Decode.field "profile" Decode.string)
