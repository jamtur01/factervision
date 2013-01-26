require 'data_mapper'
require 'dm-types'
require 'uuid'

#DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite:db/factervision.db')
#DataMapper::Model.raise_on_save_failure = true
DataMapper::Property::String.length(255)

module FacterVision

  class Tokens
    include DataMapper::Resource

    property :id, Serial
    property :email, String, :required => true, :unique => true,
      :format => :email_address,
      :messages => {
        :presence  => "We need your email address.",
        :is_unique => "We already have that email.",
        :format    => "Doesn't look like an email address to me ..."
    }
    property :access_token, String, :required => true, :unique => true,
      :messages => {
        :presence => "We need a token.",
        :is_unique => "API keys need to be unique."
    }
  end

  class Facts
    include DataMapper::Resource

    property :id, Serial
    property :access_token, String, :required => true
    property :facts, Json
    property :created_at, DateTime
  end

  DataMapper.finalize
  DataMapper.auto_upgrade!

  class Fact
    def self.add_facts(facts, access_token)
      Facts.create(:access_token => access_token, :created_at => Time.now, :facts => facts)
    end

    def self.get_facts(access_token)
      Facts.all(:access_token => access_token)
    end
  end

  class Token
    def self.signup(email)
      access_token = UUID.new.generate
      Tokens.create(:access_token => access_token, :email => email)
    end

    def self.get_user(token)
      Tokens.first(:access_token => token)
    end

    def self.get_token_email(email)
      Tokens.first(:email => email)
    end

  end
end
