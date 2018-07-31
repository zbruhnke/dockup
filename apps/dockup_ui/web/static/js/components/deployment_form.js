// libraries
import React, { Component } from 'react';
import cx from 'classnames';

// helpers
import { request } from '../request';

// components
import FlashMessage from '../flash_message';
import DeploymentCard from './deployment_card';

class DeploymentForm extends Component {
  constructor(props) {
    super(props);

    // just for dev purpose, can remove once we start getting this via props;
    const response = { containerSpecs: [
      {id: 1, image: "my_frontend", defaultTag: "latest"},
      {id: 2, image: "my-backend", defaultTag: "master"}
    ]};

    this.state = {
      containerSpecs: response.containerSpecs,
      deployment: null,
      errors: {},
    }

    this.handleOnChange = this.handleOnChange.bind(this);
    this.handleOnDeploy = this.handleOnDeploy.bind(this);
  }

  componentDidMount() {
    let channel = DockupUiSocket.getDeploymentsChannel();

    channel.on("status_updated", (deployment) => {
      this.updateDeployment(deployment);
    });
  }

  updateDeployment(deployment) {
    if(this.state.deployment.id == deployment.id) {
      this.setState({ deployment });
    }
  }

  handleOnDeploy(e) {
    e.preventDefault();
    const { containerSpecs } = this.state;
    this.setState({ deployment: null });

    this.createRequest(containerSpecs)
      .then((response) => response.json())
      .then((response) => {
        this.setState({ deployment: response.data });
      })
      .catch(() => {
        FlashMessage.showMessage("danger", "Deployment cannot be queued.");
      });
  }

  createRequest(containerSpecs) {
    return request({
      url: '/api/deployments',
      method: 'POST',
      data: JSON.stringify({
        containerSpecs,
      })
    });
  }

  handleOnChange(e) {
    const { name, value } = e.target;
    const { containerSpecs, errors } = this.state;

    containerSpecs.forEach(spec => {
      if (spec.image === name) {
        spec.defaultTag = value.trim();
      }
    });

    if (!value.trim()) {
      errors[name] = `Please enter a release tag for ${name}!`
    } else {
      delete errors[name];
    }

    this.setState({
      containerSpecs,
      errors,
    });
  }

  render() {
    const { deployment, containerSpecs = [], errors } = this.state;

    return (
      <div>
        <form onSubmit={this.handleOnDeploy}>
          {containerSpecs.map((spec) => (
            <div className="form-group">
              <label htmlFor={spec.image}>{spec.image}</label>
              <input
                className={cx("form-control", {
                  error: !!errors[spec.image]
                })}
                placeholder="release tag"
                name={spec.image}
                value={spec.defaultTag}
                onChange={this.handleOnChange}
              />
              {errors[spec.image] && <span className="error">{errors[spec.image]}</span>}
            </div>
          ))}
          <input
            type="submit"
            value="Deploy"
            className={cx("btn btn-primary", {
              disabled: !!Object.keys(errors).length
            })}
          />
        </form>

        {deployment && <DeploymentCard deployment={deployment} />}
      </div>
    )
  }
}

export default DeploymentForm;
