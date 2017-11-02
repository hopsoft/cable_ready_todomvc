class TodosController < ApplicationController
  def index
    html = render_to_string("/todos/index", assigns: { filter: "all", todos: Todo.all })
    page = RenderedPage.find_or_create_by(user_id: user_id, name: "todos#index")
    page.update body: Nokogiri::HTML(html).at("body").to_s
    render html: html
  end
end
