class @FB

  constructor: (@name) ->

  rootRef = new Firebase("https://incandescent-fire-4492.firebaseio.com/nodes");

  @remove = (id) ->
    rootRef.child(id).remove()

  @update = (id, hash) ->
    rootRef.child(id).update(hash)

  @push = (hash) ->
    rootRef.push(hash)

  @child_added = (cb) ->
    rootRef.on "child_added", (snapshot) ->
      message = snapshot.val()
      cb(snapshot.name(), snapshot.val())

  @child_removed = (cb) ->
    rootRef.on "child_removed", (snapshot) ->
      cb(snapshot.name(), snapshot.val())

  @child_changed = (cb) ->
    rootRef.on "child_changed", (snapshot) ->
      cb(snapshot.name(), snapshot.val())

jQuery("body").on "hover",".editable", (->
  $(this).next("a").show()
), ->
  $(this).next("a").hide()

