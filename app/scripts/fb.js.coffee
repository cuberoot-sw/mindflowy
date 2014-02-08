class @FB

  constructor: (@name) ->

  rootRef = new Firebase("https://mindblowwy.firebaseio.com");

  @remove = (id) ->
    rootRef.child(id).remove()

  @push = (hash) ->
    rootRef.push(hash)

  @child_added = (cb) ->
    rootRef.on "child_added", (snapshot) ->
      message = snapshot.val()
      cb(snapshot.name(), snapshot.val())

  @child_removed = (cb) ->
    rootRef.on "child_removed", (snapshot) ->
      cb(snapshot.name(), snapshot.val())

