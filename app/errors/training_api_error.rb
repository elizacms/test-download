class TrainingAPIError < StandardError
  attr_accessor :message
  
  def initialize message
    @message = message
  end
end