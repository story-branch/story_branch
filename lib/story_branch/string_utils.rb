# frozen_string_literal: true

module StoryBranch
  # Utility class for string manipulation
  class StringUtils
    def self.sanitize(text)
      res = text.strip
      res.tr!("\n", '-')
      encoding_options = {
        invalid: :replace, # Replace invalid byte sequences
        undef: :replace, # Replace anything not defined in ASCII
        replace: '-' # Use a dash for those replacements
      }
      res.encode(Encoding.find('ASCII'), encoding_options)
    end

    def self.dashed(text)
      sanitize(text).gsub(/[^0-9a-z]/i, '-').squeeze('-').gsub(/-$|^-/, '')
    end

    def self.normalised_branch_name(text)
      dashed(text).downcase
    end

    def self.undashed(text)
      text.tr('-', ' ').squeeze(' ').strip.capitalize
    end
  end
end
