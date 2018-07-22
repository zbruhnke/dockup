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

    channel.on("status_updated", (deployment) => {
      let found = this.state.deployments.find(d => d.id == deployment.id);
      if (found) {
        this.updateDeployment(deployment);
      } else {
        this.addDeployment(deployment);
      }
    })

    channel.on("deployment_created", (deployment) => {
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
      <div className="container">
        <div className="c-list" style={{marginTop: 150 + 'px'}}>
          <h2 className="u-cl-purple">Recent deployment</h2>
          <ul className="c-list--wrapper">
            {this.state.deployments.map((deployment) => {
              return (
                <DeploymentCard key={deployment.id} deployment={deployment}/>
              )
            })}
          </ul>
        </div>
      </div>
    )
  }
}

export default DeploymentList
