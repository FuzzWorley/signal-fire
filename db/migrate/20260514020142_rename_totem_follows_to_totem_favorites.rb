class RenameTotemFollowsToTotemFavorites < ActiveRecord::Migration[8.1]
  def change
    rename_table :totem_follows, :totem_favorites
  end
end
