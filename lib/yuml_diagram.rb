require 'digest/md5'

module YUML
  class Diagram
    def md5
      Digest::MD5.hexdigest(self.to_line)
    end
  end
end