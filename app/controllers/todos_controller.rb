class TodosController < ApplicationController
  def index
    @filter = "all"
    @todos = Todo.all
  end
end
