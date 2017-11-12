import React, {Component} from 'react';
import DeploymentCard from './deployment_card';

class DeploymentList extends Component {
  constructor(props) {
    super(props);
    this.state = {
      deployments: []
    }
    this.getDeployments();
    this.connectToDeploymentsChannel();
  }

  getDeployments() {
    let xhr = new XMLHttpRequest();
    xhr.open('GET', '/api/deployments');
    xhr.onload = () => {
      if (xhr.status === 200) {
        let deployments = JSON.parse(xhr.responseText).data;
        this.setState({deployments});
      }
    };
    xhr.send();
  }

  addDeployment(deployment) {
    this.setState({deployments: [deployment, ...this.state.deployments]});
  }

  connectToDeploymentsChannel() {
    let channel = DockupUiSocket.getDeploymentsChannel();

    channel.on("status_updated", ({deployment, _payload}) => {
      this.updateDeployment(deployment);
    })

    channel.on("deployment_created", (deployment) => {
      console.log("Deployment created");
      this.addDeployment(deployment);
    })
  }

  updateDeployment(newDeployment) {
    let found = false;
    let newDeployments = this.state.deployments.map((deployment) => {
      if(deployment.id == newDeployment.id) {
        deployment = Object.assign({}, newDeployment);
        found = true;
      }
      return deployment;
    })

    if(found) {
      this.setState({deployments: newDeployments})
    }
  }

  render() {
    return (
      <div>
        {this.state.deployments.map((deployment) => {
          return (
            <DeploymentCard key={deployment.id} deployment={deployment}/>
          )
         })}
      </div>
    )
  }
}

export default DeploymentList
