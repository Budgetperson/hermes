class Conversation < ActiveRecord::Base
  belongs_to :user

  has_many :conversation_users
  has_many :to_users, :through => :conversation_users, :source => :user

  has_many :messages
  
  validates_presence_of :user_id
  validates_length_of   :to_users, :within => 1..20
  
  scope :between, lambda {|from, *to| 
    includes(:conversation_users).where("conversations.user_id = ? AND conversation_users.user_id IN (?)", from.id, to)
  }
  
  scope :for_user, lambda {|user|
    where(:user_id => user && user.id)
  }
  
  scope :latest, order("updated_at DESC")
  
  validate :valid_users
  
  class << self
    def between!(user, from, *to)
      # If the message was from a different person, then the
      # conversation needs to include them too
      to |= [from]
      
      # To must not include the current user
      to -= [user]
      
      # Find or new conversation
      between(user, *to).first || self.new(:user => user, :to_users => to)
    end
  end
  
  def serializable_hash(options = nil)
    # TODO - limit amount of messages a conversation includes by default
    super((options || {}).merge(
      :include => [:user, :to_users, :messages]
    ))
  end
  
  def to_s
    handle || email
  end
  
  def valid_users
    if to_users.include?(user)
      errors.add("users", "can't start a conversation with yourself")
    end
  end
end