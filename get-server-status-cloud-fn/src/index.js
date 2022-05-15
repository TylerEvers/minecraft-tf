const Query = require("minecraft-query");

const getStats = async () => {
  const q = new Query({host: process.env.DOMAIN, port: 25565, timeout: 15000});

  const stats = await q.basicStat()
  q.close()
  return stats;
}

exports.stats = async (req, res) => {
  const stats = await getStats()
  res.status(200).send(JSON.stringify(stats))
};
