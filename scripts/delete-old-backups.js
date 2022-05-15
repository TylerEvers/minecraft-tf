const fs = require('fs');
const ONE_WEEK = 1000 * 60 * 60 * 24 * 7

const getFiles = async () => {
	const dir = "/opt/minecraft/ftb-endeavour/backups"
	return new Promise((resolve, reject) => {
		fs.readdir(dir, (err, files) => {
			if (err) reject(err)
			else resolve(files)
		}) 
	})
}

const deleteFile = async (file) => {
	const dir = "/opt/minecraft/ftb-endeavour/backups/"
	return new Promise((resolve, reject) => {
		fs.unlink(dir + file, (err) => {
			if (err) reject(err)
			else resolve()
		}) 
	})
}

const parseFileDate = (strDate) => {
	const parts = strDate.split('-').map(s => parseInt(s, 10))
	return new Date(parts[0], parts[1] - 1, parts[2])
}

const removeOldFiles = async () => {
	const date = new Date()
	const files = await getFiles()
	const filesToDelete = files.filter(f => {
		const fDate = parseFileDate(f);
		return date - fDate > ONE_WEEK
	})

	console.log("Deleting the following files:")
	console.log(filesToDelete)

	const deletions = filesToDelete.map(deleteFile)
	await Promise.all(deletions)
}

removeOldFiles();

// 2021-03-27-08-41-54.zip
//



