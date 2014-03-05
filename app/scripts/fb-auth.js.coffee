define ['fb', 'main'], (FB, Mind) ->
  chatRef = new Firebase("https://incandescent-fire-4492.firebaseio.com")

  $fb = null

  auth = new FirebaseSimpleLogin chatRef, (error, user) ->
    if $fb isnt null
      $fb.off()
      console.log "$fb.off"
    $("#records li:not(:first)").remove()
    console.log "FirebaseSimpleLogin"
    if error
      # an error occurred while attempting login
      console.log error.message
      alert error.message
    else if user
      # user authenticated with Firebase
      console.log "User ID: " + user.id + ", Provider: " + user.provider
      $(".home-index-div").hide()
      $(".mind-flowy-div").show()
      $("#account").html("Welcome #{user.email}").show()
      $("#forSignup").hide()
      $("#forLogin").hide()
      $("#signout").show()
      $('#myLogin').modal('hide')
      $('#mySignup').modal('hide')
      $fb = new FB("/users/"+user.id+"/")
      new Mind($fb)
    else
      # user is logged out
      $("#account").hide()
      $("#signout").hide()
      $("#forSignup").show()
      $("#forLogin").show()
      $fb = new FB("/public/")
      new Mind($fb)

    return

  $("body").on "click", "#signup", (e) ->
    e.preventDefault()
    email = $('#semail').val()
    password = $('#spassword').val()
    auth.createUser email, password, (error, user) ->
       if !error
         auth.login 'password', {email, password}
         # user authenticated with Firebase
         console.log "User ID: " + user.id + ", Provider: " + user.provider
       else
        console.log(error)

  $("body").on "click", "#login", (e) ->
    e.preventDefault()
    email = $('#lemail').val()
    password = $('#lpassword').val()
    auth.login 'password', {email, password}

  $("body").on "click", "#signout", (e) ->
    e.preventDefault()
    auth.logout()
