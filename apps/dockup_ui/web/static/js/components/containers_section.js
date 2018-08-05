import React, {Component} from 'react';

class ContainersSection extends Component {
  constructor(props) {
    super(props);
    this.connectToDeploymentChannel(this.props.deploymentId);
    this.state = {
      containers: this.props.containers
    }
  }

  connectToDeploymentChannel(deploymentId) {
    let channel = DockupUiSocket.getDeploymentChannel(deploymentId);

    channel.on("status_updated", (container) => {
      this.updateContainerStatus(container);
    })
  }

  updateContainerStatus(update) {
    let found = false;
    let newContainers = this.state.containers.map((container) => {
      if(container.id == update.id) {
        container = Object.assign({}, update);
        found = true;
      }
      return container;
    })

    if(found) {
      this.setState({containers: newContainers})
    }
  }

  renderEndpoints(endpoints) {
    if(!endpoints) {
      return null;
    }

    endpoints = endpoints.map(([endpoint, port]) => {return(<a key={port} href={`https://${endpoint}`}>{endpoint}</a>)});
    return endpoints;
  }

  renderContainers() {
    return(
      this.state.containers.map((container) => {
        return(
          <div key={container.id}>
            {container.name}:{container.tag} ({container.status}) {this.renderEndpoints(container.endpoints)}
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
