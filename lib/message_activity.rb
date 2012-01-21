module MessageActivity extend self
  FROM_EMAIL_PATTERNS = [
    /no-?reply/,
    /\+activity/,
    /amazon.com/,
    /facebookmail.com/,
    /linkedin.com/,
    /foursquare.com/,
    /postmaster.twitter.com/,
    /info@meetup.com/,
    /friendfeed.com/,
    /calendar-notification@google.com/,
    /support@plancast.com/,
    /github.com/,
    /googlegroups.com/
  ]
  
  def match?(message)
    message.to.each do |to|
      return true if FROM_EMAIL_PATTERNS.find {|reg| reg =~ to }
    end
    false
  end
end