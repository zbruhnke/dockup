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

    channel.on("status_updated", (deployment) => {
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
    this.setState({branch: branch.trim()});
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
    <div className="c-header--dockup">
      <div className="c-container">
        <div className="c-header--dockup-form">
            <form className="c-form">
              <div className="c-form-group">
                <GitUrlInput urls={this.urls} onUrlChange={this.handleUrlChange}/>
              </div>
              <div className="c-form-group">
                <input className="c-form-control" placeholder="Git branch" id="branch" onChange={
                  (event) => { this.handleBranchChange(event.target.value)}
                } />
                <img className="c-form-icon" src="/icons/icon-branch.svg" />
              </div>
              <div className="u-mt-20">
                <button type="submit" onClick={this.handleDeployClick} disabled={!this.validInputs()} className="c-btn c-btn--primary c-btn--block">Deploy</button>
              </div>
            </form>

          </div>
        </div>
      </div>
    )
  }
}

export default DeploymentForm
