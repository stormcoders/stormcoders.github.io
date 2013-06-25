require "digest/md5"

module Jekyll
  module MD5
    def md5(input)
      Digest::MD5.hexdigest(input)
    end
  end
end

Liquid::Template.register_filter(Jekyll::MD5)