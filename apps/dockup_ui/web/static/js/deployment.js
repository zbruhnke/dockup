import React from "react"
import ReactDOM from "react-dom"
import DeploymentList from "./components/deployment_list"
import DeploymentItem from "./components/deployment_item"
import DeploymentForm from "./components/deployment_form"

let deployment_form_container = document.getElementById('deployment_form_container');

if (deployment_form_container) {
  ReactDOM.render(<DeploymentForm/>, deployment_form_container);
}

const Deployment = {
  mountDeploymentList: (elementId, csrfToken) => {
    let element = document.getElementById(elementId);
    ReactDOM.render(<DeploymentList csrfToken={csrfToken}/>, element);
  },

  mountDeploymentForm: (elementId, repositories, csrfToken) => {
    let element = document.getElementById(elementId);
    ReactDOM.render(<DeploymentForm urls={repositories} csrfToken={csrfToken}/>, element);
  },

  mountDeploymentItem: (elementId, deploymentJSON, csrfToken) => {
    let element = document.getElementById(elementId);
    let deployment = JSON.parse(deploymentJSON);
    ReactDOM.render(<DeploymentItem deployment={deployment} csrfToken={csrfToken}/>, element);
  },
}

export default Deployment;
