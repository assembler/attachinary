class CreateTables < ActiveRecord::Migration
  def change
    create_table :attachinary_files do |t|
      t.references :parent, polymorphic: true
      t.string :scope

      t.string :public_id
      t.string :version
      t.integer :width
      t.integer :height
      t.string :format
      t.string :resource_type
      t.timestamps
    end
    add_index :attachinary_files, [:parent_type, :parent_id, :scope], name: 'by_scoped_parent'
  end
end
