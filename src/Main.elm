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
        [ Attribute.class "hero is-fullheight" ]
        [ Html.div [ Attribute.class "hero-head" ]
            [ Html.div [ Attribute.class "container" ]
                [ Html.nav [ Attribute.class "navbar is-light" ]
                    [ Html.div [ Attribute.class "navabar-brand" ]
                        [ Html.a [ Attribute.class "navbar-item" ]
                            [ Html.img [ Attribute.src "/images/logo-2.png", Attribute.alt "logo" ] [] ]
                        ]
                    ]
                ]
            ]
        , Html.div [ Attribute.class "hero-body" ]
            [ Html.div [ Attribute.class "container has-text-centered" ]
                [ Html.img [ Attribute.src "/images/boat.png", Attribute.alt "logo" ] []
                , Html.p [ Attribute.class "content" ]
                    [ Html.h3 [ Attribute.class "subtitle " ] [ Html.text "We convert far-offshore wind energy into clean renewable fuel." ]
                    , Html.a [ Attribute.class "button", Attribute.href "mailto:contact@farwind-energy.com" ] [ Html.text "Contact" ]
                    ]
                ]
            ]
        , Html.div [ Attribute.class "hero-foot" ]
            [ Html.div [ Attribute.class "tabs" ]
                [ Html.div [ Attribute.class "container" ]
                    [ Html.ul []
                        [ Html.li []
                            []
                        ]
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
