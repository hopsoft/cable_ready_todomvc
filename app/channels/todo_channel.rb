class TodoChannel < ApplicationCable::Channel
  include CableReady::Broadcaster

  def subscribed
    stream_from "TodoChannel"
  end

  def receive(data)
    data      = ActionController::Parameters.new(data)
    operation = data[:operation][:name]
    params    = data[:operation][:params] || {}
    filter    = data[:filter] || "all"

    send operation, params if respond_to?(operation, true)

    cable_ready["TodoChannel"].morph selector: "div#app",
      html: TodosController.renderer.render(
        template: "/todos/index",
        layout: false,
        assigns: { user_id: user_id, filter: filter, todos: Todo.send(filter) }
      )
    cable_ready.broadcast
  end

  private

    def create(params)
      Todo.create(params.permit(:title))
    end

    def update(params)
      return toggle_all if params[:id] == "toggle"
      todo = Todo.find(params[:id])
      todo.update params.permit(:title, :completed)
    end

    def toggle_all
      return Todo.uncompleted.update_all completed: true if Todo.uncompleted.present?
      Todo.completed.update_all completed: false
    end

    def destroy(params)
      return Todo.completed.destroy_all if params[:id] == "completed"
      todo = Todo.find(params[:id])
      todo.destroy
    end

    #def edit(spa)
      #todo = Todo.find(spa.params[:id])
      #spa.todo_edited todo
    #end

    #def show(spa)
      #todo = Todo.find(spa.params[:id])
      #spa.todo_shown todo
    #end
end
