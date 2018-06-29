module Main exposing (main)

import Html exposing (..)
import Http
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Ports exposing (ImagePortData, fileContentRead, fileSelected)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode exposing (Value)


type alias Model =
    { id : String
    , counter : Int
    , mImage : Maybe Image
    , api : String
    }


type alias Image =
    { contents : String
    , filename : String
    }


init : ( Model, Cmd Msg )
init =
    ( { id = "", counter = 0, mImage = Nothing, api = "http://localhost:8080" }, Cmd.none )



-- UPDATE


type Msg
    = SendIdentify
    | IdentifyCompleted (Result Http.Error Response)
    | ImageSelected
    | ImageRead ImagePortData
    | SetAPI String


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        SetAPI url ->
            ( { model | api = url }, Cmd.none )

        ImageSelected ->
            ( model
            , fileSelected "imageup"
            )

        ImageRead data ->
            let
                newImage =
                    { contents = data.contents
                    , filename = data.filename
                    }
            in
                ( { model | mImage = Just newImage }
                , Cmd.none
                )

        SendIdentify ->
            case model.mImage of
                Nothing ->
                    ( model, Cmd.none )

                Just img ->
                    ( model, Http.send IdentifyCompleted (identify model img.contents) )

        IdentifyCompleted (Err error) ->
            let
                _ =
                    Debug.log "Identify Request" error
            in
                ( model, Cmd.none )

        IdentifyCompleted (Ok res) ->
            ( { model | id = res.id }
            , Cmd.none
            )


type alias Response =
    { id : String }


decoder : Decoder Response
decoder =
    decode Response
        |> Json.Decode.Pipeline.required "id" Decode.string


identify : Model -> String -> Http.Request Response
identify model img =
    let
        req =
            Encode.object
                [ ( "img", Encode.string img ) ]

        body =
            Http.jsonBody req
    in
        decoder
            |> Http.post (model.api ++ "/") body



-- VIEW


view : Model -> Html Msg
view model =
    let
        imagePreview =
            case model.mImage of
                Just i ->
                    viewImagePreview i

                Nothing ->
                    text ""
    in
        div [ class "container" ]
            [ header []
                [ h1 [] [ text "PrivID Testbed" ] ]
            , p [] [ text "Upload an image of a person to get an ID." ]
            , div []
                [ input
                    [ type_ "text"
                    , onInput SetAPI
                    , placeholder "API URL"
                    ]
                    [ text (toString model.api) ]
                ]
            , div [ class "imageWrapper" ]
                [ input
                    [ type_ "file"
                    , id "imageup"
                    , on "change"
                        (Decode.succeed ImageSelected)
                    ]
                    []
                , imagePreview
                ]
            , button
                [ class "pure-button pure-button-primary"
                , onClick SendIdentify
                ]
                [ text "Identify" ]
            , p [] [ text ("ID: " ++ (toString model.id)) ]
            ]


viewImagePreview : Image -> Html Msg
viewImagePreview image =
    img
        [ src image.contents
        , title image.filename
        ]
        []


subscriptions : Model -> Sub Msg
subscriptions model =
    fileContentRead ImageRead


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
