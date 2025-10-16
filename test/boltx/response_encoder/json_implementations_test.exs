defmodule Boltx.JsonImplementationsTest do
  use ExUnit.Case, async: true

  @moduletag :legacy

  alias Boltx.Types.{
    DateTimeWithTZOffset,
    TimeWithTZOffset,
    Duration,
    Point,
    Node,
    Relationship,
    UnboundRelationship,
    Path
  }

  defmodule TestStruct do
    defstruct [:id, :name]
  end

  test "Jason implementation OK" do
    # Decode both sides to compare data structures, not string representations
    # This handles key ordering differences between JSON encoders
    assert Jason.decode!(result(:jason)) == Jason.decode!(Jason.encode!(fixture()))
  end

  test "Poison implementation OK" do
    # Decode both sides to compare data structures, not string representations
    # This handles key ordering differences between JSON encoders
    assert Poison.decode!(result(:poison)) == Poison.decode!(Poison.encode!(fixture()))
  end

  defp fixture() do
    %Path{
      nodes: [
        %Node{
          id: 56,
          labels: [],
          properties: %{
            "boltx" => true,
            "name" => "Alice",
            geoloc: Point.create(:wgs_84, 45.006, 40.32332, 50),
            duration: %Duration{
              days: 0,
              hours: 0,
              minutes: 54,
              months: 12,
              nanoseconds: 0,
              seconds: 65,
              weeks: 0,
              years: 1
            }
          }
        },
        %Node{
          id: 57,
          labels: [],
          properties: %{
            "boltx" => true,
            "name" => "Bob",
            created: DateTimeWithTZOffset.create(~N[2019-03-05 12:34:56], 3600),
            user_strut: %TestStruct{id: 43, name: "Test"}
          }
        }
      ],
      relationships: [
        %UnboundRelationship{
          id: 58,
          properties: %{
            creation_time: TimeWithTZOffset.create(~T[12:34:56], 7200)
          },
          type: "KNOWS"
        },
        %Relationship{
          end: 57,
          id: 58,
          properties: %{},
          start: 56,
          type: "LIKES"
        }
      ],
      sequence: [1, 1]
    }
  end

  # Poison and Jason doesn't order keys the same way
  defp result(:jason) do
    # Pretty formated:

    # {
    # "nodes": [
    # {
    #   "id": 56,
    #   "labels": [],
    #   "properties": {
    #     "duration": "P1Y12MT54M65.0S",
    #     "geoloc": {
    #       "crs": "wgs-84-3d",
    #       "height": 50.0,
    #       "latitude": 40.32332,
    #       "longitude": 45.006,
    #       "x": 45.006,
    #       "y": 40.32332,
    #       "z": 50.0
    #     },
    #     "boltx": true,
    #     "name": "Alice"
    #   }
    # },
    # {
    #   "id": 57,
    #   "labels": [],
    #   "properties": {
    #     "created": "2019-03-05T12:34:56+01:00",
    #    "user_struct": {
    #       id: 43,
    #       name: "Test"
    #     },
    #     "boltx": true,
    #     "name": "Bob"
    #   }
    # }
    # ],
    # "relationships": [
    # {
    #   "id": 58,
    #   "properties": {
    #     "creation_time": "12:34:56+02:00"
    #   },
    #   "type": "KNOWS"
    # },
    # {
    #   "end": 57,
    #   "id": 58,
    #   "properties": {},
    #   "start": 56,
    #   "type": "LIKES"
    # }
    # ],
    # "sequence": [
    # 1,
    # 1
    # ]
    # }
    "{\"nodes\":[{\"id\":56,\"labels\":[],\"properties\":{\"duration\":\"P1Y12MT54M65.0S\",\"geoloc\":{\"crs\":\"wgs-84-3d\",\"height\":50.0,\"latitude\":40.32332,\"longitude\":45.006,\"x\":45.006,\"y\":40.32332,\"z\":50.0},\"boltx\":true,\"name\":\"Alice\"}},{\"id\":57,\"labels\":[],\"properties\":{\"created\":\"2019-03-05T12:34:56+01:00\",\"user_strut\":{\"id\":43,\"name\":\"Test\"},\"boltx\":true,\"name\":\"Bob\"}}],\"relationships\":[{\"id\":58,\"properties\":{\"creation_time\":\"12:34:56+02:00\"},\"type\":\"KNOWS\"},{\"end\":57,\"id\":58,\"properties\":{},\"start\":56,\"type\":\"LIKES\"}],\"sequence\":[1,1]}"
  end

  defp result(:poison) do
    "{\"sequence\":[1,1],\"relationships\":[{\"type\":\"KNOWS\",\"properties\":{\"creation_time\":\"12:34:56+02:00\"},\"id\":58},{\"type\":\"LIKES\",\"start\":56,\"properties\":{},\"id\":58,\"end\":57}],\"nodes\":[{\"properties\":{\"name\":\"Alice\",\"boltx\":true,\"geoloc\":{\"z\":50.0,\"y\":40.32332,\"x\":45.006,\"longitude\":45.006,\"latitude\":40.32332,\"height\":50.0,\"crs\":\"wgs-84-3d\"},\"duration\":\"P1Y12MT54M65.0S\"},\"labels\":[],\"id\":56},{\"properties\":{\"name\":\"Bob\",\"boltx\":true,\"user_strut\":{\"name\":\"Test\",\"id\":43},\"created\":\"2019-03-05T12:34:56+01:00\"},\"labels\":[],\"id\":57}]}"
  end
end
