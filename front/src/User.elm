module User exposing (..)

-- import Data exposing (..)

import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode
import Json.Encode as Encode



-- MODEL


type alias UserPageModel =
    { token : Maybe String
    , login : Login
    , authUser : Maybe AuthUser
    , user : Maybe User
    }


type alias Login =
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


type alias User =
    { userName : String
    , displayName : String
    , profile : String
    }



-- UPDATE


type UserMsg
    = LoginInputUsername String
    | LoginInputPassword String
    | LoginSubmit
    | GotJwtToken (Result Http.Error String)
    | GotAuthUserInfo (Result Http.Error AuthUser)
    | GotUserInfo (Result Http.Error User)


update : UserMsg -> UserPageModel -> Nav.Key -> ( UserPageModel, Cmd UserMsg )
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
                    , Cmd.batch [ getAuthUserInfo token, Nav.pushUrl navKey "/" ]
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

        GotAuthUserInfo result ->
            case result of
                Ok user ->
                    ( { model | authUser = Just user }
                    , Cmd.none
                    )

                Err error ->
                    ( { model | authUser = Nothing }, Cmd.none )
        
        GotUserInfo result ->
            case result of
                Ok user ->
                    ( { model | user = Just user }
                    , Cmd.none
                    )
                
                Err error ->
                    ( { model | user = Nothing }
                    , Cmd.none
                    )



-- VIEWS


userView : UserPageModel -> Html UserMsg
userView model =
    div [ ]
        [ text "user view" ]


loginView : UserPageModel -> Html UserMsg
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


getAuthUserInfo : String -> Cmd UserMsg
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


getUserInfo : String -> Cmd UserMsg
getUserInfo username =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "Accept" "application/json"
            , Http.header "Content-Type" "application/json"
            ]
        , url = "/api/users/info?username=" ++ username
        , expect = Http.expectJson GotUserInfo userDecoder
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }



-- FUNCTIONS


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


userDecoder : Decode.Decoder User
userDecoder =
    Decode.map3 User
        (Decode.field "username" Decode.string)
        (Decode.field "display_name" Decode.string)
        (Decode.field "profile" Decode.string)
