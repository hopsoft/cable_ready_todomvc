module TodosHelper
  def editing?(todo)
    todo.id == @edit_id
  end

  def visible?(todo)
    return true if @filter == "all"
    todo.completed? && @filter == "completed" || todo.uncompleted? && @filter == "uncompleted"
  end
end
