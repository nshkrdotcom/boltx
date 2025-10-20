defmodule Boltx.BoltProtocol.Message.PullMessage do
  @moduledoc false

  import Boltx.BoltProtocol.ServerResponse

  alias Boltx.BoltProtocol.MessageEncoder

  @signature 0x3F

  def encode(bolt_version, extra_parameters)
      when is_float(bolt_version) and bolt_version >= 4.0 do
    message = [get_extra_parameters(extra_parameters)]
    MessageEncoder.encode(@signature, message)
  end

  def encode(bolt_version, _extra_parameters)
      when is_float(bolt_version) and bolt_version <= 3.0 do
    MessageEncoder.encode(@signature, [])
  end

  def encode(_, _) do
    {:error,
     Boltx.Error.wrap(__MODULE__, %{
       code: :unsupported_message_version,
       message: "PULL message version not supported"
     })}
  end

  def prepare_messages(bolt_version, messages) do
    records = Enum.reduce(messages, [], &group_record/2)

    cond do
      List.keymember?(messages, :failure, 0) ->
        {:error,
         Boltx.Error.wrap(__MODULE__, %{
           code: messages[:failure]["code"],
           message: messages[:failure]["message"]
         })}

      List.keymember?(messages, :ignored, 0) ->
        {:ok, pull_result(records: records, success_data: %{})}

      true ->
        success_data =
          if bolt_version <= 2.0 do
            Map.merge(
              %{"t_last" => messages[:success]["result_consumed_after"]},
              Map.delete(messages[:success], "result_consumed_after")
            )
          else
            messages[:success]
          end

        {:ok, pull_result(records: records, success_data: success_data)}
    end
  end

  defp get_extra_parameters(extra_parameters) do
    %{
      n: Map.get(extra_parameters, :n, -1),
      qid: Map.get(extra_parameters, :qid, -1)
    }
  end

  defp group_record({:record, data}, acc) do
    [data | acc]
  end

  defp group_record(_other, acc), do: acc
end
