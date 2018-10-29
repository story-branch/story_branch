# Architecture view

::Main
  - Read config
  - Initialize utils to use
  - Provide interface for opening/closing/config the gem

::ConfigManager
  - load configuration files and have methods to fetch project id, api key and
  finish tag according to the needs

::PivotalUtils
  - Wrap PivotalTracker API
  - Get Story List
  - ...

::GithubUtils
  - Wrap Github API
  - Get Issue List
  - Integrate with Project workflow (?)

::OtherTrackers
  - Provide interface for extending to other trackers
