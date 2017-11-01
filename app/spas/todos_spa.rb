require "forwardable"

class TodosSpa
  extend Forwardable
  include CableReady::Broadcaster
  attr_reader :user_id, :params
  def_delegators :cable_ready, :broadcast

  def initialize(user_id, params={})
    @user_id = user_id
    @params = params
  end

  def todo_created(todo)
    todo_operations.insert_adjacent_html selector: ".todo-list",
      html: todo.render_with(partial: "/todos/todo.html", assigns: { filter: params[:filter] })
    todo_operations.remove_css_class     selector: ".main",      name: "hidden"
    todo_operations.remove_css_class     selector: ".footer",    name: "hidden"
    user_operations.set_value            selector: ".new-todo",  value: ""
    render_footer
  end

  def todo_updated(todo)
    todo_operations.replace selector: "##{todo.to_gid_param}",
      html: todo.render_with(partial: "/todos/todo.html", assigns: { filter: params[:filter] })
    render_footer
  end

  def todo_destroyed(todo)
    todo_operations.remove selector: "##{todo.to_gid_param}"

    if Todo.count.zero?
      todo_operations.add_css_class selector: ".main", name: "hidden"
      todo_operations.add_css_class selector: ".footer", name: "hidden"
    end

    render_footer
  end

  def todos_shown(todos)
    todos.each do |todo|
      todo_operations.remove_css_class selector: "##{todo.to_gid_param}", name: "hidden"
    end
    render_footer
  end

  def todos_hidden(todos)
    todos.each do |todo|
      todo_operations.add_css_class selector: "##{todo.to_gid_param}", name: "hidden"
    end
    render_footer
  end

  def todo_shown(todo)
    todo_operations.replace selector: "##{todo.to_gid_param}",
      html: todo.render_with(partial: "/todos/todo.html")
  end

  def todo_edited(todo)
    user_operations.replace selector: "##{todo.to_gid_param}", focus_selector: "##{todo.to_gid_param} input",
      html: todo.render_with(partial: "/todos/form.html")
  end

  private
    def todo_operations
      cable_ready["TodoChannel"]
    end

    def user_operations
      cable_ready["UserChannel#{user_id}"]
    end

    def render_footer
      renderer = ApplicationController.renderer.new
      user_operations.replace selector: ".footer",
        html: renderer.render(partial: "/todos/footer.html", assigns: { filter: params[:filter] })
    end
end
