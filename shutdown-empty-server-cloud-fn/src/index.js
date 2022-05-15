import axios from 'axios';
import compute from '@google-cloud/compute';

/**
 * Responds to any HTTP request.
 *
 * @param {!express:Request} req HTTP request context.
 * @param {!express:Response} res HTTP response context.
 */

const fetchStatus = async () => {
  const url = process.env.SERVER_STATUS_CLOUD_FN_URL
  console.log("Fetching status")
  try {
  return await axios.get(url)
    .then(response => {
      // handle success
      console.log(response.status);
      console.log(response.data);
      return {
        players: response.data.online_players,
        up: true
      }
    })
    .catch(function (error) {
      console.log("Server Offline")
      return {
        players: 0,
        up: false
      }
   })
   } catch (e) {
     console.log("Outer try catch: Server Offline")
      return {
        players: 0,
        up: false
      }
   }
}

async function stopInstance() {
    const instancesClient = new compute.InstancesClient();

    const [response] = await instancesClient.stop({
        project: process.env.PROJECT_ID,
        zone: process.env.ZONE,
        instance: process.env.COMPUTE_INSTANCE,
    });

    let operation = response.latestResponse;
    const operationsClient = new compute.ZoneOperationsClient();

    // Wait for the operation to complete.
    while (operation.status !== 'DONE') {
        [operation] = await operationsClient.wait({
            operation: operation.name,
            project: process.env.PROJECT_ID,
            zone: operation.zone.split('/').pop(),
        });
    }

    console.log('Instance stopped.');
}

export const shutdownWhenNotInUse = async (req, res) => {

  try {
  let message = ""
  console.log("Fetching Minecraft server status")
  const {up, players} = await fetchStatus()
  if (up && players < 1) {
    console.log('Stoping VM');
    await stopInstance()
    message = "Empty server was running, now it's shutdown";
  } else {
    message = `No action required. Up: ${up} Players: ${players}`
    console.log(message)
  }
    res.status(200).send(message);
  } catch (e) {
    console.error("shutdownWhenNotInUse failed")
    console.error(e)
    message = "Failed to shutdownWhenNotInUse"
    res.status(500).send(message)
  }
};
