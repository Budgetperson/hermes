require 'user_extractor'

class User < ActiveRecord::Base
  has_many :conversations
  has_many :friends, :through => :conversations, :source => :to_users
  
  validates_uniqueness_of :uid, :allow_blank => true
  
  validates_presence_of :handle, :unless => :email?
  validates_presence_of :email, :unless => :handle?
  
  # Warm up caches when a user is first created
  after_save :autocomplete, :if => :twitter_token_changed?
  
  class << self
    # Find or new user by Twiter oauth information
    def authorize_twitter!(auth)
      return unless auth && auth.uid
    
      user = self.find_by_uid(auth.uid) || self.new
      user.uid          = auth.uid
      user.handle       = auth.info.nickname
      user.name         = auth.info.name
      user.description  = auth.info.description
      user.avatar_url   = auth.info.image
    
      if auth.provider == "twitter"      
        user.twitter_token  = auth.credentials.token
        user.twitter_secret = auth.credentials.secret
      end
    
      user.save!
      user
    end
    
    # Find or new user by handle or email address
    def for(to_users)
      if to_users.is_a?(String)
        to_users = to_users.split(',')
      end
      
      users  = []
      result = UserExtractor.extract(to_users)
      
      result[:handles].each do |handle|
        users << find_or_create_by_handle(handle)
      end
      
      result[:emails].each do |email|
        users << find_or_create_by_email(email)
      end
      
      users.uniq
    end
  end
  
  def to_s
    handle? ? "@#{handle}" : email
  end
  
  def twitter
    Twitter::Client.new(
      :oauth_token        => self.twitter_token,
      :oauth_token_secret => self.twitter_secret
    )
  end
  
  def twitter?
    twitter_token?
  end  
  
  alias_method :member?, :twitter?
  
  def autocomplete
    Rails.cache.fetch([cache_key, :autocomplete].join('/')) do
      friends_autocomplete | twitter_autocomplete
    end
  end
  
  def serializable_hash(options = nil)
    super((options || {}).merge(
      :except  => [:twitter_token, :twitter_secret, :uid]
    ))
  end
  
  protected
    def twitter_autocomplete
      return [] unless twitter? 
      friend_ids = twitter.friend_ids.ids.shuffle[0..99]
      friends    = twitter.users(*friend_ids)
      friends.map {|f| "@#{f.screen_name}" }
    end

    def friends_autocomplete
      friends.map(&:to_s)
    end
end