import React from "react"
import ReactDOM from "react-dom"
import DeploymentList from "./components/deployment_list"
import DeploymentItem from "./components/deployment_item"
import DeploymentForm from "./components/deployment_form"
import FlashMessage from "./flash_message"

let deployment_form_container = document.getElementById('deployment_form_container');

let connectToNotificationChannel = () => {
  let channel = DockupUiSocket.getNotificationChannel();

  channel.on("notification", (data) => {
    FlashMessage.showMessage(data.type, data.message);
  })
}

if (deployment_form_container) {
  ReactDOM.render(<DeploymentForm/>, deployment_form_container);
}

connectToNotificationChannel();

const Deployment = {
  mountDeploymentList: (elementId) => {
    let element = document.getElementById(elementId);
    ReactDOM.render(<DeploymentList/>, element);
  },

  mountDeploymentForm: (elementId, container_specs_json) => {
    let element = document.getElementById(elementId);
    let container_specs = JSON.parse(container_specs_json);
    ReactDOM.render(<DeploymentForm containerSpecs={container_specs}/>, element);
  },

  mountDeploymentItem: (elementId, deploymentJSON) => {
    let element = document.getElementById(elementId);
    let deployment = JSON.parse(deploymentJSON);
    ReactDOM.render(<DeploymentItem deployment={deployment}/>, element);
  },
}

export default Deployment;
