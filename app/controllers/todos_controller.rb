class TodosController < ApplicationController
  def index
    @filter = "all"
    @todos = Todo.all
    @uncompleted_count = Todo.uncompleted.count
  end
end
