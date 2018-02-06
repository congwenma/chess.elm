module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


-- import Component

import Components.Landscape exposing (renderGrid)
import Components.Piece exposing (renderPiece)


-- import Model

import Models.Piece exposing (Piece)
import Models.GameSet exposing (gameSet)
import Models.Coordinate exposing (Coordinate)
import Models.MoveForPiece exposing (..)


-- import Events

import Msg exposing (..)


-- import Support

import Debug exposing (..)
import Utils exposing (getFromMaybe)


-- APP


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { model = model
        , view = view
        , update = update
        }



-- MODEL


type alias Model =
    { selectedPiece : Maybe Piece
    , potentialMoves : List Coordinate
    , potentialKills : List Coordinate
    , pieces : List Piece
    }


model : Model
model =
    { selectedPiece = Nothing
    , potentialMoves = []
    , potentialKills = []
    , pieces = gameSet
    }



-- UPDATE: make moves


update : Msg -> Model -> Model
update msg model =
    case msg of
        SelectPiece piece ->
            { model
                | selectedPiece = Just piece
                , potentialMoves = getMoveForAnyPiece piece
                , potentialKills = getKillForAnyPiece piece
            }

        MovePiece coordinate ->
            let
                info =
                    Debug.log "MOVING PIECE" (toString coordinate)

                selectedPieceAfterMove =
                    Debug.log "SELECT PIECE AFTER MOVE" <|
                        case List.member coordinate model.potentialMoves of
                            True ->
                                case model.selectedPiece of
                                    Just selectedPiece ->
                                        Debug.log "SELECT PIECE" <| Just { selectedPiece | coordinate = coordinate }

                                    Nothing ->
                                        Nothing

                            False ->
                                model.selectedPiece

                afterMovePieces =
                    case selectedPieceAfterMove of
                        Just selectedPiece ->
                            model.pieces
                                |> List.indexedMap
                                    (\index piece ->
                                        let
                                            info =
                                                Debug.log "INDEXED MAP" ( piece, selectedPiece )
                                        in
                                            if piece.id == selectedPiece.id then
                                                selectedPiece
                                            else
                                                piece
                                    )

                        Nothing ->
                            model.pieces
            in
                { model | pieces = afterMovePieces }

        OtherSelectPiece ->
            model

        OtherMovePiece ->
            model



-- VIEW:


view : Model -> Html Msg
view model =
    let
        { pieces, potentialMoves, potentialKills, selectedPiece } =
            model
    in
        div [ class "m4 relative" ]
            [ div [ class "chess-board absolute" ]
                (renderGrid potentialMoves potentialKills)
            , div [ class "chess-pieces" ]
                (List.map (renderPiece selectedPiece) pieces)
            ]
