class Release
  include Mongoid::Document
  include Mongoid::Timestamps

  field :commit_sha, type:String
end
