class Response
  include Mongoid::Document
  include FileSystem::CrudAble

  field :response_type,    type:String
  field :response_trigger, type:String
  field :response_value,   type:String

  belongs_to :dialog

  def self.file_system_tracked_attributes
    %w(response_type response_trigger response_value)
  end

  def attrs_with_ids
    self.attrs.merge!(id: self.id)
  end
end
