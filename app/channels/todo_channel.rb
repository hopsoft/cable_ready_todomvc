class TodoChannel < ApplicationCable::Channel
  def subscribed
    stream_from "TodoChannel"
  end
end
