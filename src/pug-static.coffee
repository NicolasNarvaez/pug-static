path = require 'path'
fs = require 'fs'
pug = require 'pug'


readAndSendTemplate = (d, res, next) ->

    # Read the pug file.
    fs.readFile d, 'utf8', (err, data) ->

        # Anything screws up, then move on.
        if err?
            return next()

        try
            template = pug.compile data, filename: d
            html = template {}
            res.send html, 'Content-Type': 'text/html', 200
        catch err
            next err


checkFileAndProcess = (d, res, next) ->

    # Check if file is exists
    fs.lstat d, (err, stats) ->

        # If it exists, then we got ourselves a pug file.
        if not err? and stats.isFile()
            readAndSendTemplate d, res, next
        else
            next()


module.exports = (options) ->
    if not options?
        throw new Error("A path must be specified.")

    if typeof options is 'string'
        options = src: options, html: true

    if typeof options.html is 'undefined'
        options.html = true

    # The actual middleware itself.
    return (req, res, next) ->

        # The inputed url relative to the path.
        d = path.join options.src, req.url

        # Determines what d is.
        fs.lstat d, (err, stats) ->

            # is it a directory?
            if not err? and stats.isDirectory()

                # If so, check if there is exists a file called index.pug.
                checkFileAndProcess "#{d}/index.pug", res, next

            else if not err? and stats.isFile() and path.extname(d) is '.pug'
                readAndSendTemplate d, res, next
                
            # try to replace html file by pug template
            else if options.html? and path.extname(d) is '.html'

                # check template exists
                checkFileAndProcess d.replace(/html$/, 'pug'), res, next
            else
                next()
