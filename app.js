const express = require('express')
var bodyParser = require('body-parser')
var parseurl = require('parseurl')
var session = require('express-session')
const app = express()
var path = require('path')

var passwords = {}

passwords['krtek'] = "noname"

app.use(express.static('.'))
//app.use('/img', express.static(__dirname + '/img'));
app.use(bodyParser.json());

app.set('trust proxy', 1) // trust first proxy
app.use(session({
    secret: 'keyboard cat',
    resave: false,
    saveUninitialized: true,
}))

app.use(function(req,res, next){
    if (!req.session.views) {
        req.session.views = {}
    }

    // get the url pathname
    var pathname = parseurl(req).pathname

    // count the views
    req.session.views[pathname] = (req.session.views[pathname] || 0) + 1

    next()
})


app.get('/foo', function(req,res, next){
    res.send('you viewed this page ' + req.session.views['/foo'] + ' times')
})

app.get('/bar', function(req,res, next){
    res.send('you viewed this page ' + req.session.views['/bar'] + ' times')
})



app.get('/', function(req,res){
    console.log("cookies: " + req.get('cookie'))
     res.sendFile(path.join(__dirname + '/index.html'))
})

app.get('/login', function(req, res){
   res.sendFile(path.join(__dirname + '/login.html'))
})


function authenticUser(req, res, cbSuccess, cbFail){

    var bodyStr = '';
    var username;
    var credentials;

    req.on("data", function(chunk){
        bodyStr += chunk.toString();
    })

    req.on('end', function(){

        credentials = getCredentials(bodyStr);

        while(!credentials){} //wait until credentials are filled which happens after function call above

        username = Object.keys(credentials)[0]

        res.cookie('username', username)


        if(passwords[username] === credentials[username]){
            cbSuccess();
        }else{
            cbFail();
        }

    })

}

function getCredentials(str){

    var response = {};
    var username;
    var password;

    params = str.split('&');
    params.forEach((param) => {
        switch(param.split('=')[0]){
            case 'username':
                username = param.split('=')[1];
                break;
            case 'password':
                password = param.split('=')[1]
                break;
            default:
                break;
        }


    })

    if( username !== undefined && password != undefined){
        response[username] = password;
    }

    return response;

}

function hasIdToken(req, res, cbSuccess, cbFail){

    if(req.get('cookie').indexOf('id_token=OK') !== -1) {
        cbSuccess();
    }else{
        cbFail();
    }
}

app.post('/login', function(req, res){

    authenticUser(req, res, function(){


        console.log("DEBUG Calling Success callback")

        res.cookie('id_token', 'OK', {expires: new Date(Date.now() + 9000000)})
        res.cookie('session', '123abc', {httpOnly: true})
        res.redirect('/treasure')
    },
        function(){

            console.log("DEBUG Calling Fail callback")

        res.redirect('/')

    });

})

app.get('/treasure', function(req, res){

    hasIdToken(req, res, function(){
        res.sendFile(path.join(__dirname + '/poklad.html'))
    }, function(){
        res.status(401).send("Unauthorized")
    })

})

app.post('/treasure', function(req,res){

    hasIdToken(req, res, function(){
        res.set('IDKEY', "KlicTotoznosti")
        res.set('SESSION_KEY', 'ClefSeance')
        res.send()
    },function(){
        res.send()
    })


})

app.get('/logout', function(req, res){

    res.cookie('id_token', 'BAD', {expires: new Date('Thu, 01 Jan 1970 00:00:00 UTC')})
    res.cookie('username', 'neznamy', {expires: new Date('Thu, 01 Jan 1970 00:00:00 UTC')})
    res.redirect('/')

})

app.post('/accounts', function(req, res) {

    console.log("reached accounts " + JSON.stringify(req.body));

    passwords[req.body.name] = req.body.password

    for (var key in passwords) {
        console.log("pwd: " + key + ":" + passwords[key])
    }

    res.send("success! " + req.body.name)

})

app.delete('/accounts', function(req,res){

    delete passwords[req.body.name];

    console.log("Deleting " + req.body.name)
    for (var key in passwords) {
        console.log("pwd: " + key + ":" + passwords[key])
    }

    res.send("deleted " + req.body.name)

})


app.listen(3000, function(){
    console.log('Example app listening on port 3000')
})
