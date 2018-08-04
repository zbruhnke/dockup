import React, {Component} from 'react';

class ContainersSection extends Component {
  constructor(props) {
    super(props);
    this.connectToDeploymentChannel(this.props.deploymentId);
  }

  connectToDeploymentChannel(deploymentId) {
    let channel = DockupUiSocket.getDeploymentChannel(deploymentId);

    channel.on("status_updated", (data) => {
      console.log(data);
    })
  }

  render() {
    return(
      <div className="row">
        <div className="col">
          Containers section here
        </div>
      </div>
    );
  }
}

export default ContainersSection;
