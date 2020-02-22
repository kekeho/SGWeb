module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Url.Parser exposing ((</>))
import User



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


type Route
    = IndexPage
    | UserPage String
    | LoginPage


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | UserMessage User.UserMsg


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , user : User.UserModel
    , route : Route
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { key = key
      , url = url
      , route = IndexPage
      , user =
            { token = Nothing
            , login = { userName = "", password = "", error = Nothing }
            }
      }
    , Cmd.none
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
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

        UserMessage userMsg ->
            let
                ( model_, cmd_ ) =
                    User.update userMsg model.user model.key
            in
            ( { model | user = model_ }
            , Cmd.map UserMessage cmd_
            )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    case Url.Parser.parse routeParser model.url of
        Just (UserPage user) ->
            { title = "Users"
            , body =
                [ User.userView model.user |> Html.map UserMessage ]
            }

        Just LoginPage ->
            { title = "login"
            , body =
                [ User.loginView model.user |> Html.map UserMessage ]
            }

        Just IndexPage ->
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


routeParser : Url.Parser.Parser (Route -> a) a
routeParser =
    Url.Parser.oneOf
        [ Url.Parser.map IndexPage Url.Parser.top
        , Url.Parser.map UserPage (Url.Parser.s "user" </> Url.Parser.string)
        , Url.Parser.map LoginPage (Url.Parser.s "login")
        ]
