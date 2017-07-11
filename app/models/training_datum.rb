class TrainingDatum
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :intent

  field :file_name, type:String
end
