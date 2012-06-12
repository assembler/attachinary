class CreateTables < ActiveRecord::Migration
  def change
    create_table :attachinary_attachments do |t|
      t.belongs_to :parent, polymorphic: true
      t.belongs_to :file
      t.string :scope
      t.timestamps
    end
    add_index :attachinary_attachments, [:parent_type, :parent_id, :scope], name: 'by_scoped_parent'

    create_table :attachinary_files do |t|
      t.string :public_id
      t.string :version
      t.integer :width
      t.integer :height
      t.string :format
      t.string :resource_type
      t.timestamps
    end
  end
end
