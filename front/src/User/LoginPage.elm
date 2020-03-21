module User.LoginPage exposing (..)

import Http
import Browser.Navigation as Nav
import Json.Encode as Encode
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import User.LoginModel exposing (..)




type LoginMsg
    = LoginInputUsername String
    | LoginInputPassword String
    | LoginSubmit
    | GotJwtToken (Result Http.Error String)
    | GotAuthUserInfo (Result Http.Error AuthUser)


update : LoginMsg -> LoginUserModel -> Nav.Key -> ( LoginUserModel, Cmd LoginMsg )
update msg model navKey =
    case msg of
        LoginInputUsername username ->
            let
                login_ =
                    model.loginPage

                nextLogin =
                    { login_ | userName = username }
            in
            ( { model | loginPage = nextLogin }
            , Cmd.none
            )

        LoginInputPassword password ->
            let
                login_ =
                    model.loginPage

                nextLogin =
                    { login_ | password = password }
            in
            ( { model | loginPage = nextLogin }
            , Cmd.none
            )

        LoginSubmit ->
            ( model, login model.loginPage )

        GotJwtToken result ->
            case result of
                Ok token ->
                    let
                        login_ =
                            model.loginPage

                        clearedLogin =
                            { login_ | userName = "", password = "", error = Nothing }
                    in
                    ( { model | loginPage = clearedLogin }
                    , Cmd.batch [ getAuthUserInfo token, Nav.pushUrl navKey "/" ]
                    )

                Err error ->
                    let
                        login_ =
                            model.loginPage

                        nextLogin =
                            { login_ | error = Just error, password = "" }
                    in
                    ( { model | loginPage = nextLogin }
                    , Cmd.none
                    )

        GotAuthUserInfo result ->
            case result of
                Ok user ->
                    ( { model | authUser = Just user }
                    , Cmd.none
                    )

                Err error ->
                    ( { model | authUser = Nothing }, Cmd.none )


-- VIEWS

view : LoginUserModel -> Html LoginMsg
view model =
    div []
        [ h1 [] [ text "login" ]
        , div []
            [ input [ type_ "text", value model.loginPage.userName, onInput LoginInputUsername ] []
            , input [ type_ "password", value model.loginPage.password, onInput LoginInputPassword ] []
            , button [ onClick LoginSubmit ] [ text "login" ]
            ]
        ]



-- CMD

-- Post username/password and get jwt token
login : LoginPage -> Cmd LoginMsg
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


getAuthUserInfo : String -> Cmd LoginMsg
getAuthUserInfo token =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "Authorization" ("JWT " ++ token)
            , Http.header "Accept" "application/json"
            , Http.header "Content-Type" "application/json"
            ]
        , url = "/api/users/auth-userinfo/"
        , expect = Http.expectJson GotAuthUserInfo authUserDecoder
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }
