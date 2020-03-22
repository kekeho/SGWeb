module Post.EditorModel exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode

import Post.Model exposing (Tag)

type alias EditorModel =
    { content : String
    , tags : List Tag
    , testResult : Maybe TestResult
    , testPostError : Maybe String
    }

type alias TestResult =
    { content : String
    , result_output : String
    , result_status : Int
    , result_image : Maybe String -- Base64
    }


-- JSON DECODER/Encoder

editorResultDecoder : Decode.Decoder TestResult
editorResultDecoder =
    Decode.map4 TestResult
        (Decode.field "content" Decode.string)
        (Decode.field "result_output" Decode.string)
        (Decode.field "result_status" Decode.int)
        (Decode.maybe (Decode.field "result_image" Decode.string))


editorModelEncoder : EditorModel -> Encode.Value
editorModelEncoder editorModel =
    Encode.object
        [ ("content", Encode.string editorModel.content)
        , ("tags", Encode.list Encode.string editorModel.tags)
        ]
