express = require 'express'
supertest = require 'supertest'
pugStatic = require '../src/pug-static'

describe 'pug-static', ->
  request = null

  before ->
    app = express()
    app.use '/mount', pugStatic "#{__dirname}/public"
    request = supertest app

  it 'serves index.pug from folder', (done) ->
    request
      .get '/mount'
      .expect 200
      .expect '<div class="hello">World!</div>', done

  it 'serves index.pug', (done) ->
    request
      .get '/mount/index.pug'
      .expect 200
      .expect '<div class="hello">World!</div>', done

  it 'serves index.html', (done) ->
    request
      .get '/mount/index.html'
      .expect 200
      .expect '<div class="hello">World!</div>', done

  it 'handles 404s', (done) ->
    request
      .get '/mount/missing-file.pug'
      .expect 404, done
