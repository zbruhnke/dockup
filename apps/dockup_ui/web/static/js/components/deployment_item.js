import React, {Component} from 'react';
import DeploymentCard from './deployment_card';

class DeploymentItem extends Component {
  constructor(props) {
    super(props);
    this.state = {deployment: this.props.deployment};
    this.connectToDeploymentsChannel();
  }

  connectToDeploymentsChannel() {
    let channel = DockupUiSocket.getDeploymentsChannel();

    channel.on("status_updated", ({deployment, _payload}) => {
      this.updateDeployment(deployment);
    })
  }

  updateDeployment(newDeployment) {
    if(this.state.deployment.id == newDeployment.id) {
      this.setState({deployment: Object.assign({}, newDeployment)});
    }
  }

  renderDeploymentCard() {
    if(this.state.deployment) {
      return(<DeploymentCard deployment={this.state.deployment} csrfToken={this.props.csrfToken}/>);
    }
  }

  render() {
    return (
      <div>
        {this.renderDeploymentCard()}
      </div>
    )
  }
}

export default DeploymentItem;
