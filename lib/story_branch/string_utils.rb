# frozen_string_literal: true

module StoryBranch
  # Utility class for string manipulation
  class StringUtils
    def self.sanitize(s)
      res = s.strip
      res.tr!("\n", '-')
      encoding_options = {
        invalid: :replace, # Replace invalid byte sequences
        undef: :replace, # Replace anything not defined in ASCII
        replace: '-' # Use a dash for those replacements
      }
      res.encode(Encoding.find('ASCII'), encoding_options)
    end

    def self.dashed(s)
      sanitize(s).tr(" _,./:;+&'\"?", '-').squeeze('-')
    end

    def self.normalised_branch_name(s)
      dashed(s).downcase
    end

    def self.undashed(s)
      s.tr('-', ' ').squeeze(' ').strip.capitalize
    end
  end
end
