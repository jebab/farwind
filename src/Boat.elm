module Boat exposing (..)

import Svg exposing (..)
import Svg.Attributes as Attributes
import Svg.Coast as Coast
import Svg.Events exposing (onClick)


type alias Size =
    { width : Float
    , height : Float
    }


type alias Position =
    { x : Float
    , y : Float
    }


type alias Port =
    { position : Position
    , dockPosition : Position
    , size : Size
    , energy : Float
    , energyStorageCapacity : Float
    }


type alias Map =
    { size : Size
    , port_ : Port
    , wind : Wind
    , distanceBetweenPortAndWind : Int
    }


type Route
    = ToWind (List Position)
    | ToPort (List Position)


type alias Boat =
    { position : Position
    , energy : Float
    , windToEnergyRatio : Float
    , route : Route
    }


type Animation
    = Playing
    | Stopped


type alias Events msg =
    { toggleAnimation : msg
    }


type alias Model msg =
    { map : Map
    , boats : List Boat
    , animation : Animation
    , events : Events msg
    }


type alias Wind =
    { position : Position
    , force : Int
    }


initPort : Float -> Float -> Port
initPort fWidth fHeight =
    let
        position =
            Position (fWidth - 300) (fHeight * 0.1)

        dockPosition =
            Position (fWidth - 170) (fHeight * 0.1)
    in
    { position = position
    , dockPosition = dockPosition
    , size = Size (fWidth * 0.2) (fHeight * 0.1)
    , energy = 150
    , energyStorageCapacity = 1000
    }


init : Float -> Float -> msg -> Model msg
init width height toggleAnimation_ =
    let
        port_ =
            initPort width height

        wind =
            { position = Position (width * 0.1) (height * 0.9)
            , force = 50
            }

        map_ =
            { size = Size width height
            , port_ = port_
            , wind = wind
            , distanceBetweenPortAndWind = distance port_.position wind.position
            }
    in
    { boats =
        [ { position = port_.dockPosition
          , energy = 0.0
          , windToEnergyRatio = 0.002
          , route = windRoute map_
          }
        , { position = halfWayToWindPosition map_
          , energy = 25.0
          , windToEnergyRatio = 0.002
          , route = windRoute map_
          }
        , { position = halfWayToPortPosition map_
          , energy = 80.0
          , windToEnergyRatio = 0.002
          , route = portRoute map_
          }
        , { position = wind.position
          , energy = 60.0
          , windToEnergyRatio = 0.002
          , route = portRoute map_
          }
        ]
    , map = map_
    , animation = Playing
    , events = { toggleAnimation = toggleAnimation_ }
    }


positions : Route -> List Position
positions route_ =
    case route_ of
        ToWind positions_ ->
            positions_

        ToPort positions_ ->
            positions_


route : Route -> (List Position -> Route)
route route_ =
    case route_ of
        ToWind _ ->
            ToWind

        ToPort _ ->
            ToPort


windRoute : Map -> Route
windRoute map_ =
    ToWind [ halfWayToWindPosition map_, map_.wind.position ]


halfWayToWindPosition : Map -> Position
halfWayToWindPosition map_ =
    Position (map_.size.width * 0.65) (map_.size.height * 0.65)


portRoute : Map -> Route
portRoute map_ =
    ToPort
        [ halfWayToPortPosition map_
        , map_.port_.dockPosition
        ]


halfWayToPortPosition : Map -> Position
halfWayToPortPosition map_ =
    Position (map_.size.width * 0.35) (map_.size.height * 0.35)


updatePortEnergy : Float -> Port -> Port
updatePortEnergy energy port_ =
    { port_ | energy = min port_.energyStorageCapacity (port_.energy + energy) }


updatePort : Port -> Map -> Map
updatePort port_ map_ =
    { map_ | port_ = port_ }


update : Model msg -> Model msg
update model =
    let
        ( boats, energies ) =
            List.map (moveBoat model.map) model.boats
                |> List.unzip

        port_ =
            updatePortEnergy (List.foldl (+) 0 energies) model.map.port_
                |> dischargePort
    in
    { model
        | boats = boats
        , map =
            updatePort port_ model.map
    }


