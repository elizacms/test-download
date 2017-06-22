module FieldsHelper
  def get_intent_data
    file_path = IntentFileManager.new.file_path( @intent )

    IntentFileManager.new.load_intent_from( file_path )[:intent]
  end
end
