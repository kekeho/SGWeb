module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Url.Parser
import Url.Parser exposing ((</>))

import Data exposing (..)
import User exposing (userView, loginView, login)


-- MAIN

main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


init : () -> Url.Url -> Nav.Key -> (Model, Cmd Msg)
init flags url key =
    ( 
        { key = key
        , url = url
        , route = Data.IndexPage
        , user = 
            { token = Nothing
            , login = { userName = "", password = "", error = Nothing }
            }
        }
    , Cmd.none )



-- UPDATE

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )
                
                Browser.External href ->
                    ( model, Nav.load href )
        
        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )

        LoginInputUsername username ->
            let
                user_ = model.user
                login_ = model.user.login

                nextLogin = { login_ | userName = username }
                nextUser = { user_ | login = nextLogin }
            in
                ( { model | user = nextUser }
                , Cmd.none
                )
        
        LoginInputPassword password ->
            let
                user_ = model.user
                login_ = model.user.login

                nextLogin = { login_ | password = password }
                nextUser = { user_ | login = nextLogin }
            in
                ( { model | user = nextUser }
                , Cmd.none
                )

        LoginSubmit ->
            ( model, login model.user.login )
        
        GotJwtToken result ->
            case result of
                Ok token ->
                    let
                        user_ = model.user
                        login_ = model.user.login
                        clearedLogin = { login_ | userName = "", password = "", error = Nothing }
                        newUser = { user_ | token = Just token, login = clearedLogin }
                    in
                        ( { model | user = newUser }
                        , Nav.pushUrl model.key "/"
                        )
                
                Err error ->
                    let
                        user_ = model.user
                        login_ = model.user.login
                        nextLogin = { login_ | error = Just error }
                        nextUser = { user_ | login = nextLogin }
                    in
                        ( { model | user = nextUser }
                        , Cmd.none
                        )




-- VIEW

view : Model -> Browser.Document Msg
view model =
    case Url.Parser.parse routeParser model.url of
        Just (Data.UserPage user) ->
            { title = "Users"
            , body =
                [ userView model ]
            }
        
        Just (Data.LoginPage) ->
            { title = "login"
            , body =
                [ loginView model ]
            }
    
        Just (Data.IndexPage) ->
            { title = "URL Interceptor"
            , body =
                [ text "The Current URL is: "
                , b [] [ text (Url.toString model.url) ]
                , a [ href "/user/hogefuga" ] [ text "hogefuga" ]
                , a [ href "/login" ] [ text "login" ]
                ]
            }
        
        Nothing ->
            { title = "404"
            , body =
                [ text "404" ]
            }


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- FUNCTIONS

routeParser : Url.Parser.Parser (Data.Route -> a) a
routeParser =
    Url.Parser.oneOf
        [ Url.Parser.map Data.IndexPage Url.Parser.top
        , Url.Parser.map Data.UserPage (Url.Parser.s "user" </> Url.Parser.string)
        , Url.Parser.map Data.LoginPage (Url.Parser.s "login")
        ]
