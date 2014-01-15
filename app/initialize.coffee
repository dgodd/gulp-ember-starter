#
# Copyright (c) 2014 Fuse Elements, LLC. All rights reserved.
#

`import App from "app"`

# TODO Generate a registry loader.
`import "templates/registry"`
`import "models/registry"`
`import "views/registry"`
`import "components/registry"`
`import "controllers/registry"`
`import "routes/registry"`

`import "router"`

# Export App to window.App (or a different property name) for use in the
# Handlebars templates and console debugging.
window.App = App
