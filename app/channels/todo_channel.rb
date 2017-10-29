class TodoChannel < ApplicationCable::Channel
  include CableReady::Broadcaster

  def subscribed
    stream_from "TodoChannel"
  end

  def receive(data)
    data.each do |action, params_list|
      params_list.each do |params|
        send action, ActionController::Parameters.new(params)
      end
    end
  end

  private

    def todo_operations
      cable_ready["TodoChannel"]
    end

    def user_operations
      cable_ready["UserChannel#{user_id}"]
    end

    def count_html
      renderer = ApplicationController.renderer.new
      renderer.render partial: "/todos/count", locals: { count: Todo.uncompleted.size }
    end

    def clear_completed_operation
      Todo.completed.count.zero? ? :add_css_class : :remove_css_class
    end

    def should_remove?(todo, filter)
      remove   = filter == "Active" && todo.completed?
      remove ||= filter == "Completed" && todo.uncompleted?
      remove
    end

    def create(params)
      todo = Todo.new(params.permit(:title))

      if todo.save
        todo_html = todo.render_with(partial: "/todos/todo.html")
        user_operations.set_value                              selector: ".new-todo",   value: ""
        todo_operations.insert_adjacent_html                   selector: ".todo-list",  html: todo_html
        todo_operations.remove_css_class                       selector: ".main",       name: "hidden"
        todo_operations.remove_css_class                       selector: ".footer",     name: "hidden"
        todo_operations.replace                                selector: ".todo-count", html: count_html
        todo_operations.public_send clear_completed_operation, selector: ".clear-completed", name: "hidden"
        cable_ready.broadcast
      end
    end

    def update(params)
      todo = Todo.find(params["id"])

      if todo.update(params.permit(:title, :completed))
        todo_html = todo.render_with(partial: "/todos/todo.html")
        operation = should_remove?(todo, params[:filter]) ? :remove : :replace
        todo_operations.public_send operation,                 selector: "##{todo.id}", html: todo_html
        todo_operations.replace                                selector: ".todo-count", html: count_html
        todo_operations.public_send clear_completed_operation, selector: ".clear-completed", name: "hidden"
        cable_ready.broadcast
      end
    end
end
