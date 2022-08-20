# frozen_string_literal: true

require 'story_branch/git_wrapper'

def grab_and_print_log(from, to)
  all_log = StoryBranch::GitWrapper.command("log #{from}..#{to}")

  matches = all_log.scan(/CHANGELOG\n(.*?)--- 8< ---/m).flatten
  matches.map!(&:strip)

  File.open("release-#{from}-#{to}.md", 'w') do |output|
    output << "# RELEASE NOTES\n\n"
    matches.each do |m|
      output << "#{m}\n"
    end
  end
end

# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
def print_all_logs
  all_tags = StoryBranch::GitWrapper.command_lines('tag --list')
  cleanup_tags = all_tags.map do |t|
    { cleanup_tag: t.delete('v'), tag: t }
  end
  cleanup_tags.sort_by! { |ctags| ctags[:cleanup_tag] }
  puts cleanup_tags

  cleanup_tags.each_with_index do |tag, idx|
    from = tag[:tag]
    if idx + 1 == cleanup_tags.length
      to = 'HEAD'
    else
      from = tag[:tag]
      to = cleanup_tags[idx + 1][:tag]
    end
    grab_and_print_log(from, to)
  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength

all_logs = ARGV[0] == 'all'
if all_logs
  print_all_logs
else
  from = ARGV[0] || 'v0.7.0'
  to = ARGV[1] || 'HEAD'
  grab_and_print_log(from, to)
end
