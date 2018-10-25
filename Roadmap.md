# Architecture view

::Main
  - Read config
  - Initialize utils to use
  - Provide interface for opening/closing/config the gem

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
