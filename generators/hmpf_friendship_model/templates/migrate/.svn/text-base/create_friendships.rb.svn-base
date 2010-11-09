class CreateFriendships < ActiveRecord::Migration

  def self.up
    create_table :friendships do |t|
      t.string      :inviter_type
      t.integer     :inviter_id
      t.string      :invitee_type
      t.integer     :invitee_id      
      t.datetime    :accepted_at      
      t.timestamps
    end
  end

  def self.down
    drop_table :friendships
  end

end
