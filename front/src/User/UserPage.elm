module User.UserPage exposing (..)

-- import Data exposing (..)

import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode

import User.UserPageModel exposing (..)

-- UPDATE


type UserMsg
    = GotUserInfo (Result Http.Error User)


update : UserMsg -> UserPageModel -> Nav.Key -> ( UserPageModel, Cmd UserMsg )
update msg model navKey =
    case msg of
        GotUserInfo result ->
            case result of
                Ok user ->
                    ( Just user
                    , Cmd.none
                    )
                
                Err error ->
                    ( Nothing
                    , Cmd.none
                    )



-- VIEWS


view : UserPageModel -> Html UserMsg
view model =
    div [ ]
        [ text "user view" ]


-- CMD

getUserInfo : String -> Cmd UserMsg
getUserInfo username =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "Accept" "application/json"
            , Http.header "Content-Type" "application/json"
            ]
        , url = "/api/users/info/" ++ username
        , expect = Http.expectJson GotUserInfo userDecoder
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }



-- FUNCTIONS

userDecoder : Decode.Decoder User
userDecoder =
    Decode.map3 User
        (Decode.field "username" Decode.string)
        (Decode.field "display_name" Decode.string)
        (Decode.field "profile" Decode.string)
