module TodosHelper
  def todo_css(todo, filter)
    css = []
    css << "completed" if todo.completed?
    css << "hidden"    if todo.uncompleted? && filter == "completed"
    css << "hidden"    if todo.completed? && filter == "uncompleted"
    css.uniq.join " "
  end
end
