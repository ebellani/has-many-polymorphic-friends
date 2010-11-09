class Friendship < ActiveRecord::Base

  belongs_to :inviter, :polymorphic => true
  belongs_to :invitee, :polymorphic => true

end

