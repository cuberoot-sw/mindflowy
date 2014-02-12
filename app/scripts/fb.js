define(function() {
  var FB;
  return FB = (function() {
    var FBURL, nodeRef;

    FBURL = "https://incandescent-fire-4492.firebaseio.com";

    nodeRef = null;

    function FB(root) {
      console.log("in FB", root);
      nodeRef = new Firebase(FBURL + root + "nodes");
    }

    FB.prototype.remove = function(id) {
      return nodeRef.child(id).remove();
    };

    FB.prototype.update = function(id, hash) {
      return nodeRef.child(id).update(hash);
    };

    FB.prototype.push = function(hash) {
      return nodeRef.push(hash);
    };

    FB.prototype.child_added = function(cb) {
      return nodeRef.on("child_added", function(snapshot) {
        var message;
        message = snapshot.val();
        return cb(snapshot.name(), snapshot.val());
      });
    };

    FB.prototype.child_removed = function(cb) {
      return nodeRef.on("child_removed", function(snapshot) {
        return cb(snapshot.name(), snapshot.val());
      });
    };

    FB.prototype.child_changed = function(cb) {
      return nodeRef.on("child_changed", function(snapshot) {
        return cb(snapshot.name(), snapshot.val());
      });
    };

    FB;

    return FB;

  })();
});
