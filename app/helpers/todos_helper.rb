module TodosHelper
  def completed(todos)
    todos.select(&:completed?)
  end

  def uncompleted(todos)
    todos - completed(todos)
  end
end
