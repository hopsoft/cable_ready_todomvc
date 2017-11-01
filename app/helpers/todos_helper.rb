module TodosHelper
  def todo_css(todo, filter)
    css = []
    css << "completed" if todo.completed?
    css << "hidden"    if todo.uncompleted? && filter == "completed"
    css << "hidden"    if todo.completed? && filter == "uncompleted"
    css.uniq.join " "
  end

  def filter_css(key, filter)
    return "selected" if key == :all && filter.nil?
    return "selected" if key.to_s == filter
    nil
  end

  def count_css
    return "hidden" if Todo.completed.count.zero?
    nil
  end

  def footer_css
    return "hidden" if Todo.count.zero?
    nil
  end
end
