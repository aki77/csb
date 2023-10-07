module Csb
  class ActionControllerLiveNotIncludedError < StandardError
    def initialize(controller)
      super("#{controller.class.name} must include ActionController::Live")
    end
  end
end
