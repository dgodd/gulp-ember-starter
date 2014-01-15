#
# Copyright (c) 2014 Fuse Elements, LLC. All rights reserved.
#

#
# Create the Ember application instance.
#
define ->
  App = Ember.Application.create
    # LOG_TRANSITIONS: window.ENV && window.ENV.DEVELOPMENT
    LOG_TRANSITIONS_INTERNAL: window.ENV && window.ENV.DEVELOPMENT

  #
  # Postpone booting the app. See scripts/main.js.
  #
  App.deferReadiness()

  App
