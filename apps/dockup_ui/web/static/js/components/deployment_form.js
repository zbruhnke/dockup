// libraries
import React, {Component} from "react";
import cx from "classnames";

// helpers
import {request} from "../request";

// components
import FlashMessage from "../flash_message";
import DeploymentCard from "./deployment_card";

class DeploymentForm extends Component {
  constructor(props) {
    super(props);

    this.state = {
      containerSpecs: this.props.containerSpecs,
      deployment: null,
      errors: {}
    };

    this.handleOnChange = this.handleOnChange.bind(this);
    this.handleOnDeploy = this.handleOnDeploy.bind(this);
  }

  componentDidMount() {
    let channel = DockupUiSocket.getDeploymentsChannel();

    channel.on("status_updated", deployment => {
      this.updateDeployment(deployment);
    });
  }

  updateDeployment(deployment) {
    if (this.state.deployment && this.state.deployment.id == deployment.id) {
      this.setState({deployment});
    }
  }

  handleOnDeploy(e) {
    e.preventDefault();
    const {containerSpecs} = this.state;
    this.setState({deployment: null});

    this.createRequest(containerSpecs)
      .then(response => response.json())
      .then(response => {
        this.setState({deployment: response});
      })
      .catch(() => {
        FlashMessage.showMessage("danger", "Deployment cannot be queued.");
      });
  }

  createRequest(containerSpecs) {
    return request({
      url: "/api/deployments",
      method: "POST",
      body: JSON.stringify({
        containerSpecs
      })
    });
  }

  handleOnChange(e) {
    const {name, value} = e.target;
    const {containerSpecs, errors} = this.state;

    containerSpecs.forEach(spec => {
      if (spec.name === name) {
        spec.tag = value.trim();
      }
    });

    if (!value.trim()) {
      errors[name] = `Please enter an image tag for ${name}`;
    } else {
      delete errors[name];
    }

    this.setState({
      containerSpecs,
      errors
    });
  }

  render() {
    const {deployment, containerSpecs = [], errors} = this.state;
    const deploymentStatus =
      deployment &&
      (deployment.status === "starting" ||
        deployment.status === "pending" ||
        deployment.status === "queued");

    return (
      <div>
        <p className="alert alert-info" role="alert">
          Fill image tags in the input fields.
        </p>
        <form onSubmit={this.handleOnDeploy} className="mb-5">
          {containerSpecs.map(spec => (
            <div className="form-group" key={spec.id}>
              <label htmlFor={spec.name}>{spec.name}</label>
              <input
                className={cx("form-control", {
                  error: !!errors[spec.name]
                })}
                placeholder="Image tag"
                name={spec.name}
                value={spec.tag}
                onChange={this.handleOnChange}
              />
              {errors[spec.name] && <span className="error">{errors[spec.name]}</span>}
            </div>
          ))}
          <button
            type="submit"
            value="Deploy"
            className={cx(
              "btn btn-primary",
              {
                disabled: !!Object.keys(errors).length || deploymentStatus
              },
              {
                "is-loading": deploymentStatus
              }
            )}
          >
            Deploy
          </button>
        </form>

        {deployment && <DeploymentCard deployment={deployment} showDetails={true} />}
      </div>
    );
  }
}

export default DeploymentForm;
