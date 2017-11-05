class UserChannel < ApplicationCable::Channel
  include CableReady::Broadcaster

  def subscribed
    stream_from "UserChannel#{params[:room]}"
  end

  def receive(data)
    data      = ActionController::Parameters.new(data)
    filter    = data[:filter] || "all"
    operation = data[:operation][:name]
    params    = data[:operation][:params] || {}
    edit_id   = params[:id].to_i if operation == "edit"

    send operation, params if respond_to?(operation, true)

    cable_ready["UserChannel#{user_id}"].morph selector: "section#todoapp",
      html: TodosController.renderer.render(
        template: "/todos/index",
        layout: false,
        assigns: {
          filter: filter,
          todos: Todo.owned_by(user_id).send(filter),
          completed_count: Todo.owned_by(user_id).completed.count,
          uncompleted_count: Todo.owned_by(user_id).uncompleted.count,
          edit_id: edit_id
        }
      )
    cable_ready.broadcast
  end

  private

    def create(params)
      Todo.create params.permit(:title).merge(user_id: user_id)
    end

    def update(params)
      return toggle_all if params[:id] == "toggle"
      todo = Todo.owned_by(user_id).find_by(id: params[:id])
      todo.update params.permit(:title, :completed)
    end

    def toggle_all
      return Todo.owned_by(user_id).uncompleted.update_all completed: true if Todo.uncompleted.present?
      Todo.owned_by(user_id).completed.update_all completed: false
    end

    def destroy(params)
      return Todo.owned_by(user_id).completed.destroy_all if params[:id] == "completed"
      todo = Todo.owned_by(user_id).find(params[:id])
      todo.destroy
    end
end
