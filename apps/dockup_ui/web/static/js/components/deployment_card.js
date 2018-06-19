import React, {Component} from 'react';
import TimeAgo from 'react-timeago';
import DeploymentStatus from './deployment_status';
import {getStatusColorClass} from '../status_colors';
import FlashMessage from '../flash_message';

class DeploymentCard extends Component {
  constructor(props) {
    super(props);
    this.handleHibernate = this.handleHibernate.bind(this);
    this.handleWakeUp = this.handleWakeUp.bind(this);
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
    if(!this.props.deployment.urls ||
       this.props.deployment.status == "hibernating_deployment" ||
       this.props.deployment.status == "deployment_hibernated" ||
       this.props.deployment.status == "waking_up_deployment") {
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
      let absoluteUrl = (url.indexOf("http") === 0 ? url : `//${url}`);
      return(
        <a href={absoluteUrl} className="btn btn-outline-primary mr-2" target="_blank">Logs</a>
      )
    }
  }

  handleHibernate(e) {
    e.preventDefault();
    let xhr = this.hibernateRequest();
    xhr.done((response) => {
      this.setState({deployment: Object.assign({}, response.data)});
    });
    xhr.fail(() => {
      FlashMessage.showMessage("danger", "Deployment cannot be hibernated.");
    });
  }

  hibernateRequest(id) {
    return $.ajax({
      url: `/api/deployments/${this.props.deployment.id}/hibernate`,
      type: 'PUT',
      contentType: 'application/json'
    });
  }

  renderHibernateButton() {
    if (this.props.deployment.status == "started") {
      return(
        <button type="button" onClick={this.handleHibernate} className="btn btn-outline-primary mr-2">Hibernate</button>
      );
    }
  }

  handleWakeUp(e) {
    e.preventDefault();
    let xhr = this.wakeUpRequest();
    xhr.done((response) => {
      this.setState({deployment: Object.assign({}, response.data)});
    });
    xhr.fail(() => {
      FlashMessage.showMessage("danger", "Deployment cannot be started.");
    });
  }

  wakeUpRequest(id) {
    return $.ajax({
      url: `/api/deployments/${this.props.deployment.id}/wake_up`,
      type: 'PUT',
      contentType: 'application/json'
    });
  }

  renderWakeUpButton() {
    if (this.props.deployment.status == "deployment_hibernated") {
      return(
        <button type="button" onClick={this.handleWakeUp} className="btn btn-outline-primary mr-2">Wake Up</button>
      );
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
                {this.renderHibernateButton()}
                {this.renderWakeUpButton()}
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
