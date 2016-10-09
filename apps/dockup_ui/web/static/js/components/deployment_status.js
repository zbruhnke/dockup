import React, {Component} from 'react';

class DeploymentStatus extends Component {
  constructor(props) {
    super(props);
    this.state = {
      status: null,
      payload: null
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

  /*
  When status == "started", params will be:
  status: "started",
  payload: {
    web: [{url: "foo", port: "1000"}, {url: "bar", port: "2000"}],
    app: [{url: "foo", port: "1000"}]
  }
  */
  renderServiceUrls(status, payload) {
    if(status == "started") {
      if(payload) {
        let urlText = Object.keys(payload).map((key, index) =>{
          return(
            <tr key={index}>
              <td>{key}</td>
              <td>
                <div className="btn-group btn-group-sm">
                  {payload[key].map((map, index) => {
                    return(
                      <a href={map.url} className="btn btn-default" role="button" key={index} target="_blank">Port {map.port}</a>
                    )
                  })}
                </div>
              </td>
            </tr>
          )
        })
        return urlText;
      } else {
        return (
          <tr>
            <td colSpan={2}>
              No service info available
            </td>
          </tr>
        );
      }
    }
  }

  renderServiceUrlTable() {
    if(this.state.status == "started") {
      return(
        <table className="table">
          <thead>
            <tr>
              <th>Service</th>
              <th>URLs</th>
            </tr>
          </thead>
          <tbody>
            {this.renderServiceUrls(this.state.status, this.state.payload)}
          </tbody>
        </table>
      );
    } else {
      return null;
    }
  }

  render() {
    if(!this.props.deploymentId) {
      return null;
    }

    return(
      <div className="deployment-status panel panel-default">
        {this.renderStatusText()}
        {this.renderServiceUrlTable()}
      </div>
    )
  }
}

export default DeploymentStatus;
