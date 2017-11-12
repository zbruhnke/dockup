import React, {Component} from 'react';
import TimeAgo from 'react-timeago';

class DeploymentCard extends Component {
  constructor(props) {
    super(props);
  }

  getGithubRepo() {
    let match = this.props.deployment.git_url.match(/https:\/\/github.com\/(.*).git/);
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
      let absoluteUrl = `//${url}`;
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
        <a href={absoluteUrl} className="btn btn-outline-primary" target="_blank">Logs</a>
      )
    }
  }

  render() {
    return(
      <div className="row mt-5">
        <div className="card border-success text-primary dockup-card">
          <div className="card-body">
            <div className="row">
              <div className="col-8">
                <h4 className="card-title display-4 dockup-card-branch">{this.props.deployment.branch}</h4>
              </div>
              <div className="col text-muted text-right dockup-card-timeago">
                <TimeAgo date={this.props.deployment.inserted_at} title={new Date(this.props.deployment.inserted_at)}/>
              </div>

            </div>

            <h6 className="card-subtitle mb-2 text-secondary">{this.getGithubRepo()}</h6>


          </div>
          <div className="card-footer dockup-card-footer">
            <div className="row">
              <div className="col-8">
                {this.renderOpenButton()}
                {this.renderLogButton()}
              </div>

              <div className="col text-right text-success dockup-card-status">
                <div>
                  {this.props.deployment.status}
                </div>

                <div>
                  <i className="fa fa-check-circle dockup-card-icon" aria-hidden="true"></i>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

export default DeploymentCard;
