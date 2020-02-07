class AddPublicIdIndex < ActiveRecord::Migration
  def change
    add_index :attachinary_files, [:public_id], name: 'attch_index_public_id', length: 10
  end
end
