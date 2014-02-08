(($) ->
  $.fn.wysiwygEvt = ->
    $this = $(this)
    htmlold = $this.html()
    $this.bind "blur keydown", (e) ->
      specialKey = switch e.which
        when 38 then "up"
        when 40 then "down"
        when 9
          if e.shiftKey then "shiftTab"
          else "tab"
        else null

      if specialKey or e.type is "blur"
        console.log "wysiwygEvt: ", e.which
        $this.trigger specialKey, [e]
        e.preventDefault()

        htmlnew = $this.html()

        if htmlold isnt htmlnew
          console.log htmlold, htmlnew
          if htmlold is null or htmlold is ""
            $this.trigger "change", ["newNode"]
          else if htmlnew is null or htmlnew is ""
            $this.trigger "delete", ["emptyNode"]
          else
            $this.trigger "change", ["editedNode"]

          htmlold = htmlnew

) jQuery
