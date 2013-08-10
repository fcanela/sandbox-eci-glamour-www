class CreateParticipants < ActiveRecord::Migration
  def up
    create_table :participants do |t|
      t.string  :name
      t.string  :namehash
    end
    add_index :participants, :name, :unique => true
    add_index :participants, :namehash, :unique => true
  end

  def down
    drop_table :participant
  end
end
