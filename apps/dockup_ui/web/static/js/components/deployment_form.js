import React, {Component} from 'react';
import $ from 'jquery';
import GitUrlInput from './git_url_input';
import FlashMessage from '../flash_message';
import DeploymentCard from './deployment_card';

class DeploymentForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      deployment: null,
      gitUrl: "",
      branch: ""
    }

    this.handleUrlChange = this.handleUrlChange.bind(this);
    this.handleDeployClick = this.handleDeployClick.bind(this);
    this.urls = JSON.parse(this.props.urls);

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

  handleDeployClick(e) {
    this.setState({deployment: null});
    e.preventDefault();
    let xhr = this.createRequest();
    xhr.done((response) => {
      this.setState({deployment: Object.assign({}, response.data)});
    });
    xhr.fail(() => {
      FlashMessage.showMessage("danger", "Deployment cannot be queued.");
    });
  }

  createRequest() {
    return $.ajax({
      url: '/api/deployments',
      type: 'POST',
      contentType: 'application/json',
      data: JSON.stringify({
        git_url: this.state.gitUrl,
        branch: this.state.branch,
        callback_url: null
      })
    });
  }

  handleUrlChange(url) {
    this.setState({gitUrl: url});
  }

  handleBranchChange(branch) {
    this.setState({branch: branch});
  }

  validInputs() {
    return (this.state.gitUrl.length > 0 && this.state.branch.length > 0);
  }

  renderDeploymentCard() {
    if(this.state.deployment) {
      return(<DeploymentCard deployment={this.state.deployment}/>);
    }
  }

  render() {
    return (
      <div>
        <form>
          <div className="form-group">
            <label>Git URL</label>
            <GitUrlInput urls={this.urls} onUrlChange={this.handleUrlChange}/>
          </div>
          <div className="form-group">
            <label htmlFor="branch">Branch</label>
            <input className="form-control" id="branch" onChange={(event) => { this.handleBranchChange(event.target.value)}}/>
          </div>

          <button type="submit" onClick={this.handleDeployClick} disabled={!this.validInputs()} className="btn btn-primary">Deploy</button>
        </form>

        {this.renderDeploymentCard()}
      </div>
    )
  }
}

export default DeploymentForm
