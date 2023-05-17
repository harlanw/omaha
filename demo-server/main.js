const http		= require('http')
const express	= require('express')
const hbs			= require('express-handlebars')
const path		= require('path')

const app			= express()
const server	= http.createServer(app)
const io			= require('socket.io').listen(server)

const SMSMessageTypes = {
	SENDER: 's',
	RECEIVER: 'r'
}

class SMSMessage {
	constructor(type, body) {
		this.type = type;
		this.body = body;
	}
}

const HIDEventTypes = {
	PRESSED: 1,
	RELEASE: 0
}

class HIDEvent {
	constructor(state, key) {
		this.state = state;
		this.key = key;
	}
}

app.engine('.hbs', hbs({
	defaultLayout: 'main',
	extname: '.hbs',
	layoutsDir: path.join(__dirname, 'views/layouts')
}))

app.set('view engine', '.hbs')
app.set('views', path.join(__dirname, 'views'))
app.set('port', process.env.PORT || 3000)

app.use(express.static(__dirname + '/public'))

var messages = [
	new SMSMessage(SMSMessageTypes.SENDER, "This is a test message.")
]

app.get('/', (req, res) => {
	res.render('home', {
		messages: messages,
		time: Date.now()
	})
})

const i2c = require('i2c-bus')
const kbd = i2c.openSync(2)

kbd.writeByteSync(0x34, 0x49, 0x7F)
kbd.writeByteSync(0x34, 0x4A, 0x1F)
kbd.writeByteSync(0x34, 0x4D, 0x80)

function pollI2CBus(socket) {
	const stat = kbd.readByteSync(0x34, 0x02) & 0x1F

	if (stat != 0) {
		const _event = kbd.readByteSync(0x34, 0x03)
		const _state = (_event & 0x80) >> 7
		const _ident = _event & 0x7F

		var key = ''

		switch (_ident) {
			case 0x01: key = 'Q'; break;
			case 0x0C: key = 'W'; break;
			case 0x02: key = 'E'; break;
			case 0x03: key = 'R'; break;
			case 0x04: key = 'U'; break;
			case 0x05: key = 'O'; break;
			case 0x0D: key = 'S'; break;
			case 0x18: key = 'D'; break;
			case 0x19: key = 'T'; break;
			case 0x1A: key = 'Y'; break;
			case 0x1B: key = 'I'; break;
			case 0x22: key = 'A'; break;
			case 0x23: key = 'P'; break;
			case 0x45: key = 'F'; break;
			case 0x0E: key = 'G'; break;
			case 0x0F: key = 'H'; break;
			case 0x46: key = 'J'; break;
			case 0x47: key = 'K'; break;
			case 0x10: key = 'L'; break;
			case 0x26: key = 'DEL'; break;
			case 0x2D: key = 'ALT'; break;
			case 0x39: key = 'Z'; break;
			case 0x2E: key = 'X'; break;
			case 0x3A: key = 'C'; break;
			case 0x2F: key = 'V'; break;
			case 0x30: key = 'B'; break;
			case 0x3B: key = 'N'; break;
			case 0x3C: key = 'M'; break;
			case 0x31: key = '$'; break;
			case 0x25: key = 'RET'; break;
			case 0x44: key = 'LUP'; break;
			case 0x43: key = 'MIC'; break;
			case 0x38: key = ' '; break;
			case 0x17: key = 'SYM'; break;
			case 0x24: key = 'RUP'; break;
		}

		socket.emit('newHIDEvent', new HIDEvent(_state, key))
	}
}

const { spawn } = require('child_process')
const child = spawn('/home/omaha/server/smsbus', [], {})

child.stdout.on('data', function (data) {
	console.log("child: " + data.toString())
})

server.listen(8000)

io.sockets.on('connection', function(socket) {
	console.log('Client connected')

	socket.on('sendMessage', function(msg) {
		console.log(msg)
	})

	const len = messages.length;
	for (var i = 0; i < len; i++) {
		socket.emit('newSMSMessage', new SMSMessage(messages[i].type, messages[i].body))
	}

	setInterval(function () { pollI2CBus(socket) }, 50)

	socket.on('sendSMSMessage', function (msg) {
		const cmd = "send 2543400693 " + msg.body + '\n'
		child.stdin.write(cmd)
	})

	const fs = require('fs');
	const readline = require('readline');
	const {google} = require('googleapis');

	const SCOPES = ['https://www.googleapis.com/auth/gmail.readonly'];
	const TOKEN_PATH = 'token.json';

	// Load client secrets from a local file.
	fs.readFile('credentials.json', (err, content) => {
		if (err) return console.log('Error loading client secret file:', err);
		// Authorize a client with credentials, then call the Gmail API.
		setInterval( function() {
			authorize(JSON.parse(content), getRecentEmail)
		}, 30*1000)
	});

	function authorize(credentials, callback) {
		const {client_secret, client_id, redirect_uris} = credentials.installed;
		const oAuth2Client = new google.auth.OAuth2(
				client_id, client_secret, redirect_uris[0]);

		// Check if we have previously stored a token.
		fs.readFile(TOKEN_PATH, (err, token) => {
			if (err) return getNewToken(oAuth2Client, callback);
			oAuth2Client.setCredentials(JSON.parse(token));
			callback(oAuth2Client);
		});
	}

	function getNewToken(oAuth2Client, callback) {
		const authUrl = oAuth2Client.generateAuthUrl({
			access_type: 'offline',
			scope: SCOPES,
		});
		console.log('Authorize this app by visiting this url:', authUrl);
		const rl = readline.createInterface({
			input: process.stdin,
			output: process.stdout,
		});
		rl.question('Enter the code from that page here: ', (code) => {
			rl.close();
			oAuth2Client.getToken(code, (err, token) => {
				if (err) return console.error('Error retrieving access token', err);
				oAuth2Client.setCredentials(token);
				// Store the token to disk for later program executions
				fs.writeFile(TOKEN_PATH, JSON.stringify(token), (err) => {
					if (err) return console.error(err);
					console.log('Token stored to', TOKEN_PATH);
				});
				callback(oAuth2Client);
			});
		});
	}

	function getRecentEmail(auth) {
		const gmail = google.gmail({version: 'v1', auth});
		// Only get the recent email - 'maxResults' parameter
		gmail.users.messages.list({auth: auth, userId: 'me', maxResults: 1,}, function(err, response) {
			if (err) {
				console.log('The API returned an error: ' + err);
				return;
			}

			var message_id = response['data']['messages'][0]['id'];

			// Retreive the actual message using the message id
			gmail.users.messages.get({
				auth: auth,
				userId: 'waldroha@oregonstate.edu',
				'id': message_id
			}, function(err, response) {
				if (err) {
					console.log('The API returned an error: ' + err);
					return;
				}

				const headers = response['data']['payload']['headers'];
				const len = headers.length;
				for (var i = 0; i < len; i++) {
					if (headers[i].name == 'Subject') {
						socket.emit('newEmailEvent', headers[i].value)
					}
				}
			});
		});
	}
})
