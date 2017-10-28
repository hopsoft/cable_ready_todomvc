class UserChannel < ApplicationCable::Channel
  def subscribed
    stream_from "UserChannel#{params[:room]}"
  end
end
