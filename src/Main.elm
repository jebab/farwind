module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (..)
import Html.Attributes as Attribute exposing (..)



-- ---------------------------
-- MODEL
-- ---------------------------


type alias Model =
    { counter : Int
    , serverMessage : String
    }


init : Int -> ( Model, Cmd Msg )
init flags =
    ( { counter = flags, serverMessage = "" }, Cmd.none )



-- ---------------------------
-- UPDATE
-- ---------------------------


type Msg
    = Noop


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        Noop ->
            ( model, Cmd.none )



-- ---------------------------
-- VIEW
-- ---------------------------


view : Model -> Html Msg
view _ =
    Html.div
        []
        [ Html.section [ Attribute.class "section" ]
            [ Html.div [ Attribute.class "container has-text-centered" ]
                [ Html.img
                    [ Attribute.src "/images/tilded-logo.webp"
                    , Attribute.alt "Farwind : We convert far-offshore wind energy into clean renewable fuel"
                    , Attribute.height 56
                    ]
                    []
                ]
            ]
        , Html.section [ Attribute.class "section" ]
            [ Html.div [ Attribute.class "container has-text-centered" ]
                [ Html.img [ Attribute.src "/images/boat.webp", Attribute.alt "80m Autonomous Catamaran" ] []
                ]
            ]
        , Html.div
            [ Attribute.class "hero" ]
            [ Html.div [ Attribute.class "container has-text-centered" ]
                [ Html.p [ Attribute.class "content" ]
                    [ Html.h3 [ Attribute.class "subtitle " ] [ Html.text "We convert far-offshore wind energy into clean renewable fuel." ]
                    , Html.a [ Attribute.class "button", Attribute.href "mailto:contact@farwind-energy.com" ] [ Html.text "Contact" ]
                    ]
                ]
            ]
        ]



-- ---------------------------
-- MAIN
-- ---------------------------


main : Program Int Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view =
            \m ->
                { title = "Farwind energy"
                , body = [ view m ]
                }
        , subscriptions = \_ -> Sub.none
        }
