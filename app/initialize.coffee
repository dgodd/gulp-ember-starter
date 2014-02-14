#
# Copyright (c) 2014 Fuse Elements, LLC. All rights reserved.
#

define ["app", "templates/registry", "models/registry", "views/registry", "components/registry", "controllers/registry", "routes/registry", "router"] , (App) ->

  # Export App to window.App (or a different property name) for use in the
  # Handlebars templates and console debugging.
  window.App = App
