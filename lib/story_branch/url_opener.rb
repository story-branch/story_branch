# frozen_string_literal: true

module StoryBranch
  # Class used to open a URL
  class UrlOpener
    def self.open_url(url)
      url = "https://#{url}" unless url.start_with?('http')
      if RbConfig::CONFIG['host_os'].match?(/mswin|mingw|cygwin/)
        system "start #{url}"
      elsif RbConfig::CONFIG['host_os'].match?(/darwin/)
        system "open #{url}"
      elsif RbConfig::CONFIG['host_os'].match?(/linux|bsd/)
        system "xdg-open #{url}"
      end
    end
  end
end
