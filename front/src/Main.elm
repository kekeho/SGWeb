module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Url.Parser exposing ((</>))
import Task
import User

import Model exposing (..)



-- MAIN


main : Program () RootModel Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | UserMessage User.UserMsg


init : () -> Url.Url -> Nav.Key -> ( RootModel, Cmd Msg )
init flags url key =
    ( { key = key
      , url = url
      , route = IndexPage
      , user =
            { token = Nothing
            , login = { userName = "", password = "", error = Nothing }
            , authUser = Nothing
            , user = Nothing
            }
      }
    , Nav.pushUrl key (Url.toString url)
    )



-- UPDATE


update : Msg -> RootModel -> ( RootModel, Cmd Msg )
update msg rootModel =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( rootModel, Nav.pushUrl rootModel.key (Url.toString url) )

                Browser.External href ->
                    ( rootModel, Nav.load href )

        UrlChanged url ->
            ( { rootModel | url = url }
            , 
            
            case Url.Parser.parse routeParser rootModel.url of
                Just (UserPage username) ->
                    Cmd.map UserMessage (User.getUserInfo username)
                _ ->
                    Cmd.none
            )

        UserMessage userMsg ->
            let
                ( rootModel_, cmd_ ) =
                    User.update userMsg rootModel.user rootModel.key
            in
            ( { rootModel | user = rootModel_ }
            , Cmd.map UserMessage cmd_
            )



-- VIEW


view : RootModel -> Browser.Document Msg
view rootModel =
    case Url.Parser.parse routeParser rootModel.url of
        Just (UserPage user) ->
            { title = "Users"
            , body =
                [ User.userView rootModel.user |> Html.map UserMessage ]
            }

        Just LoginPage ->
            { title = "login"
            , body =
                [ User.loginView rootModel.user |> Html.map UserMessage ]
            }

        Just IndexPage ->
            { title = "URL Interceptor"
            , body =
                [ text "The Current URL is: "
                , b [] [ text (Url.toString rootModel.url) ]
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


subscriptions : RootModel -> Sub Msg
subscriptions rootModel =
    Sub.none



-- FUNCTIONS


routeParser : Url.Parser.Parser (Route -> a) a
routeParser =
    Url.Parser.oneOf
        [ Url.Parser.map IndexPage Url.Parser.top
        , Url.Parser.map UserPage (Url.Parser.s "user" </> Url.Parser.string)
        , Url.Parser.map LoginPage (Url.Parser.s "login")
        ]
