require 'jira-ruby'

tracker_url = "https://perxtechnologies.atlassian.net"
api_key = "6lGruzSf1YWWEoTapgsv899F"
username = "rui@perxtech.com"

client = JIRA::Client.new({
  username: username,
  password: api_key,
  site: tracker_url,
  auth_type: :basic,
  read_timeout: 120,
  context_path: ''
})

epic_keys = client.Issue.jql("issuetype = Epic AND project = VS AND fixVersion = \"V4 2019 - Jan to Mar 2020\"").map(&:key)
issue_jql = "\"Epic Link\" in (#{epic_keys.join(',')})"

issues = client.Issue.jql(issue_jql)
