class TodosSpa
  extend Forwardable
  include CableReady::Broadcaster
  attr_reader :channel, :user_id, :params

  def initialize(channel, user_id, params={})
    @channel = channel
    @user_id = user_id
    @params = params
  end

  def broadcast
    render_footer
    cable_ready.broadcast
  end

  def request
    channel.connection.send :request
  end

  def todo_created(todo)
    filter = params[:filter] || "all"
    html = TodosController.renderer.render(
      template: "/todos/index",
      assigns: { user_id: user_id, filter: filter, todos: Todo.send(filter) }
    )
    old_body = RenderedPage.find_by(user_id: user_id, name: "todos#index")&.body_element
    new_body = Nokogiri::HTML(html).at("body")

    # TODO: diff the fragments & generate the cable_ready updates
    changes = []
    old_body.tdiff(new_body) do |change, node|
      node = node.parent while node.text? && node.parent
      changes << [change, node.to_s] if change =~ /\+|\-/
    end
    binding.pry

    todo_operations.insert_adjacent_html selector: ".todo-list",
      html: todo.render_with(partial: "/todos/todo.html", assigns: { filter: params[:filter] })
    todo_operations.remove_css_class selector: ".main",      name: "hidden"
    todo_operations.remove_css_class selector: ".footer",    name: "hidden"
    user_operations.set_value        selector: ".new-todo",  value: ""
  end

  def todo_updated(todo)
    todo_operations.replace selector: "##{todo.to_gid_param}",
      html: todo.render_with(partial: "/todos/todo.html", assigns: { filter: params[:filter] })
  end

  def todo_destroyed(todo)
    todo_operations.remove selector: "##{todo.to_gid_param}"

    if Todo.count.zero?
      todo_operations.add_css_class selector: ".main", name: "hidden"
      todo_operations.add_css_class selector: ".footer", name: "hidden"
    end
  end

  def todos_shown(todos)
    todos.each do |todo|
      todo_operations.remove_css_class selector: "##{todo.to_gid_param}", name: "hidden"
    end
  end

  def todos_hidden(todos)
    todos.each do |todo|
      todo_operations.add_css_class selector: "##{todo.to_gid_param}", name: "hidden"
    end
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
      renderer = TodosController.renderer.new
      user_operations.replace selector: ".footer",
        html: renderer.render(partial: "/todos/footer.html", assigns: { filter: params[:filter] })
    end
end
