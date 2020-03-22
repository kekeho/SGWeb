module Post.EditorPage exposing (..)


import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)

import Post.EditorModel exposing (..)
import Post.Model exposing (..)


type Msg
    = ContentInput String
    | TagInput String
    | TestSubmit
    | GotTestResult (Result Http.Error TestResult)


update : Msg -> EditorModel -> String -> ( EditorModel, Cmd Msg )
update msg editorModel token =
    case msg of
        ContentInput content ->
            ( { editorModel | content = content}
            , Cmd.none )

        TagInput str ->
            let
                tags =
                    strToTags str
            in
            ( { editorModel | tags = tags}
            , Cmd.none )
        
        TestSubmit ->
            ( { editorModel | content = "", tags = [] }
            , testSubmit editorModel token
            )
        
        GotTestResult result ->
            case result of
                Err error ->
                    ( { editorModel | testResult = Nothing, testPostError = Just "HTTP ERROR!" }
                    , Cmd.none
                    )
                
                Ok testResult ->
                    ( { editorModel | testResult = Just testResult, testPostError = Nothing }
                    , Cmd.none
                    )


-- VIEW

view : EditorModel -> Html Msg
view editorModel =
    div [ class "container editor-page" ]
        [ div [ class "row" ]
            [ div [ class "col-md-6 editor"]
                [ editorView editorModel ]
            , div [ class "col-md-6 result" ]
                [ resultView editorModel]
            ]
        ]


editorView : EditorModel -> Html Msg
editorView editorModel =
    div [ class "row"]
        [ div [ class "col-12"]
            [ input [ class "text", onInput TagInput ] []
            ]
        , div [ class "col-12"]
            [ textarea [ class "editor", onInput ContentInput, value editorModel.content ] [] 
            ]
        , div [ class "col-12"]
            [ button [ onClick TestSubmit ] [ text "Test" ] ]
        ]


resultView : EditorModel -> Html Msg
resultView editorModel =
    let
        (output, status, content) =
            case editorModel.testResult of
                Just result ->
                    (result.result_output, Just result.result_status, result.content)    
                Nothing ->
                    ("", Nothing, "")
    in
    
    div [ class "row" ]
        [ div [ class "col-12" ]
            [ h2 [ ] [ text "Output" ]
            , div [ class "output" ]
                [ text output ]
            ]
        , div [ class "col-12" ]
            [ div [ class "status" ]
                [ case status of
                    Just val ->
                        text ("Status : " ++ String.fromInt val)
                    Nothing ->
                        text ""
                ]
            ]
        ]



-- FUNC

tagsToStr : List Tag -> String
tagsToStr tags =
    tagsToStrHelper (List.intersperse ", " tags)

tagsToStrHelper : List Tag -> String
tagsToStrHelper tags =
    case List.head tags of
        Nothing ->
            ""

        Just headTag ->
            headTag ++ tagsToStrHelper (List.drop 1 tags)


strToTags : String -> List Tag
strToTags str =
    String.split "," str
        |> List.map String.trimLeft
        |> List.map String.trimRight
        |> List.filter (\s -> not (String.isEmpty s))
        |> List.map (String.replace " " "")



-- CMD

testSubmit : EditorModel -> String -> Cmd Msg
testSubmit editorModel token =
    Http.request
        { method = "POST"
        , url = "/api/post/test/"
        , headers =
            [ Http.header "Authorization" ("JWT " ++ token)
            , Http.header "Accept" "application/json"
            , Http.header "Content-Type" "application/json"
            ]
        , body = Http.jsonBody (editorModelEncoder editorModel)
        , expect = Http.expectJson GotTestResult editorResultDecoder
        , timeout = Nothing
        , tracker = Nothing
        }
