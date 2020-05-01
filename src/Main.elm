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
    Html.main_
        []
        [ Html.section [ Attribute.class "hero is-fullheight" ]
            [ Html.div [ Attribute.class "hero-head" ]
                [ Html.div [ Attribute.class "container has-text-centered " ]
                    [ Html.p [] [ Html.h1 [ Attribute.class "has-text-primary is-logo is-hidden-touch is-family-secondary" ] [ Html.text "Farwind" ] ]
                    , Html.p [] [ Html.h1 [ Attribute.class "has-text-primary is-mobile-logo is-hidden-desktop is-family-secondary" ] [ Html.text "Farwind" ] ]
                    ]
                ]
            , Html.div [ Attribute.class "hero-body " ]
                [ Html.div [ Attribute.class "container has-text-centered " ]
                    [ Html.section [ Attribute.class "columns" ]
                        [ Html.div
                            [ Attribute.class
                                "column is-half-desktop is-offset-one-quarter-desktop is-three-fifths-tablet is-offset-one-fifth-tablet"
                            ]
                            [ Html.figure [ Attribute.class "image is-3by2" ]
                                [ Html.img
                                    [ Attribute.attribute "sizes" "(max-width: 1520px) 100vw, 1520px"
                                    , Attribute.attribute "srcset" <|
                                        String.join ","
                                            [ "/images/boat_utgpat_c_scale,w_190.webp 190w,"
                                            , "/images/boat_utgpat_c_scale,w_762.webp 762w,"
                                            , "/images/boat_utgpat_c_scale,w_1162.webp 1162w,"
                                            , "/images/boat_utgpat_c_scale,w_1520.webp 1520w,"
                                            ]
                                    , Attribute.src "/images/boat_utgpat_c_scale,w_1520.webp"
                                    , Attribute.alt "An eighty meters autonomous catamaran"
                                    ]
                                    []
                                ]
                            ]
                        ]
                    , Html.p [ Attribute.class "content " ]
                        [ Html.h3 [ Attribute.class "subtitle" ] [ Html.text "We convert far-offshore wind energy into clean renewable fuel." ]
                        , Html.a [ Attribute.class "button  ", Attribute.href "mailto:contact@farwind-energy.com" ] [ Html.text "Contact" ]
                        ]
                    ]
                ]
            , Html.div [ Attribute.class "hero-foot " ]
                []
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
