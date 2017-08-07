desc 'Create user; create skill; create field_data_types'
task eliza_setup: :environment do
  # Create admin user
  user = User.create( email: 'iamplusqa@gmail.com' )
  Role.create( name: 'admin', user_id: user.id )

  # Create Eliza Skill
  Skill.create( name: 'Eliza', web_hook: 'eliza' )

  # Get Existing Data Types
  all_types = Intent.new.all_action_files.map do |file_path|
    JSON.parse( File.read(file_path) )['fields'].map { |field| field['type'] }
  end.flatten.compact.uniq

  # Create FieldDataType objects
  all_types.each { |type| FieldDataType.create(name: type) }
end
