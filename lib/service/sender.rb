
module Service
  module Sender
    module_function

    def get(name)
      if name == 'slack'
        return Service::Sender::Slack
      end
      raise
    end
  end
end
