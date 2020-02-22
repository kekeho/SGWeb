module User exposing (login, loginView, userView)

import Data exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Url.Parser as Url exposing ((</>))



-- VIEWS


userView : Model -> Html Msg
userView model =
    div []
        [ text "user view" ]


loginView model =
    div []
        [ h1 [] [ text "login" ]
        , div []
            [ input [ type_ "text", value model.user.login.userName, onInput LoginInputUsername ] []
            , input [ type_ "password", value model.user.login.password, onInput LoginInputPassword ] []
            , button [ onClick LoginSubmit ] []
            ]
        ]



-- CMD
-- Post username/password and get jwt token


login : Login -> Cmd Msg
login info =
    let
        jsonData : Encode.Value
        jsonData =
            Encode.object
                [ ( "username", Encode.string info.userName )
                , ( "password", Encode.string info.password )
                ]
    in
    Http.post
        { url = "/api/users/jwt-token/"
        , body = Http.jsonBody jsonData
        , expect = Http.expectJson GotJwtToken jwtTokenDecoder
        }



-- FUNCTIONS


jwtTokenDecoder : Decode.Decoder String
jwtTokenDecoder =
    Decode.field "token" Decode.string
