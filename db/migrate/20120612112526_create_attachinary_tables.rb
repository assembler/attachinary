class CreateAttachinaryTables < ActiveRecord::Migration
  def change
    create_table :attachinary_files do |t|
      t.references :attachinariable, polymorphic: true
      t.string :scope

      t.string :public_id
      t.string :version
      t.integer :width
      t.integer :height
      t.string :format
      t.string :resource_type
      t.integer :position
      t.timestamps
    end
    add_index :attachinary_files, [:attachinariable_type, :attachinariable_id, :scope], name: 'by_scoped_parent'
  end
end
