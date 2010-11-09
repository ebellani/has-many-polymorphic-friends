module HasManyPolymorphicFriends

  module UserExtensions
  
    def self.included( recipient )
      recipient.extend( ClassMethods )
    end
    
    module ClassMethods
      def has_many_friends(options={})
      
        has_many :friendships, :as => :inviter

        has_many :friendships, :as => :invitee

        include HasManyFriends::UserExtensions::InstanceMethods
      end
    end
    
    module InstanceMethods

      def friends_by_me
        friendships = Friendship.find(:all, :conditions => ['invitee_id = :id AND invitee_type = :type AND accepted_at IS NOT NULL', {:id => self.id, :type => self.class.to_s}]) 
        friends_by_me = []
        friendships.each { |friendship|
          friends_by_me << friendship.inviter
        }        
        friends_by_me          
      end
      
      def friends_for_me
        friendships = Friendship.find(:all, :conditions => ['inviter_id = :id AND inviter_type = :type AND accepted_at IS NOT NULL', {:id => self.id, :type => self.class.to_s}]) 
        friends_for_me = []
        friendships.each { |friendship|
          friends_for_me << friendship.invitee
        }        
        friends_for_me           
      end      

      def pending_friends_by_me
        friendships = Friendship.find(:all, :conditions => ['invitee_id = :id AND invitee_type = :type AND accepted_at IS NULL', {:id => self.id, :type => self.class.to_s}]) 
        pending_friends_by_me = []
        friendships.each { |friendship|
          pending_friends_by_me << friendship.inviter
        }        
        pending_friends_by_me  
      end
      
      def pending_friends_for_me
        friendships = Friendship.find(:all, :conditions => ['inviter_id = :id AND inviter_type = :type AND accepted_at IS NULL', {:id => self.id, :type => self.class.to_s}])
        pending_friends_for_me = []
        friendships.each { |friendship|
          pending_friends_for_me << friendship.invitee
        }        
        pending_friends_for_me          
      end      

      # Returns a list of all of a users accepted friends.
      def friends
        friends = self.friends_for_me + self.friends_by_me
      end
      
      # Returns a list of all pending friendships.
      def pending_friends
        self.pending_friends_by_me + self.pending_friends_for_me
      end
      
      # Returns a full list of all pending and accepted friends.
      def pending_or_accepted_friends
        self.friends + self.pending_friends
      end
      
      # Accepts a user object and returns the friendship object 
      # associated with both users.
      def friendship(friend)
        Friendship.find(:first, :conditions => ['(inviter_id = ?    AND
                                                  inviter_type = ?  AND 
                                                  invitee_id = ?    AND 
                                                  invitee_type = ?) OR 
                                                  (invitee_id = ?   AND 
                                                   invitee_type = ? AND
                                                   inviter_id = ?   AND 
                                                   inviter_type = ?)', 
                                                  self.id, 
                                                  self.class.to_s, 
                                                  friend.id, 
                                                  friend.class.to_s,
                                                  self.id, self.class.to_s, friend.id,
                                                  friend.class.to_s]) 
      end
    
      # Accepts a user object and returns true if both users are
      # friends and the friendship has been accepted.
      def is_friends_with?(friend)
        self.friends.include?(friend)
      end
      
      # Accepts a user object and returns true if both users are
      # friends but the friendship hasn't been accepted yet.
      def is_pending_friends_with?(friend)
        self.pending_friends.include?(friend)
      end
      
      # Accepts a user object and returns true if both users are
      # friends regardless of acceptance.
      def is_friends_or_pending_with?(friend)
        self.pending_or_accepted_friends.include?(friend)
      end
      
      # Accepts a user object and creates a friendship request
      # between both users.
      def request_friendship_with(friend)
       f = Friendship.create!(:inviter => self, 
                           :invitee => friend) unless self.is_friends_or_pending_with?(friend) || self == friend
      end
      
      # Accepts a user object and updates an existing friendship to
      # be accepted.
      def accept_friendship_with(friend)
        self.friendship(friend).update_attribute(:accepted_at, Time.now)
      end
      
      # Accepts a user object and deletes a friendship between both 
      # users.
      def delete_friendship_with(friend)
        self.friendship(friend).destroy if self.is_friends_or_pending_with?(friend)
      end
      
      # Accepts a user object and creates a friendship between both 
      # users. This method bypasses the request stage and makes both
      # users friends without needing to be accepted.
      def become_friends_with(friend)
        unless self.is_friends_with?(friend)
          unless self.is_pending_friends_with?(friend)
            Friendship.create!(:inviter => self, :invitee => friend, :accepted_at => Time.now)
          else
            self.friendship(friend).update_attribute(:accepted_at, Time.now)
          end
        else
          self.friendship(friend)
        end
      end
      
    end  
  end
end
