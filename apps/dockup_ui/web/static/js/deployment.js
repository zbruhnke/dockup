import React from "react"
import ReactDOM from "react-dom"
import DeploymentList from "./components/deployment_list"
import DeploymentForm from "./components/deployment_form"

let deployment_form_container = document.getElementById('deployment_form_container');

if (deployment_form_container) {
  ReactDOM.render(<DeploymentForm/>, deployment_form_container);
}

const Deployment = {
  mountDeploymentList: (elementId) => {
    let element = document.getElementById(elementId);
    ReactDOM.render(<DeploymentList/>, element);
  },

  mountDeploymentForm: (elementId, whitelistedUrls) => {
    let element = document.getElementById(elementId);
    ReactDOM.render(<DeploymentForm urls={whitelistedUrls}/>, element);
  }
}

export default Deployment;
