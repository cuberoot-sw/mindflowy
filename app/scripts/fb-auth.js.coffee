chatRef = new Firebase("https://incandescent-fire-4492.firebaseio.com")

auth = new FirebaseSimpleLogin(chatRef, (error, user) ->
  console.log "FirebaseSimpleLogin"
  if error
    # an error occurred while attempting login
    console.log error.message
    alert error.message
  else if user
    # user authenticated with Firebase
    console.log "User ID: " + user.id + ", Provider: " + user.provider
    $("#account").html(user.email).show()
    $("#forSignup").hide()
    $("#forLogin").hide()
    $('#myLogin').modal('hide')
    $('#mySignup').modal('hide')
  else
    # user is logged out
    $("#account").hide()
    $("#forSignup").hide()
    $("#forSignup").show()
    $("#forLogin").show()

  return
)

$("body").on "click", "#signup", (e) ->
  e.preventDefault()
  email = $('#semail').val()
  password = $('#spassword').val()
  auth.createUser email, password, (error, user) ->
    if user
      # user authenticated with Firebase
      console.log "User ID: " + user.id + ", Provider: " + user.provider
  return false

$("body").on "click", "#login", (e) ->
  e.preventDefault()
  email = $('#lemail').val()
  password = $('#lpassword').val()
  auth.login 'password', {email, password}

$("body").on "click", "#signout", (e) ->
  e.preventDefault()
  auth.logout()
