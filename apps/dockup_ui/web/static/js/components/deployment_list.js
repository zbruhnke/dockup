import React, {Component} from 'react';
import createHistory from "history/createBrowserHistory"
import DeploymentCard from './deployment_card';

class DeploymentList extends Component {
  constructor(props) {
    super(props);
    this.history = createHistory()
    this.state = {
      deployments: [],
      filteredDeployments : [],
      filtersApplied: [],
    }
    this.getDeployments();
    this.connectToDeploymentsChannel();
    this.handleFilterChange = this.handleFilterChange.bind(this)
  }

  getDeployments() {
    let xhr = new XMLHttpRequest();
    xhr.open('GET', '/api/deployments');
    xhr.onload = () => {
      if (xhr.status === 200) {
        let deployments = JSON.parse(xhr.responseText).data;
        this.setState({deployments});
      }
    };
    xhr.send();
  }

  addDeployment(deployment) {
    this.setState({deployments: [deployment, ...this.state.deployments]})
  }

  connectToDeploymentsChannel() {
    let channel = DockupUiSocket.getDeploymentsChannel();

    channel.on("status_updated", (deployment) => {
      this.updateDeployment(deployment);
    })

    channel.on("deployment_created", (deployment) => {
      this.addDeployment(deployment);
    })
  }

  updateDeployment(newDeployment) {
    let found = false;
    let newDeployments = this.state.deployments.map((deployment) => {
      if(deployment.id == newDeployment.id) {
        deployment = Object.assign({}, newDeployment);
        found = true;
      }
      return deployment;
    })

    if(found) {
      this.setState({deployments: newDeployments})
    }
  }

  handleFilterChange(event, filter){
    if(!this.state.filtersApplied.includes(filter) && event.target.checked){
      const filtersApplied = [...this.state.filtersApplied, filter]
      this.setState( {filtersApplied},
        () => {
          this.filterDeployments()
          // this.pushHistory()
        })
    }
    else{
      const filtersApplied = this.state.filtersApplied.filter(filterName => filterName !== filter)
      this.setState({filtersApplied}, () => this.filterDeployments() )
    }
  }

  filterDeployments(){
    let filteredDeployments = []
    this.state.deployments.forEach(deployment =>
       this.state.filtersApplied.forEach(filter => {
         if(deployment.status ===  filter){
          filteredDeployments.push(deployment)
         }
        })
    )
    this.showAll() ? this.setState({filteredDeployments: this.state.deployments}) : this.setState({filteredDeployments})
  }


  renderFilter(){
    const filters = ["queued", "started", "hibernated", "deleted", "failed"];
    return filters.map((filter) => (
      <div key={filter} style={{display: "inline-block", padding: 5}} >
        <label className="form-check-label">{filter}</label>
        <input name={filter} type="checkbox" className="custom-checkbox" style={{padding: 5}} onChange={ (e) => this.handleFilterChange(e, filter) } checked={this.state.filtersApplied[filter]} />
      </div>
    )
    )
  }


  renderDeploymentCards(){
    if(!this.state.filtersApplied.length){
      return this.state.deployments.map(deployment => <DeploymentCard key={deployment.id} deployment={deployment} />)
    }
    return this.state.filteredDeployments.map((deployment) => <DeploymentCard key={deployment.id} deployment={deployment} />)
  }

  render() {
    return (
      <div>
        <h3 className="mb-5">Recent Deployments</h3>
        {this.renderFilter()}
        {this.renderDeploymentCards()}
      </div>
    )
  }
}

export default DeploymentList
