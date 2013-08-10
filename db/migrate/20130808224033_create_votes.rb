class CreateVotes < ActiveRecord::Migration
  def up
    create_table :votes do |t|
      t.references :participant
      t.integer :number

      t.datetime :created_at
    end
  end

  def down
    drop_table :votes
  end
end
