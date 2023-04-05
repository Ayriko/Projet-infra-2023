module.exports = {
  apps : [{
    name   : "foundry",
    script : "./foundryvtt/resources/app/main.js",
    env: {
        "FOUNDRY_VTT_DATA_PATH": "/home/aymerico/nfs/foundrydata"
    }
  }]
}
