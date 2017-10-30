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

    def create(params)
      todo = Todo.new(params.permit(:title))

      if todo.save
        todo_operations.insert_adjacent_html selector: ".todo-list",
          html: todo.render_with(partial: "/todos/todo.html", assigns: { filter: params[:filter] })
        todo_operations.remove_css_class     selector: ".main",      name: "hidden"
        todo_operations.remove_css_class     selector: ".footer",    name: "hidden"
        user_operations.set_value            selector: ".new-todo",  value: ""
        render_todo_count
        toggle_clear_completed_button
        cable_ready.broadcast
      end
    end

    def update(params)
      todo = Todo.find(params[:id])

      if todo.update(params.permit(:title, :completed))
        todo_operations.replace selector: "##{todo.to_gid_param}",
          html: todo.render_with(partial: "/todos/todo.html", assigns: { filter: params[:filter] })
        render_todo_count
        toggle_clear_completed_button
        cable_ready.broadcast
      end
    end

    def destroy(params)
      todo = Todo.find(params[:id])
      todo.destroy

      if Todo.count.zero?
        todo_operations.add_css_class selector: ".main", name: "hidden"
        todo_operations.add_css_class selector: ".footer", name: "hidden"
      end

      todo_operations.remove selector: "##{todo.to_gid_param}"
      render_todo_count
      toggle_clear_completed_button
      cable_ready.broadcast
    end

    def edit(params)
      todo = Todo.find(params[:id])
      user_operations.replace selector: "##{todo.to_gid_param}", focus_selector: "##{todo.to_gid_param} input",
        html: todo.render_with(partial: "/todos/form.html")
      cable_ready.broadcast
    end

    def show(params)
      todo = Todo.find(params[:id])
      todo_operations.replace selector: "##{todo.to_gid_param}", html: todo.render_with(partial: "/todos/todo.html")
      cable_ready.broadcast
    end

    def index(params)
      case params[:filter]
      when "all"
        show_todos Todo.all
      when "uncompleted"
        show_todos Todo.uncompleted
        hide_todos Todo.completed
      when "completed"
        show_todos Todo.completed
        hide_todos Todo.uncompleted
      end

      user_operations.replace selector: ".footer",
        html: renderer.render(partial: "/todos/footer.html", assigns: { todos: todos, filter: params[:filter] })
      cable_ready.broadcast
    end

    def show_todos(todos)
      todos.each do |todo|
        todo_operations.remove_css_class selector: "##{todo.to_gid_param}", name: "hidden"
      end
    end

    def hide_todos(todos)
      todos.each do |todo|
        todo_operations.add_css_class selector: "##{todo.to_gid_param}", name: "hidden"
      end
    end

    def show_clear_completed_button
      todo_operations.remove_css_class selector: ".clear-completed", name: "hidden"
    end

    def hide_clear_completed_button
      todo_operations.add_css_class selector: ".clear-completed", name: "hidden"
    end

    def toggle_clear_completed_button
      if Todo.completed.count.zero?
        hide_clear_completed_button
      else
        show_clear_completed_button
      end
    end

    def show_footer
      todo_operations.remove_css_class selector: ".footer", name: "hidden"
    end

    def hide_footer
      todo_operations.remove_css_class selector: ".footer", name: "hidden"
    end

    def toggle_footer
      if Todo.count.zero?
        hide_footer
      else
        show_footer
      end
    end

    def render_todo_count
      renderer = ApplicationController.renderer.new
      todo_operations.replace selector: ".todo-count",
        html: renderer.render(partial: "/todos/count", locals: { count: Todo.uncompleted.size })
    end
end