toggleAnimation : Model msg -> Model msg
toggleAnimation model =
    case model.animation of
        Playing ->
            { model | animation = Stopped }

        Stopped ->
            { model | animation = Playing }


isPlaying : Model msg -> Bool
isPlaying model =
    model.animation == Playing


goToWind : Map -> Route -> Route
goToWind map_ route_ =
    case route_ of
        ToPort _ ->
            windRoute map_

        _ ->
            route_


goToPort : Map -> Route -> Route
goToPort map_ route_ =
    case route_ of
        ToWind _ ->
            portRoute map_

        _ ->
            route_


moveBoat : Map -> Boat -> ( Boat, Float )
moveBoat map_ boat_ =
    if (boat_.energy > 1) && (distance boat_.position map_.port_.dockPosition < 5) then
        dischargeBoat boat_

    else if (distance boat_.position map_.port_.dockPosition < 5) && map_.port_.energy > 800 then
        ( boat_, 0 )

    else if boat_.energy < 60 then
        ( { boat_ | route = goToWind map_ boat_.route }
            |> move map_
        , 0
        )

    else
        ( { boat_ | route = goToPort map_ boat_.route }
            |> move map_
        , 0
        )


dischargeBoat : Boat -> ( Boat, Float )
dischargeBoat boat_ =
    ( { boat_
        | energy = boat_.energy - 2
      }
    , 2
    )


dischargePort : Port -> Port
dischargePort port_ =
    { port_
        | energy = port_.energy - 0.1
    }


windForce : Map -> Boat -> Int
windForce map_ boat_ =
    let
        distanceFromWind =
            distance map_.wind.position boat_.position

        windForceRelativeToDistance_ =
            toFloat (distanceFromWind * map_.wind.force)
                / toFloat map_.distanceBetweenPortAndWind
                |> round
    in
    map_.wind.force
        - windForceRelativeToDistance_


