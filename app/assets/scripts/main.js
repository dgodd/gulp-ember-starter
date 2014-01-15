/*
 * Copyright (c) 2014 Fuse Elements, LLC. All rights reserved.
 */

/* global require requirejs */

requirejs.config({
  baseUrl: "scripts/modules",
  paths: {
    ember: window.ENV && window.ENV.DEVELOPMENT ? "../ember" : "../ember.min",
    handlebars: window.ENV && window.ENV.DEVELOPMENT ? "../handlebars" : "../handlebars.runtime",
    jquery: "//code.jquery.com/jquery-2.0.3.min"
  },
  shim: {
    ember: {
      deps: ["jquery", "handlebars"],
      exports: "Ember"
    },
    handlebars: {
      exports: "Handlebars"
    },
    jquery: {
      exports: "$"
    }
  }
});

//
// Bootstrap the ember and the application.
//
// Note: "app" defers booting the application instance to allow all custom
// framework modules to complete loading.
//
require(["ember"], function () {
  require(["app", "initialize"], function (app) {
    // Resume booting the app.
    app["default"].advanceReadiness();
  });
});
