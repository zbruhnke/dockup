import {Socket} from "phoenix"

class DockupUiSocket {
  constructor(){
    this.initializeSocket();
  }

  initializeSocket() {
    this.socket = new Socket("/socket", {
      logger: (kind, msg, data) => {
        console.log(`${kind}: ${msg}`, data)
      }
    })
    this.socket.connect()
  }

  getDeploymentsChannel() {
    let channel = this.socket.channel("deployments:all", {});
    channel.join()
      .receive("ok", resp => { console.log("Joined deployments:all channel", resp) })
      .receive("error", resp => { console.log("Unable to join deployments:all channel", resp) })
    return channel;
  }

  getDeploymentChannel(id) {
    let channel = this.socket.channel(`deployments:${id}`, {});
    channel.join()
      .receive("ok", resp => { console.log(`Joined deployments:${id} channel`, resp) })
      .receive("error", resp => { console.log(`Unable to join deployments:${id} channel`, resp) })
    return channel;
  }

  getNotificationChannel() {
    let channel = this.socket.channel("notifications", {});
    channel.join()
      .receive("ok", resp => { console.log(`Joined notifications channel`, resp) })
      .receive("error", resp => { console.log(`Unable to join notifications channel`, resp) })
    return channel;
  }
}

window.DockupUiSocket = new DockupUiSocket();

export default DockupUiSocket;
