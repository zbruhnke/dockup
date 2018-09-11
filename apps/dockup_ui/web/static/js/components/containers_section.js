import React, {Component} from "react";
import cx from "classnames";

class ContainersSection extends Component {
  constructor(props) {
    super(props);

    this.state = {
      containers: this.props.containers || []
    };
  }

  componentDidMount() {
    this.connectToDeploymentChannel(this.props.deploymentId);
  }

  connectToDeploymentChannel(deploymentId) {
    const channel = DockupUiSocket.getDeploymentChannel(deploymentId);

    channel.on("status_updated", container => {
      this.updateContainerStatus(container);
    });
  }

  updateContainerStatus(update) {
    let found = false;

    const newContainers = this.state.containers.map(container => {
      if (container.id === update.id) {
        container = Object.assign({}, update);
        found = true;
      }
      return container;
    });

    if (found) {
      this.setState({
        containers: newContainers
      });
    }
  }

  renderEndpoints(endpoints) {
    if (!endpoints) {
      return null;
    }

    return endpoints.map(([endpoint, port]) => (
      <a key={port} href={`https://${endpoint}`} target="_blank">
        {endpoint}
      </a>
    ));
  }

  renderContainerStatus(name, tag, status, endpoints) {
    const truncateString = (str, length) => {
      return str.length > length ? str.substring(0, length) + "..." : str;
    };
    const icons = {
      running: "fa-check-circle",
      failed: "fa-times",
      unknown: "fa-exclamation-circle",
      pending: "fa-circle-notch"
    };
    const deploymentStatus = this.props.status;
    const renderContainersStatus = !(
      deploymentStatus === "deleting" || deploymentStatus === "deleted"
    );
    return (
      renderContainersStatus && (
        <div title={tag}>
          {name}:{truncateString(tag, 10)}({status})<i className={`fa ${icons[status]}`} />
          <div>{this.renderEndpoints(endpoints)}</div>
        </div>
      )
    );
  }

  renderContainers() {
    return this.state.containers.map(container => {
      return (
        <div
          key={container.id}
          className={cx("container-row", {
            running: container.status === "running",
            failed: container.status === "failed",
            unknown: container.status === "unknown",
            pending: container.status === "pending"
          })}
        >
          {this.renderContainerStatus(
            container.name,
            container.tag,
            container.status,
            container.endpoints
          )}

          {container.status_reason}
        </div>
      );
    });
  }

  render() {
    return (
      <div className="row">
        <div className="col">{this.renderContainers()}</div>
      </div>
    );
  }
}

export default ContainersSection;
