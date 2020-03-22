module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Url.Parser
import User.UserPageModel as UserPageModel
import User.UserPage as UserPage
import User.LoginModel as LoginModel
import User.LoginPage  as LoginPage
import Post.EditorPage as EditorPage

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
    | UserPageMsg UserPage.UserMsg
    | LoginPageMsg LoginPage.LoginMsg
    | EditorPageMsg EditorPage.Msg


init : () -> Url.Url -> Nav.Key -> ( RootModel, Cmd Msg )
init flags url key =
    ( { key = key
      , url = url
      , route = IndexPage
      , userPage =
            Nothing
      , login =
            { token = Nothing
            , loginPage = { userName = "", password = "", error = Nothing }
            , authUser = Nothing
            }
      , editorPage =
            { content = ""
            , tags = []
            , testResult = Nothing
            , testPostError = Nothing
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
                    Cmd.map UserPageMsg (UserPage.getUserInfo username)
                _ ->
                    Cmd.none
            )

        UserPageMsg subMsg ->
            let
                ( userModel_, cmd_ ) =
                    UserPage.update subMsg rootModel.userPage rootModel.key
            in
            ( { rootModel | userPage = userModel_ }
            , Cmd.map UserPageMsg cmd_
            )
        
        LoginPageMsg subMsg ->
            let
                ( loginModel_, cmd_ ) =
                    LoginPage.update subMsg rootModel.login rootModel.key
            in
            ( { rootModel | login = loginModel_ }
            , Cmd.map LoginPageMsg cmd_
            )
        
        EditorPageMsg subMsg ->
            case rootModel.login.token of
                Nothing ->
                    ( rootModel
                    , Nav.pushUrl rootModel.key "/login"
                    )
            
                Just token ->
                    let
                        ( editorModel_, cmd_ ) =
                            EditorPage.update subMsg rootModel.editorPage token
                    in
                    ( { rootModel | editorPage = editorModel_ }
                    , Cmd.map EditorPageMsg cmd_
                    )



-- VIEW


view : RootModel -> Browser.Document Msg
view rootModel =
    let
        pageView =
            case Url.Parser.parse routeParser rootModel.url of
                Just (UserPage user) ->
                    { title = "Users"
                    , body =
                        [ UserPage.view rootModel.userPage |> Html.map UserPageMsg ]
                    }

                Just LoginPage ->
                    { title = "login"
                    , body =
                        [ LoginPage.view rootModel.login |> Html.map LoginPageMsg ]
                    }

                Just IndexPage ->
                    { title = "URL Interceptor"
                    , body =
                        [ text "The Current URL is: "
                        , b [] [ text (Url.toString rootModel.url) ]
                        , a [ href "/user/hogefuga" ] [ text "hogefuga" ]
                        , a [ href "/login" ] [ text "login" ]
                        , a [ href "/post" ] [ text "post"]
                        ]
                    }
                
                Just EditorPage ->
                    { title = "POST"
                    , body =
                        [ EditorPage.view rootModel.editorPage |> Html.map EditorPageMsg ]
                    }

                Nothing ->
                    { title = "404"
                    , body =
                        [ text "404" ]
                    }
    in
    { title = "SGWeb | " ++ pageView.title
    , body =
        [ navbarView
        ] 
        ++ pageView.body
        ++ [ footerView ]
    }


navbarView : Html Msg
navbarView =
    nav [ class "navbar navbar-expand navbar-dark bg-dark" ]
        [ a [ class "navbar-brand", href "/"] [ text "SGWeb"]
        , ul [ class "navbar-nav mr-auto" ] []
        , ul [ class "navbar-nav" ]
            [ li [ class "nav-item" ]
                [ a [ class "nav-link", href "https://twitter.com/minyoruminyon/" ] 
                    [ text "Twitter Edition" ]
                ]
            ]
        ]


footerView : Html Msg
footerView =
    footer [ class "footer" ]
        [ div [ class "container" ]
            [ p [] [ text "by Hiroki Takemura (kekeho)"]
            , a [ href "https://twitter.com/k3k3h0" ] [ text "Twitter: @k3k3h0" ]
            , a [ href "https://github.com/kekeho" ] [ text "GitHub: @kekeho" ]
            ]
        ]


-- SUBSCRIPTIONS


subscriptions : RootModel -> Sub Msg
subscriptions rootModel =
    Sub.none
