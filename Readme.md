# Steps to deploy
```
  grunt build
```

Edit dist/index.html

```
  <script src="https://cdn.firebase.com/v0/firebase-simple-login.js"></script>
  <script src="scripts/a984ab86.main.js"></script>
  <script data-main="scripts/main.min" src="scripts/20b30de2.require.js"></script>
</body>

```

Change last 2 <script>, to point to proper file
