module Service
  module PutLocker
    module_function

    HOSTNAME = "\x70\x75\x74\x6c\x6f\x63\x6b\x65\x72\x2e\x75\x73\x2e\x63\x6f\x6d"

    def base_url
      'http://' + HOSTNAME
    end
  end
end
