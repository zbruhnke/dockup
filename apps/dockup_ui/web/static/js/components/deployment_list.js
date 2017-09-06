import React, {Component} from 'react';

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

  updateDeploymentStatus(id, status, payload) {
    let found = false;
    let newDeployments = this.state.deployments.map((deployment) => {
      if(deployment.id == id) {
        deployment.status = status;
        if(status == "started") {
          deployment.urls = payload;
        }
        if(status == "starting") {
          deployment.log_url = payload;
        }
        found = true;
      }
      return deployment;
    })

    if(found) {
      this.setState({deployments: newDeployments})
    }
  }

  addDeployment(deployment) {
    this.setState({deployments: [deployment, ...this.state.deployments]});
  }

  renderDeploymentUrls(urls) {
    if(urls) {
      let urlText = urls.map((url, index) =>{
        let absoluteUrl = `http://${url}`;
        return(
          <a href={absoluteUrl} className="btn btn-default" role="button" key={index} target="_blank">Open</a>
        )
      })
      return (
        <div className="btn-group btn-group-sm">
          {urlText}
        </div>
      );
    } else {
      return "-";
    }
  }

  renderLogUrl(url) {
    if(url) {
      return <a href={url} target="_blank">Open</a>;
    } else {
      return "-";
    }
  }

  connectToDeploymentsChannel() {
    let channel = DockupUiSocket.getDeploymentsChannel();
    channel.on("status_updated", ({deployment, payload}) => {
      this.updateDeploymentStatus(deployment.id, deployment.status, payload);
    })

    channel.on("deployment_created", (deployment) => {
      this.addDeployment(deployment);
    })
  }

  render() {
    return (
      <div>
        <table className="table">
          <caption>Deployments</caption>
          <thead>
            <tr>
              <th>#</th>
              <th>Git URL</th>
              <th>Branch</th>
              <th>Status</th>
              <th>URLs</th>
              <th>Logs</th>
            </tr>
          </thead>
          <tbody>
            {this.state.deployments.map((deployment) => {
              return (
                <tr key={deployment.id}>
                  <td>{deployment.id}</td>
                  <td>{deployment.git_url}</td>
                  <td>{deployment.branch}</td>
                  <td>{deployment.status}</td>
                  <td>{this.renderDeploymentUrls(deployment.urls)}</td>
                  <td>{this.renderLogUrl(deployment.log_url)}</td>
                </tr>
              )
             })}
          </tbody>
        </table>
      </div>
    )
  }
}

export default DeploymentList
