# frozen_string_literal: true

module StoryBranch
  # Class used to open a URL
  class UrlOpener
    def self.open_url(url)
      url = "https://#{url}" unless url.start_with?('http')
      case RbConfig::CONFIG['host_os']
      when /mswin|mingw|cygwin/
        system "start #{url}"
      when /darwin/
        system "open #{url}"
      when /linux|bsd/
        system "xdg-open #{url}"
      end
    end
  end
end
