define ->
  class FB
    FBURL = "https://incandescent-fire-4492.firebaseio.com"
    #nodeRef = new Firebase(FBURL+"/public/nodes");
    nodeRef = null

    constructor: (root) ->
      console.log "in FB", root
      nodeRef = new Firebase(FBURL+root+"nodes");

    remove : (id) ->
      nodeRef.child(id).remove()

    update : (id, hash) ->
      nodeRef.child(id).update(hash)

    push : (hash) ->
      nodeRef.push(hash)

    child_added : (cb) ->
      nodeRef.on "child_added", (snapshot) ->
        message = snapshot.val()
        cb(snapshot.name(), snapshot.val())

    child_removed : (cb) ->
      nodeRef.on "child_removed", (snapshot) ->
        cb(snapshot.name(), snapshot.val())

    child_changed : (cb) ->
      nodeRef.on "child_changed", (snapshot) ->
        cb(snapshot.name(), snapshot.val())

    FB


