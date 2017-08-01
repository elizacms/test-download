class DialogReference < Dialog
  include DialogReferenceExportable

  field :intent_reference, type:String

  validates_presence_of :intent_reference
end