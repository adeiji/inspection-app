var express = require('express');
var ParseServer = require('parse-server').ParseServer;

var app = express();
var api = new ParseServer({
	databaseURI: 'mongodb://dephyned:6Ab7boy!!@ds019668.mlab.com:19668/heroku_3cmsq8c3',
	cloud: './cloud/main.js',
	appId: 'pXYoDYstnZ7wvICh2nNtxmAwegOpjhsdRpFjNoVE',
	masterKey: '8And2LPBtbDL4beX8a9scdIikf0aLTEjCs1pxjcl',
	serverURL: 'http://localhost:1337'
});

app.use('/parse', api);
app.listen(1337, function () {
	console.log('parse-server-example running on port 1337.');
});