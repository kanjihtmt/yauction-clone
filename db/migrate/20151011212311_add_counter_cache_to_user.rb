class AddCounterCacheToUser < ActiveRecord::Migration
  def change
    add_column :users, :ratings_count, :integer, default: 0
  end
end
