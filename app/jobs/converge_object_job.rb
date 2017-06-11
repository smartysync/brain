class ConvergeObjectJob < ApplicationJob
  queue_as :default

  def perform(object:)
    Brain.converge_object object
  end
end
