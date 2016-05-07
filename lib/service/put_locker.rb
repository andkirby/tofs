module Service
  module PutLocker
    module_function

    HOSTNAME = "\x70\x75\x74\x6C\x6F\x63\x6B\x65\x72\x2E\x69\x73"

    def get_base_url
      'http://' + HOSTNAME
    end
  end
end
