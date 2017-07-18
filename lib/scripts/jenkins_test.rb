load 'app/services/training_api.rb'

3.times do | i |
  puts i
  Thread.new{ puts TrainingAPI.new.build Release.new( branch_name:"release-#{ i }" )}
end
