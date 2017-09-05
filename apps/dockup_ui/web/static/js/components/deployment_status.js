import React, {Component} from 'react';

class DeploymentStatus extends Component {
  constructor(props) {
    super(props);
    let payload = props.payload ? JSON.parse(props.payload) : null;
    this.state = {
      status: props.status,
      payload: payload
    };
    this.connectToDeploymentsChannel();
  }

  connectToDeploymentsChannel() {
    let channel = DockupUiSocket.getDeploymentsChannel();
    channel.on("status_updated", ({deployment, payload}) => {
      if(deployment.id === this.props.deploymentId) {
        this.setState({status: deployment.status, payload: payload})
      }
    })

    channel.on("deployment_created", (deployment) => {
      if(deployment.id === this.props.deploymentId) {
        this.setState({status: "queued"});
      }
    })
  }

  renderStatusText() {
    let status = this.state.status;
    let statusText = null;
    let alertClass = "info";

    switch (status) {
      case 'queued':
        statusText = "Queued for deployment..";
        break;
      case 'cloning_repo':
        statusText = "Cloning repository..";
        break;
      case 'starting':
        statusText = "Starting services..";
        break;
      case 'checking_urls':
        statusText = "Waiting for URLs to be ready..";
        break;
      case 'started':
        statusText =
          <span>
            Deployed and running. Access application logs <a href={`/deployment_logs/#?projectName=${this.props.deploymentId}`} target="_blank">here</a>.
          </span>
        alertClass = "success";
        break;
      case 'deployment_failed':
        statusText = "Deployment failed";
        alertClass = "danger";
        break;
      default:
        statusText = "Deploying..";
    }
    return (
      <div className={`alert alert-${alertClass}`}>
        <p>
          {statusText}
        </p>
      </div>
    );
  }

  renderServiceUrls(status, payload) {
    if(status == "started") {
      if(payload) {
        let urlText = payload.map((url, index) => {
          let absoluteUrl = `//${url}`;
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
        return (
          <div>
            URLs not yet available
          </div>
        );
      }
    }
  }

  render() {
    if(!this.props.deploymentId) {
      return null;
    }

    return(
      <div className="deployment-status panel panel-default">
        {this.renderStatusText()}
        {this.renderServiceUrls(this.state.status, this.state.payload)}
      </div>
    )
  }
}

export default DeploymentStatus;
