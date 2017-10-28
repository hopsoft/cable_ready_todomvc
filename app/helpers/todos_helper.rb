module TodosHelper
  def completed(todos)
    todos.select(&:completed?)
  end

  def incompleted(todos)
    todos - completed(todos)
  end
end
