class TodoChannel < ApplicationCable::Channel
  include CableReady::Broadcaster

  def subscribed
    stream_from "TodoChannel"
  end

  def receive(data)
    data.each do |action, params_list|
      params_list.each do |params|
        spa = TodosSpa.new(user_id, ActionController::Parameters.new(params))
        send action, spa
        spa.broadcast
      end
    end
  end

  private

    def create(spa)
      todo = Todo.new(spa.params.permit(:title))
      if todo.save
        spa.todo_created todo
      end
    end

    def update(spa)
      return toggle_all(spa) if spa.params[:id] == "toggle"

      todo = Todo.find(spa.params[:id])
      if todo.update spa.params.permit(:title, :completed)
        spa.todo_updated todo
      end
    end

    def toggle_all(spa)
      if Todo.uncompleted.present?
        Todo.uncompleted.each do |todo|
          todo.update completed: true
          spa.todo_updated todo
        end
      else
        Todo.completed.each do |todo|
          todo.update completed: false
          spa.todo_updated todo
        end
      end
    end

    def destroy(spa)
      if spa.params[:id] == "completed"
        destroy_completed spa
      else
        todo = Todo.find(spa.params[:id])
        todo.destroy
        spa.todo_destroyed todo
      end
    end

    def destroy_completed(spa)
      Todo.completed.each do |todo|
        todo.destroy
        spa.todo_destroyed todo
      end
    end

    def edit(spa)
      todo = Todo.find(spa.params[:id])
      spa.todo_edited todo
    end

    def show(spa)
      todo = Todo.find(spa.params[:id])
      spa.todo_shown todo
    end

    def index(spa)
      case spa.params[:filter]
      when "all"
        spa.todos_shown Todo.all
      when "uncompleted"
        spa.todos_shown Todo.uncompleted
        spa.todos_hidden Todo.completed
      when "completed"
        spa.todos_shown Todo.completed
        spa.todos_hidden Todo.uncompleted
      end
    end
end
