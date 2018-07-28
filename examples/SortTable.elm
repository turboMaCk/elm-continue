module SortTable exposing (main)

import Continue exposing (Continue(Cont))
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { model = model
        , update = update
        , view = view
        }



-- SortTable


type SortTable a
    = SortTable (a -> a -> Order)


sortBy : (a -> comparable) -> SortTable a
sortBy get =
    SortTable <|
        \a b ->
            compare (get a) (get b)


sortRows : List a -> SortTable a -> Continue r (List a)
sortRows items (SortTable f) =
    Continue.return (List.sortWith f items)


forRow : (a -> b) -> Continue r (List a) -> Continue r (List b)
forRow f cont =
    Continue.map (List.map f) cont



-- Model


type alias Entry =
    { name : String, count : Int }


type alias Model =
    { fruits : List Entry
    , sortTable : SortTable Entry
    , showCountWarning : Bool
    }


model : Model
model =
    { fruits =
        [ { name = "Apple", count = 5 }
        , { name = "Orange", count = 4 }
        , { name = "Kiwi", count = 3 }
        ]
    , sortTable = sortBy .name
    , showCountWarning = False
    }



-- Update


type Msg
    = SetSort Bool (SortTable Entry)


update : Msg -> Model -> Model
update (SetSort show sortTable) m =
    { m | sortTable = sortTable, showCountWarning = show }



-- View


viewRow : Entry -> Continue (Html msg) Entry
viewRow entry =
    Cont <|
        \k ->
            Html.tr []
                [ Html.td [] [ Html.text entry.name ]
                , Html.td [] [ k entry ]
                ]


viewCount : Entry -> Html msg
viewCount { count } =
    if count <= 3 then
        Html.span [ Attrs.style [ ( "color", "red" ) ] ]
            [ Html.text <| "last " ++ toString count ++ " items" ]
    else
        Html.text <| toString count


viewTableHead : Html Msg
viewTableHead =
    let
        btn b get txt =
            Html.a [ Events.onClick <| SetSort b <| sortBy get ]
                [ Html.text txt ]
    in
    Html.tr []
        [ Html.th [] [ btn False .name "name" ]
        , Html.th [] [ btn True .count "count" ]
        ]


view : Model -> Html Msg
view model =
    let
        showCount =
            if model.showCountWarning then
                viewCount
            else
                Html.text << toString << .count
    in
    sortRows model.fruits model.sortTable
        |> Continue.map (List.map (Continue.run showCount << viewRow))
        |> Continue.run (\rows -> viewTableHead :: rows)
        |> Html.table []
