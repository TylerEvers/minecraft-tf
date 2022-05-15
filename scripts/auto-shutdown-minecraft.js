const childProcess = require('child_process')
const RECORD_START = String.fromCharCode(30)
const NEW_CONNECTION = "joined the game"
const DISCONNECT = "left the game"
let firstConnect = false
let connectionCount = 0

// Shutdown the server 20 minutes after it starts up if no one has joined in those 20 minutes
const noPlayersTimeout = setTimeout(shutdown, 1000 * 60 * 20)

const spawnJournalCtl = (handleLog) => {
	const logs = childProcess.spawn('journalctl', [
		'-u', "minecraft@ftb-endeavour.service", 
		"-o", "json-seq", 
		"--output-fields", "MESSAGE",
		"-b",
		"-f"])
	let data = ""
	logs.stdout.on('data', (chunk) => {
		let str = chunk.toString()
		for (let i = 0; i < str.length; i++) {
			if (str[i] != RECORD_START) {
				data += str[i]
			} else if (data.length > 0) {
				const obj = JSON.parse(data.trim())
				if (obj?.MESSAGE?.length > 0) {
					handleLog(obj);
				}
				data = ""
			}
		}
	})
}

const printLog = (log) => {
	console.log(
		"\n================================================================================\n" + 
		log +
		"\n================================================================================\n"
	)
}

const printAllLogs = (log) => {
	if(log?.MESSAGE?.trim()?.length > 0) printLog(log.MESSAGE)
}

const shutdown = () => {
	childProcess.spawn('systemctl', ['stop', 'minecraft@ftb-endeavour.service'])
	childProcess.spawn('shutdown', ['-P', '+3'], { stdio: [process.stdin, process.stdout, process.stderr] })
}

const cancelShutdown = () => {
	childProcess.spawn('shutdown', ['-c'],{ stdio: [process.stdin, process.stdout, process.stderr] })
	childProcess.spawn('systemctl', ['start', 'minecraft@ftb-endeavour.service'])
}

const shutdownOnZeroConnections = (log) => {
	if (log?.MESSAGE?.includes(NEW_CONNECTION)) {
		printLog(log.MESSAGE)
		if (firstConnect == false) {
			clearTimeout(noPlayersTimeout)
			firstConnect = true
		}
		connectionCount++
		console.log(`New Conection: firstConnect ${firstConnect} connection count: ${connectionCount}`)
	}

	if (log?.MESSAGE?.includes(DISCONNECT)) {
		printLog(log.MESSAGE)
		if (connectionCount > 0) connectionCount--
		console.log(`Disconnect: firstConnect ${firstConnect} connection count: ${connectionCount}`)
		if (firstConnect && connectionCount <= 0) {
			console.log(`shutting down`)
			shutdown();
		}
	}
}

spawnJournalCtl(shutdownOnZeroConnections)
