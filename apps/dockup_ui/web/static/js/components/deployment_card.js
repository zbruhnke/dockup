import React, {Component} from "react";
import TimeAgo from "react-timeago";
import DeploymentStatus from "./deployment_status";
import {getStatusColorClass} from "../status_colors";
import FlashMessage from "../flash_message";
import ContainersSection from "./containers_section";

class DeploymentCard extends Component {
  constructor(props) {
    super(props);
    this.handleHibernate = this.handleHibernate.bind(this);
    this.handleWakeUp = this.handleWakeUp.bind(this);
    this.handleDelete = this.handleDelete.bind(this);
  }

  handleHibernate(e) {
    e.preventDefault();
    let xhr = this.hibernateRequest();
    xhr.done(response => {
      this.setState({deployment: Object.assign({}, response.data)});
    });
    xhr.fail(() => {
      FlashMessage.showMessage("danger", "Deployment cannot be hibernated.");
    });
  }

  hibernateRequest(id) {
    return $.ajax({
      url: `/api/deployments/${this.props.deployment.id}/hibernate`,
      type: "PUT",
      beforeSend: xhr => {
        xhr.setRequestHeader("x-csrf-token", window.csrfToken);
      },
      contentType: "application/json"
    });
  }

  renderHibernateButton() {
    if (this.props.deployment.status == "started") {
      return (
        <button
          type="button"
          onClick={this.handleHibernate}
          className="btn btn-sm btn-outline-primary mr-2"
        >
          Hibernate
        </button>
      );
    }
  }

  renderDetailsButton() {
    if (!this.props.showDetails && !(this.props.deployment.status == "deleted")) {
      return (
        <a
          href={`/deployments/${this.props.deployment.id}`}
          className="btn btn-sm btn-outline-info mr-2"
        >
          Details
        </a>
      );
    }
  }

  renderContainersSection() {
    if (!this.props.showDetails) {
      return null;
    }

    return (
      <ContainersSection
        containers={this.props.deployment.containers}
        deploymentId={this.props.deployment.id}
      />
    );
  }

  handleWakeUp(e) {
    e.preventDefault();
    let xhr = this.wakeUpRequest();
    xhr.done(response => {
      this.setState({deployment: Object.assign({}, response.data)});
    });
    xhr.fail(() => {
      FlashMessage.showMessage("danger", "Deployment cannot be started.");
    });
  }

  wakeUpRequest(id) {
    return $.ajax({
      url: `/api/deployments/${this.props.deployment.id}/wake_up`,
      type: "PUT",
      beforeSend: xhr => {
        xhr.setRequestHeader("x-csrf-token", window.csrfToken);
      },
      contentType: "application/json"
    });
  }

  renderWakeUpButton() {
    if (this.props.deployment.status == "hibernated") {
      return (
        <button
          type="button"
          onClick={this.handleWakeUp}
          className="btn btn-sm btn-outline-primary mr-2"
        >
          Wake Up
        </button>
      );
    }
  }

  handleDelete(e) {
    e.preventDefault();
    let xhr = this.deleteRequest();
    xhr.done(response => {
      this.setState({deployment: Object.assign({}, response.data)});
    });
    xhr.fail(() => {
      FlashMessage.showMessage("danger", "Deployment cannot be deleted.");
    });
  }

  deleteRequest(id) {
    return $.ajax({
      url: `/api/deployments/${this.props.deployment.id}`,
      type: "DELETE",
      beforeSend: xhr => {
        xhr.setRequestHeader("x-csrf-token", window.csrfToken);
      },
      contentType: "application/json"
    });
  }

  renderDeleteButton() {
    if (this.props.deployment.status != "deleted" && this.props.deployment.status != "deleting") {
      return (
        <button
          type="button"
          onClick={this.handleDelete}
          className="btn btn-sm  btn-outline-danger"
        >
          Delete
        </button>
      );
    }
  }

  render() {
    let statusClass = getStatusColorClass(this.props.deployment.status);
    let borderClass = `border-${statusClass}`;
    let textClass = `text-${statusClass}`;
    return (
      <div className="mb-5">
        <div className={`card ${borderClass} ${textClass} dockup-card`}>
          <div className="card-body">
            <div className="row">
              <div className="col-8">
                <h4 className="card-title display-4 dockup-card-branch">
                  {this.props.deployment.name}
                  <i className="fa fa-code-branch" />
                </h4>
              </div>
              <div className="col text-right dockup-card-timeago">
                <TimeAgo
                  date={this.props.deployment.inserted_at}
                  title={new Date(this.props.deployment.inserted_at)}
                />
              </div>
            </div>

            <h6 className="card-subtitle mb-2">{this.props.deployment.blueprint_name}</h6>

            {this.renderContainersSection()}
          </div>
          <div className="card-footer dockup-card-footer">
            <div className="row">
              <div className="col-8">
                {this.renderDetailsButton()}
                {this.renderHibernateButton()}
                {this.renderWakeUpButton()}
                {this.renderDeleteButton()}
              </div>

              <DeploymentStatus status={this.props.deployment.status} />
            </div>
          </div>
        </div>
      </div>
    );
  }
}

export default DeploymentCard;
