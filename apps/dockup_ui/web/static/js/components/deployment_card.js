import React, {Component} from 'react';
import TimeAgo from 'react-timeago';
import DeploymentStatus from './deployment_status';
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
    // TODO: these status checks can be removed if the urls are cleared on hibernation
    if(!this.props.deployment.urls ||
       this.props.deployment.status == "deleted" ||
       this.props.deployment.status == "hibernating" ||
       this.props.deployment.status == "hibernated" ||
       this.props.deployment.status == "waking_up") {
      return null;
    }

    let [url] = this.props.deployment.urls;
    if(url) {
      let absoluteUrl = `http://${url}`;
      return(
        <a href={absoluteUrl} className="c-btn c-btn--primary" target="_blank">Open</a>
      )
    }
  }

  renderLogButton() {
    let url = this.props.deployment.log_url;
    if(url) {
      let absoluteUrl = (url.indexOf("http") === 0 ? url : `//${url}`);
      return(
        <a href={absoluteUrl} className="c-btn c-btn--ghost" target="_blank">Logs</a>
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
        <a className="c-btn c-btn--ghost" onClick={this.handleHibernate}>Hibernate</a>
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
    if (this.props.deployment.status == "hibernated") {
      return(
        <a onClick={this.handleWakeUp} className="c-btn c-btn--ghost">Wake Up</a>
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
    if(this.props.deployment.status != "deleted" && this.props.deployment.status != "deleting") {
      return(
        <a onClick={this.handleDelete} className="c-btn c-btn--ghost">Delete</a>
      );
    }
  }

  render() {
    let deleted = this.props.deployment.status == "deleted" ? "is-deleted" : "";

    return(
      <li className={"c-list--item " + deleted}>
        <DeploymentStatus status={this.props.deployment.status}/>
        <span className="c-list--name">
          <h3>
            {this.props.deployment.branch}
            <span className="c-pill c-pill--slate">
              <TimeAgo date={this.props.deployment.inserted_at} title={new Date(this.props.deployment.inserted_at)}/>
            </span>
          </h3>
          <p>{this.getGithubRepo()}</p>
        </span>
        <span className="c-list--action">
          {this.renderHibernateButton()}
          {this.renderWakeUpButton()}
          {this.renderDeleteButton()}
          {this.renderLogButton()}
          {this.renderOpenButton()}
        </span>
      </li>
    );
  }
}

export default DeploymentCard;
