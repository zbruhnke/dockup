import React, {Component} from 'react';
import $ from 'jquery';
import GitUrlInput from './git_url_input';
import FlashMessage from '../flash_message';
import DeploymentStatus from './deployment_status';

class DeploymentForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      deploymentId: null,
      gitUrl: "",
      branch: ""
    }

    this.handleUrlChange = this.handleUrlChange.bind(this);
    this.urls = JSON.parse(this.props.urls);
  }

  handleDeployClick(e) {
    e.preventDefault();
    let xhr = this.createRequest();
    xhr.done((response) => {
      this.setState({deploymentId: response.data.id})
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

          <button type="submit" onClick={this.handleDeployClick.bind(this)} disabled={!this.validInputs()} className="btn btn-default">Deploy</button>
        </form>

        <DeploymentStatus deploymentId={this.state.deploymentId}/>
      </div>
    )
  }
}

export default DeploymentForm
