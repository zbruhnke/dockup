import React from "react"
import ReactDOM from "react-dom"
import DeploymentList from "./components/deployment_list"
import DeploymentForm from "./components/deployment_form"
import DeploymentStatus from "./components/deployment_status"

let deployment_form_container = document.getElementById('deployment_form_container');

if (deployment_form_container) {
  ReactDOM.render(<DeploymentForm/>, deployment_form_container);
}

const Deployment = {
  mountDeploymentList: (elementId) => {
    let element = document.getElementById(elementId);
    ReactDOM.render(<DeploymentList/>, element);
  },

  mountDeploymentForm: (elementId) => {
    let element = document.getElementById(elementId);
    ReactDOM.render(<DeploymentForm/>, element);
  },

  mountDeploymentItem: (elementId, deploymentId, status, payload) => {
    let element = document.getElementById(elementId);
    ReactDOM.render(
      <DeploymentStatus
        deploymentId={deploymentId}
        status={status}
        payload={payload}
      />,
      element
    );
  }
}

export default Deployment;
