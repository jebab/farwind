module Main exposing (Model, Msg(..), init, main, update, view)

import Boat exposing (Map)
import Browser
import Browser.Dom as Dom exposing (Element)
import Browser.Events
import Html exposing (..)
import Html.Attributes as Attribute exposing (..)
import Task
import Time exposing (Posix)



-- ---------------------------
-- MODEL
-- ---------------------------


type alias ViewPort =
    { width : Int
    , height : Int
    }


type alias Model =
    { boats : Boat.Model Msg
    , boatsElement : Maybe Element
    , viewport : ViewPort
    }


init : ViewPort -> ( Model, Cmd Msg )
init viewport =
    ( { viewport = viewport
      , boats = Boat.init (toFloat viewport.width) (toFloat viewport.height) ToggleAnimation
      , boatsElement = Nothing
      }
    , Dom.getElement "boats-element"
        |> Task.attempt GotBoatsElements
    )



-- ---------------------------
-- UPDATE
-- ---------------------------


type Msg
    = GotNewSize ViewPort
    | MoveBoat Posix
    | ToggleAnimation
    | GotBoatsElements (Result Dom.Error Element)


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        GotBoatsElements boatsElement ->
            case boatsElement of
                Ok boatsElements_ ->
                    ( { model
                        | boatsElement = Just boatsElements_
                        , boats = Boat.init boatsElements_.element.width boatsElements_.element.height ToggleAnimation
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | boatsElement = Nothing }, Cmd.none )

        GotNewSize viewport ->
            ( { model
                | viewport = viewport
                , boats = Boat.init (toFloat viewport.width) (toFloat viewport.height) ToggleAnimation
              }
            , Dom.getElement "boats-element "
                |> Task.attempt GotBoatsElements
            )

        MoveBoat _ ->
            ( { model | boats = Boat.update model.boats }, Cmd.none )

        ToggleAnimation ->
            ( { model | boats = Boat.toggleAnimation model.boats }, Cmd.none )



-- ---------------------------
-- VIEW
-- ---------------------------


view : Model -> Html Msg
view model =
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
            ]
        , Html.section [ Attribute.class "hero is-fullheight" ]
            [ Html.div
                [ Attribute.class "hero-body has-fullheight-content"
                ]
                [ Html.div
                    [ Attribute.id "boats-element"
                    , Attribute.class "container has-text-centered is-fullheight-boats"
                    ]
                    [ Boat.map model.boats
                    ]
                ]
            ]
        ]



-- ---------------------------
-- MAIN
-- ---------------------------


main : Program ViewPort Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view =
            \m ->
                { title = "Farwind energy"
                , body = [ view m ]
                }
        , subscriptions = \m -> subscriptions m
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    if Boat.isPlaying model.boats then
        Sub.batch
            [ Browser.Events.onResize (\x y -> GotNewSize (ViewPort x y))
            , Browser.Events.onAnimationFrame MoveBoat
            ]

    else
        Browser.Events.onResize (\x y -> GotNewSize (ViewPort x y))
