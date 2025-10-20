defmodule Boltx.BoltProtocol.Message.DiscardMessage do
  @moduledoc false

  alias Boltx.BoltProtocol.MessageEncoder

  @signature 0x2F

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
       message: "DISCARD message version not supported"
     })}
  end

  def prepare_messages(bolt_version, messages) do
    case hd(messages) do
      {:success, response} ->
        success_data =
          if bolt_version <= 2.0 do
            Map.merge(
              %{"t_last" => messages[:success]["result_consumed_after"]},
              Map.delete(messages[:success], "result_consumed_after")
            )
          else
            response
          end

        {:ok, success_data}

      {:failure, response} ->
        {:error,
         Boltx.Error.wrap(__MODULE__, %{code: response["code"], message: response["message"]})}

      {:ignored, _response} ->
        {:ok, %{}}
    end
  end

  defp get_extra_parameters(extra_parameters) do
    %{
      n: Map.get(extra_parameters, :n, -1),
      qid: Map.get(extra_parameters, :qid, -1)
    }
  end
end