distance : Position -> Position -> Int
distance p1 p2 =
    ((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2)
        |> sqrt
        |> round


isAtPosition : Position -> Position -> Bool
isAtPosition p1 p2 =
    distance p1 p2 < 2


move : Map -> Boat -> Boat
move map_ boat_ =
    let
        ( to, next ) =
            case positions boat_.route of
                nextPoint :: next_ ->
                    ( nextPoint, next_ )

                [] ->
                    ( boat_.position, [] )

        route_ =
            if isAtPosition boat_.position to then
                route boat_.route next

            else
                boat_.route

        currentWind =
            windForce map_ boat_ |> toFloat
    in
    { boat_
        | position = newPosition boat_.position to
        , route = route_
        , energy = min 100 (boat_.energy + (boat_.windToEnergyRatio * currentWind))
    }


newPosition : Position -> Position -> Position
newPosition from to =
    let
        od =
            1

        ob =
            distance from to
    in
    if ob == 0 then
        to

    else
        let
            ocx =
                (od / toFloat ob) * (to.x - from.x)

            ocy =
                (od / toFloat ob) * (to.y - from.y)
        in
        { x = from.x + ocx
        , y = from.y + ocy
        }


positionToX : Position -> Attribute msg
positionToX position =
    position.x
        |> round
        |> String.fromInt
        |> Attributes.x


positionToY : Position -> Attribute msg
positionToY position =
    position.y
        |> round
        |> String.fromInt
        |> Attributes.y


map : Model msg -> Svg msg
map model =
    svg
        [ Attributes.width "100%"
        , Attributes.height "100%"
        , onClick model.events.toggleAnimation
        ]
    <|
        List.concat
            [ [ rect [ Attributes.width "100%", Attributes.height "100%", Attributes.fill "#cce2f6" ] []
              ]
            , [ Coast.coast (String.fromFloat model.map.port_.position.x) "-80" ]
            , docks model.map.port_
            , pauseButton model
            , List.map boat model.boats
            ]


docks : Port -> List (Svg msg)
docks port_ =
    let
        nbGreenBar =
            (port_.energy * 10)
                / port_.energyStorageCapacity

        percentCharge =
            (nbGreenBar
                - toFloat (floor nbGreenBar)
            )
                * 100

        xBase =
            port_.dockPosition.x + 115

        yBase =
            port_.size.height + 20 - (8 * nbGreenBar)

        drawEnergyBar num energyPercentage =
            svg []
                [ rect
                    [ Attributes.x (String.fromFloat xBase)
                    , Attributes.y (String.fromFloat (yBase + (8 * num)))
                    , Attributes.width "40"
                    , Attributes.height "6"
                    , Attributes.fill "red"
                    ]
                    []
                , rect
                    [ Attributes.x (String.fromFloat xBase)
                    , Attributes.y (String.fromFloat (yBase + (8 * num)))
                    , Attributes.width <| String.fromFloat ((40 * energyPercentage) / 100)
                    , Attributes.height "6"
                    , Attributes.fill "green"
                    ]
                    []
                ]

        greenBars nb =
            if nb <= 1 then
                [ drawEnergyBar nb percentCharge ]

            else
                drawEnergyBar nb 100 :: greenBars (nb - 1)
    in
    greenBars (toFloat (floor nbGreenBar))


pauseButton : Model msg -> List (Svg msg)
pauseButton model =
    case model.animation of
        Stopped ->
            let
                x1 =
                    round <| (model.map.size.width / 2) - 15

                y1 =
                    round <| (model.map.size.height / 2) - 25

                toPoint x y =
                    String.fromInt x ++ "," ++ String.fromInt y
            in
            [ polygon
                [ Attributes.points <|
                    toPoint x1 y1
                        ++ " "
                        ++ toPoint x1 (y1 + 50)
                        ++ " "
                        ++ toPoint (x1 + 40) (y1 + 25)
                , Attributes.fill "#ffffff"
                , Attributes.opacity "0.4"
                ]
                []
            ]

        Playing ->
            [ svg
                [ Attributes.x <| String.fromInt <| (round <| (model.map.size.width / 2) - 15)
                , Attributes.y <| String.fromInt <| (round (model.map.size.height / 2) - 25)
                ]
                [ rect [ Attributes.width "15", Attributes.height "50", Attributes.fill "#ffffff", Attributes.opacity "0.2" ] []
                , rect [ Attributes.x "25", Attributes.width "15", Attributes.height "50", Attributes.fill "#ffffff", Attributes.opacity "0.2" ] []
                ]
            ]


boat : Boat -> Svg msg
boat boat_ =
    let
        greenLevel =
            boat_.energy
                * 33
                / toFloat 100
                |> round
                |> String.fromInt
    in
    svg [ positionToX boat_.position, positionToY boat_.position, Attributes.width "80", Attributes.height "44" ]
        [ rect [ Attributes.width "100%", Attributes.height "100%", Attributes.fill "#cce2f6", Attributes.opacity "0.4" ] []

        -- Ship Hull
        , rect [ Attributes.x "8", Attributes.y "28", Attributes.width "64", Attributes.height "2", Attributes.fill "#ffffff" ] []
        , rect [ Attributes.x "10", Attributes.y "30", Attributes.width "60", Attributes.height "5", Attributes.fill "#fbc817" ] []

        -- Fletner rotors
        , rect [ Attributes.x "15", Attributes.y "27", Attributes.width "6", Attributes.height "1", Attributes.fill "#ffffff" ] []
        , rect [ Attributes.x "60", Attributes.y "27", Attributes.width "6", Attributes.height "1", Attributes.fill "#ffffff" ] []
        , rect [ Attributes.x "16", Attributes.y "7", Attributes.width "4", Attributes.height "21", Attributes.fill "#ffffff" ] []
        , rect [ Attributes.x "61", Attributes.y "7", Attributes.width "4", Attributes.height "21", Attributes.fill "#ffffff" ] []
        , rect [ Attributes.x "15", Attributes.y "6", Attributes.width "6", Attributes.height "1", Attributes.fill "#ffffff" ] []
        , rect [ Attributes.x "60", Attributes.y "6", Attributes.width "6", Attributes.height "1", Attributes.fill "#ffffff" ] []

        -- Battery level
        , rect [ Attributes.x "24", Attributes.y "22", Attributes.width "33", Attributes.height "6", Attributes.fill "red" ] []
        , rect [ Attributes.x "24", Attributes.y "22", Attributes.width greenLevel, Attributes.height "6", Attributes.fill "green" ] []
        ]
