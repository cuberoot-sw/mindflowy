(function($) {
  return $.fn.wysiwygEvt = function() {
    var $this, htmlold;
    $this = $(this);
    htmlold = $this.html();
    return $this.bind("blur keyup", function(e) {
      var htmlnew, specialKey;
      specialKey = (function() {
        switch (e.which) {
          case 38:
            return "up";
          case 40:
            return "down";
          case 9:
            if (e.shiftKey) {
              return "shiftTab";
            } else {
              return "tab";
            }
            break;
          default:
            return null;
        }
      })();
      if (specialKey || (e && e.type === "blur")) {
        console.log("wysiwygEvt: ", e.which);
        $this.trigger(specialKey, [e]);
        e.preventDefault();
        htmlnew = $this.html();
        if (htmlold !== htmlnew) {
          console.log(htmlold, htmlnew);
          if (htmlold === null || htmlold === "") {
            $this.trigger("change", ["newNode"]);
          } else if (htmlnew === null || htmlnew === "") {
            $this.trigger("delete", ["emptyNode"]);
          } else {
            $this.trigger("change", ["editedNode"]);
          }
          return htmlold = htmlnew;
        }
      }
    });
  };
})(jQuery);
