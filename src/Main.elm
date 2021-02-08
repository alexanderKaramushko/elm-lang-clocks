module Main exposing (..)

import Browser
import Html exposing (Html, div, button, text)
import Html.Events exposing (onClick)
import Time
import Task
import String

-- MAIN

main: Program () Model Msg
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

-- MODEL


type alias Model =
  {
    zone: Time.Zone
  , time: Time.Posix
  , paused: Bool
  }

init : () -> (Model, Cmd Msg)
init _ =
  ( Model Time.utc (Time.millisToPosix 0) False
  , Task.perform AdjustTimeZone Time.here
  )



-- UPDATE


type Msg =
  Tick Time.Posix
  | AdjustTimeZone Time.Zone
  | Pause
  | Start

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tick posixTime ->
      ({ model | time = posixTime }
      , Cmd.none
      )

    AdjustTimeZone timeZone ->
      ({ model | zone = timeZone }
      , Cmd.none
      )

    Pause ->
      ({ model | paused = True }
      , Cmd.none
      )

    Start ->
      ({ model | paused = False }
      , Cmd.none
      )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  if model.paused then
    Sub.none
  else
    Time.every 1000 Tick
  



-- VIEW


view : Model -> Html Msg
view model =
  let
    hours = String.fromInt (Time.toHour model.zone model.time)
    minutes = String.fromInt (Time.toMinute model.zone model.time)
    seconds = String.fromInt (Time.toSecond model.zone model.time)
  in
  div [] [
    div [] [ text (hours ++ ":" ++ minutes ++ ":" ++ seconds) ]
    , viewControl model
  ]

viewControl : Model -> Html Msg
viewControl model =
  if model.paused then
    button [ onClick Start ] [ text "Start" ]
  else
    button [ onClick Pause ] [ text "Pause" ]
