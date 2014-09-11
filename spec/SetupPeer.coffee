noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  SetupPeer = require '../components/SetupPeer.coffee'
else
  SetupPeer = require 'noflo-peer/components/SetupPeer.js'

describe 'SetupPeer component', ->
  c = null
  beforeEach ->
    c = SetupPeer.getComponent()
    # ins = noflo.internalSocket.createSocket()
    # out = noflo.internalSocket.createSocket()
    # c.inPorts.in.attach ins
    # c.outPorts.out.attach out

  describe 'when instantiated', ->
    it 'should have correct input ports', ->
      chai.expect(Object.keys(c.inPorts.ports).length).to.equal 9
      chai.expect(c.inPorts.key).to.be.an 'object'
      chai.expect(c.inPorts.server).to.be.an 'object'
      chai.expect(c.inPorts.connect).to.be.an 'object'
      chai.expect(c.inPorts.connect_peer).to.be.an 'object'
      chai.expect(c.inPorts.send_peer).to.be.an 'object'
      chai.expect(c.inPorts.stream).to.be.an 'object'
      chai.expect(c.inPorts.call_peer).to.be.an 'object'
      chai.expect(c.inPorts.answer_call).to.be.an 'object'
      chai.expect(c.inPorts.close_peer).to.be.an 'object'
    it 'should have correct output ports', ->
      chai.expect(Object.keys(c.outPorts.ports).length).to.equal 8
      chai.expect(c.outPorts.id).to.be.an 'object'
      chai.expect(c.outPorts.data).to.be.an 'object'
      chai.expect(c.outPorts.call).to.be.an 'object'
      chai.expect(c.outPorts.stream).to.be.an 'object'
      chai.expect(c.outPorts.open).to.be.an 'object'
      chai.expect(c.outPorts.close).to.be.an 'object'
      chai.expect(c.outPorts.server_error).to.be.an 'object'
      chai.expect(c.outPorts.peer_error).to.be.an 'object'
    it 'should be a compatible browser', ->
      p = require('peerjs')
      supports = p.util.supports
      chai.expect(supports.audioVideo).to.be.true
      chai.expect(supports.data).to.be.true

  describe 'before connected to server', ->
    connect = null
    connect_peer = null
    call_peer = null
    server_error = null
    beforeEach ->
      connect = noflo.internalSocket.createSocket()
      connect_peer = noflo.internalSocket.createSocket()
      call_peer = noflo.internalSocket.createSocket()
      server_error = noflo.internalSocket.createSocket()
      c.inPorts.connect.attach connect
      c.inPorts.connect_peer.attach connect_peer
      c.inPorts.call_peer.attach call_peer
      c.outPorts.server_error.attach server_error
    it 'should immediately error when try to connect to peer', ->
      server_error.once 'data', (err) ->
        chai.expect(err).to.be.a 'string', err
      connect_peer.send 'abc'
    it 'should immediately error when try to call peer', ->
      server_error.once 'data', (err) ->
        chai.expect(err).to.be.a 'string', err
      connect_peer.send 'abc'
    it 'should immediately error when trying to connect without key', ->
      server_error.once 'data', (err) ->
        chai.expect(err).to.be.a 'string', err
      connect_peer.send 'abc'

  describe 'connecting to server', ->
    key = null
    connect = null
    send_peer = null
    id = null
    server_error = null

    before ->
      key = noflo.internalSocket.createSocket()
      connect = noflo.internalSocket.createSocket()
      send_peer = noflo.internalSocket.createSocket()
      id = noflo.internalSocket.createSocket()
      server_error = noflo.internalSocket.createSocket()
      c.inPorts.key.attach key
      c.inPorts.connect.attach connect
      c.outPorts.id.attach id
      c.outPorts.server_error.attach server_error

    it 'should get an id from the server', (done) ->
      @timeout 10000
      key.send 'lwjd5qra8257b9'
      id.once 'data', (id) ->
        chai.expect(id).to.be.a 'string'
        done()
      server_error.once 'data', (err) ->
        chai.expect(true).to.equal false, err
        done()
      connect.send()

    describe 'before connecting to peer', ->

      it 'should immediately error sending data to no peers', ->
        server_error.once 'data', (err) ->
          chai.expect(err).to.equal 'no open peer connections'
        send_peer.send 'abc'

      it 'should immediately error sending data to wrong peer id', ->
        server_error.once 'data', (err) ->
          chai.expect(err).to.equal 'no open peer connections'
        send_peer.beginGroup 'abc'
        send_peer.send 'abc'
