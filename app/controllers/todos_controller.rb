class TodosController < ApplicationController
  def index
    @filter = "all"
    @todos = Todo.owned_by(user_id)
    @completed_count = Todo.owned_by(user_id).completed.count
    @uncompleted_count = Todo.owned_by(user_id).uncompleted.count
  end
end
