const compute = require('@google-cloud/compute');
/**
* Start the Minecraft server and return the external IP
*/

async function startInstance() {
    const instancesClient = new compute.InstancesClient();

    const [response] = await instancesClient.start({
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

    console.log('Instance started.');
}

const startServer = async (req, res) => {
    console.log('Starting VM');
    await startInstance()
    res.status(200).send(`
<!doctype html>
<html lang="en">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-eOJMYsd53ii+scO/bJGFsiCZc+5NDVN2yr8+0RDqr0Ql0h+rP48ckxlpbzKgwra6" crossorigin="anonymous">

    <title>Jolley's Minecraft Server</title>
  </head>
  <body>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta3/dist/js/bootstrap.bundle.min.js" integrity="sha384-JEW9xMcG8R+pH31jmWH6WWP0WintQrMb4s7ZOdauHnUtxwoG2vI5DkLtS3qm9Ekf" crossorigin="anonymous"></script>
    <script type="text/javascript">
      console.log("Status checking script loaded")
      let doneBy
      const fetchStatus = async () => {
        const url = "${process.env.SERVER_STATUS_CLOUD_FN_URL}" //https://us-central1-abstract-code-308212.cloudfunctions.net/get-server-status
        console.log("Fetching status")
        const response = await fetch(url)
        if (response.ok) {

          let json = await response.json()
          console.log("Json response:", json)
          return {
            message: "The server is up!  Connected players: " + json.online_players,
            up: true
          }
        } else {
          if (!doneBy) doneBy = Date.now() + 8 * 60 * 1000
          return {
            message: "The server is still starting up! <br> Worst case, the server will be up in " + Math.floor((doneBy - Date.now()) / 1000 / 60) + " minutes",
            up: false
          }
        }
      }
      let status
      const setStatus = async () => {
        console.log("Interval fired")
        status = await fetchStatus()
        console.log("Fetching element")
        const el = document.querySelector('#status')
        const imgEl = document.querySelector('#myimg')
        console.log("Setting status")
        if (status.up) {
          el.className = "alert alert-success"
          imgEl.src = "https://media.giphy.com/media/zCq3TyuABrRrG/giphy.gif"
        } else {
          el.className = "alert alert-warning"
          imgEl.src = "https://media.giphy.com/media/2uwZ4xi75JhxZYeyQB/giphy.gif"
        }
        el.innerHTML = "<p>" + status.message + "</p>";
      }

      setStatus();
      setInterval(setStatus, 20000)

    </script>
    <main>
    <div class="container">
    <div class="jumbotron text-center">
      <h1 class="display-4">Jolley's Minecraft Virtual Machine</h1>
      <p class="lead">The computer that runs the minecraft server is on!</p>
      <hr class="my-4">
      <div class="row">
        <img id="myimg" src="https://media.giphy.com/media/OmbyTTZGa60gM/giphy.gif" class="rounded mx-auto d-block my-5" style="width: 300px;">
      </div>
      <h3> Minecraft Server Status</h3>
      <div id="status" class="alert alert-info">
        <p> Please wait, Querying Server Status </p>
      </div>
       <p>The server address is <em>${process.env.DOMAIN}</em></p>
       <p>The server IP is <em>${process.env.IP}</em></p>
    </div>
    </div>
    </main>
    <footer class="container">
      <section class="row text-center bg-dark text-white">
        <a href="https://www.patreon.com/bePatron?u=24954938" data-patreon-widget-type="become-patron-button">Become a Patron!</a><script async src="https://c6.patreon.com/becomePatronButton.bundle.js"></script>
      </section>
    </footer>
  </body>
</html>
    `);
};

exports.startServer = startServer
