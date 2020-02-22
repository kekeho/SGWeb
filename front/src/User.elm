module User exposing (..)

-- import Data exposing (..)

import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Url.Parser as Url exposing ((</>))



-- MODEL


type alias UserModel =
    { token : Maybe String
    , login : Login
    }


type alias Login =
    { userName : String
    , password : String
    , error : Maybe Http.Error
    }



-- UPDATE


type UserMsg
    = LoginInputUsername String
    | LoginInputPassword String
    | LoginSubmit
    | GotJwtToken (Result Http.Error String)


update : UserMsg -> UserModel -> Nav.Key -> ( UserModel, Cmd UserMsg )
update msg model navKey =
    case msg of
        LoginInputUsername username ->
            let
                login_ =
                    model.login

                nextLogin =
                    { login_ | userName = username }
            in
            ( { model | login = nextLogin }
            , Cmd.none
            )

        LoginInputPassword password ->
            let
                login_ =
                    model.login

                nextLogin =
                    { login_ | password = password }
            in
            ( { model | login = nextLogin }
            , Cmd.none
            )

        LoginSubmit ->
            ( model, login model.login )

        GotJwtToken result ->
            case result of
                Ok token ->
                    let
                        login_ =
                            model.login

                        clearedLogin =
                            { login_ | userName = "", password = "", error = Nothing }
                    in
                    ( { model | login = clearedLogin }
                    , Nav.pushUrl navKey "/"
                    )

                Err error ->
                    let
                        login_ =
                            model.login

                        nextLogin =
                            { login_ | error = Just error }
                    in
                    ( { model | login = nextLogin }
                    , Cmd.none
                    )



-- VIEWS


userView : UserModel -> Html UserMsg
userView model =
    div []
        [ text "user view" ]


loginView : UserModel -> Html UserMsg
loginView model =
    div []
        [ h1 [] [ text "login" ]
        , div []
            [ input [ type_ "text", value model.login.userName, onInput LoginInputUsername ] []
            , input [ type_ "password", value model.login.password, onInput LoginInputPassword ] []
            , button [ onClick LoginSubmit ] []
            ]
        ]



-- CMD
-- Post username/password and get jwt token


login : Login -> Cmd UserMsg
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
