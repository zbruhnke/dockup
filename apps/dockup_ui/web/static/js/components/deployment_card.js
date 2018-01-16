import React, {Component} from 'react';
import TimeAgo from 'react-timeago';
import DeploymentStatus from './deployment_status';
import {getStatusColorClass} from '../status_colors';
import FlashMessage from '../flash_message';

class DeploymentCard extends Component {
  constructor(props) {
    super(props);
    this.handleDelete = this.handleDelete.bind(this);
  }

  getGithubRepo() {
    let match = this.props.deployment.git_url.match(/.*[:\/](.*\/.*).git/)
    if(match) {
      let [_, repo] = match;
      return repo;
    } else {
      return "";
    }
  }

  renderOpenButton() {
    if(!this.props.deployment.urls) {
      return null;
    }

    let [url] = this.props.deployment.urls;
    if(url) {
      let absoluteUrl = `http://${url}`;
      return(
        <a href={absoluteUrl} className="btn btn-outline-primary mr-2" target="_blank">Open</a>
      )
    }
  }

  renderLogButton() {
    let url = this.props.deployment.log_url;
    if(url) {
      let absoluteUrl = `//${url}`;
      return(
        <a href={absoluteUrl} className="btn btn-outline-primary mr-2" target="_blank">Logs</a>
      )
    }
  }

  handleDelete(e) {
    e.preventDefault();
    let xhr = this.deleteRequest();
    xhr.done((response) => {
      this.setState({deployment: Object.assign({}, response.data)});
    });
    xhr.fail(() => {
      FlashMessage.showMessage("danger", "Deployment cannot be deleted.");
    });
  }

  deleteRequest(id) {
    return $.ajax({
      url: `/api/deployments/${this.props.deployment.id}`,
      type: 'DELETE',
      contentType: 'application/json'
    });
  }

  renderDeleteButton() {
    if(this.props.deployment.status != "deployment_deleted" && this.props.deployment.status != "deleting_deployment") {
      return(
        <button type="button" onClick={this.handleDelete} className="btn btn-outline-danger">Delete</button>
      );
    }
  }

  render() {
    let statusClass = getStatusColorClass(this.props.deployment.status);
    let borderClass = `border-${statusClass}`;
    let textClass = `text-${statusClass}`;
    return(
      <div className="row mt-5">
        <div className={`card ${borderClass} ${textClass} dockup-card`}>
          <div className="card-body">
            <div className="row">
              <div className="col-8">
                <h4 className="card-title display-4 dockup-card-branch">{this.props.deployment.branch}</h4>
              </div>
              <div className="col text-right dockup-card-timeago">
                <TimeAgo date={this.props.deployment.inserted_at} title={new Date(this.props.deployment.inserted_at)}/>
              </div>

            </div>

            <h6 className="card-subtitle mb-2">{this.getGithubRepo()}</h6>


          </div>
          <div className="card-footer dockup-card-footer">
            <div className="row">
              <div className="col-8">
                {this.renderOpenButton()}
                {this.renderLogButton()}
                {this.renderDeleteButton()}
              </div>

              <DeploymentStatus status={this.props.deployment.status}/>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

export default DeploymentCard;
