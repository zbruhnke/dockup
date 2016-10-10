import React from "react"
import ReactDOM from "react-dom"
import DeploymentList from "./components/deployment_list"
import DeploymentForm from "./components/deployment_form"

let deployments_list_container = document.getElementById('deployments_list_container');
let deployment_form_container = document.getElementById('deployment_form_container');

if (deployments_list_container) {
  ReactDOM.render(<DeploymentList/>, deployments_list_container);
}

if (deployment_form_container) {
  ReactDOM.render(<DeploymentForm/>, deployment_form_container);
}
