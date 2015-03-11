class CreateCatRentalRequests < ActiveRecord::Migration
  def change
    create_table :cat_rental_requests do |t|
      t.references :cat, index: true
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :status, null: false

      t.timestamps null: false
    end
    add_foreign_key :cat_rental_requests, :cats
  end
end
