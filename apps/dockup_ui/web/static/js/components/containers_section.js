import React, {Component} from 'react';
import cx from 'classnames';

class ContainersSection extends Component {
  constructor(props) {
    super(props);

    this.state = {
      containers: this.props.containers || [],
    }
  }

  componentDidMount() {
    this.connectToDeploymentChannel(this.props.deploymentId);
  }

  connectToDeploymentChannel(deploymentId) {
    const channel = DockupUiSocket.getDeploymentChannel(deploymentId);

    channel.on("status_updated", (container) => {
      this.updateContainerStatus(container);
    })
  }

  updateContainerStatus(update) {
    let found = false;

    const newContainers = this.state.containers.map((container) => {
      if(container.id === update.id) {
        container = Object.assign({}, update);
        found = true;
      }
      return container;
    });

    if(found) {
      this.setState({
        containers: newContainers,
      });
    }
  }

  renderEndpoints(endpoints) {
    if(!endpoints) {
      return null;
    }

    return endpoints.map(([endpoint, port]) => (
      <a key={port} href={`https://${endpoint}`}>
        {endpoint}
      </a>
    ));
  }

  renderContainers() {
    return(
      this.state.containers.map((container) => {
        return(
          <div
            key={container.id}
            className={cx({
              running: container.status === 'running',
              failed: container.status === 'failed',
              unknown: container.status === 'unknown',
              pending: container.status === 'pending',
            })}
          >
            {container.name}:{container.tag} ({container.status}) {this.renderEndpoints(container.endpoints)}
            {container.status_reason}
          </div>
        );
      })
    );
  }

  render() {
    return(
      <div className="row">
        <div className="col">
          {this.renderContainers()}
        </div>
      </div>
    );
  }
}

export default ContainersSection;
