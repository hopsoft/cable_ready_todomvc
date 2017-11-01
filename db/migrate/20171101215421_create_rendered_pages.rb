class CreateRenderedPages < ActiveRecord::Migration[5.1]
  def change
    create_table :rendered_pages do |t|
      t.string :user_id, null: false
      t.string :name, null: false
      t.text :body
      t.timestamps
      t.index [:user_id, :name], unique: true
    end
  end
end
