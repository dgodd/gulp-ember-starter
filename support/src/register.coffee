#
# Copyright (c) 2014 Fuse Elements, LLC. All rights reserved.
#

path = require "path"
stream = require "stream"
File = require("vinyl")

  	
#
# Generate framework module loaders.
#

module.exports = (moduleRoot, fileName, nameFn, contentsFn) ->
  nameFn ||= (name) -> name
  contentsFn ||= (names) -> JSON.stringify(names)
  base = null
  cwd = null
  names = []
  
  ts = new stream.Transform
    objectMode: true
    
  truncate = (p) ->
    ps = p.split path.sep
    i = ps.lastIndexOf(moduleRoot) + 1
    ps.slice(i).join('/')

  ts._transform = (file, encoding, callback) ->
    	# Capture values for base and cwd for use in new File.
    	base ||= file.base
    	cwd ||= file.cwd
    	# Extract a name from the file's path.
    	p = file.path
    	extname = path.extname(p)
    	p.slice 0, -extname.length
    	name = "./" + nameFn(truncate p)
    	names.push name
    	# Done.
    	callback()

  ts._flush = (callback) ->
    	# Turn names into the file's content.
    	contents = contentsFn(names)
    	# Wrap the content in a file and push it into the stream.
    	this.push new File
    	  base: base
    	  cwd: cwd
    	  path: path.join base, fileName
    	  contents: new Buffer(contents)
    	# Done.
    	callback()

  # A gulp plugin must return a stream in objectMode where the stream contains File instances.
  ts
