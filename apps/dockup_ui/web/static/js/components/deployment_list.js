import React, {Component} from 'react';
import DeploymentCard from './deployment_card';

class DeploymentList extends Component {
  constructor(props) {
    super(props);
    this.state = {
      deployments: [],
      filteredDeployments : [],
      currentPageDeployments:[],
      filterBy: "all",
      currentPage: 1,
      itemsPerPage: 10
    }
    this.getDeployments();
    this.connectToDeploymentsChannel();
    this.handleFilterChange = this.handleFilterChange.bind(this)
    this.changeitemsPerPage = this.changeitemsPerPage.bind(this)
  }

  getDeployments() {
    let xhr = new XMLHttpRequest();
    xhr.open('GET', '/api/deployments');
    xhr.onload = () => {
      if (xhr.status === 200) {
        let deployments = JSON.parse(xhr.responseText).data;
        this.setState({deployments}, () => { this.filterDeployments() });
      }
    };
    xhr.send();
  }

  addDeployment(deployment) {
    this.setState({deployments: [deployment, ...this.state.deployments]},
      () => {this.filterDeployments() })
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
      this.setState({deployments: newDeployments}, () => { this.filterDeployments() })
    }
  }

  handleFilterChange(event){
    this.setState({filterBy: event.target.value, currentPage: 1}, () => {this.filterDeployments()})
  }

  chunkDeployments(array, chunk_size){
    if(!array.length){
      return [[]]
    }
    return array.map( function(_,index){
      return index % chunk_size===0 ? array.slice(index,index+chunk_size) : [];
  }).filter(item => item)
  }

  showAll() {
    return this.state.filterBy === "all" ? true : false
  }

  filterDeployments(){
    const filteredDeployments = this.state.deployments.filter((deployment) => deployment.status === this.state.filterBy)
    const allCards = this.chunkDeployments(this.state.deployments, this.state.itemsPerPage)
    const filteredCards = this.chunkDeployments(filteredDeployments, this.state.itemsPerPage)
    this.showAll() ? this.setState({filteredDeployments: allCards}) : this.setState({filteredDeployments: filteredCards})
    this.showAll() ? this.setState({currentPageDeployments: allCards[this.state.currentPage - 1]}) : this.setState({currentPageDeployments: filteredCards[this.state.currentPage - 1]})
  }

  renderFilter(){
    return (<div className="form-group col">
    <label className="my-1 mr-2" htmlFor="filter-deployments">Filter Deployments</label>
    <select className="custom-select-sm my-3 mr-sm-2 " value={this.state.value} onChange={this.handleFilterChange}>
      <option value="all">all</option>
      <option value="queued">queued</option>
      <option value="started">started</option>
      <option value="hibernated">hibernated</option>
      <option value="deleted">deleted</option>
      <option value="failed">failed</option>
    </select>
    </div>)
  }

  renderDeploymentCards(){
    if(!this.state.currentPageDeployments.length){
      return <p>No {this.state.filterBy} deployments</p>
    }
    return this.state.currentPageDeployments.map((deployment) => <DeploymentCard key={deployment.id} deployment={deployment} />)
  }

  changeitemsPerPage(e){
    const itemsPerPage = parseInt(e.target.value)
    this.setState({itemsPerPage}, () => {this.filterDeployments()})
  }

  renderPaginationOptions(){
    return (<div className="form-group col">
    <label className="my-1 mr-2" htmlFor="pagination-options">Items on a Page</label>
    <select className="custom-select-sm my-3 mr-sm-2 " value={this.state.itemsOnPage} onChange={this.changeitemsPerPage}>
      <option value="10">10</option>
      <option value="20">20</option>
      <option value="30">30</option>
      <option value="40">40</option>
      <option value="50">50</option>
    </select>
    </div>)
  }

  changePage(pageNumber){
    this.setState({currentPage: pageNumber})
  }

  renderPagination(){
    const noOfPages = Math.ceil(this.state.filteredDeployments.reduce((acc,item) => acc + item.length, 0)/this.state.itemsPerPage)
    const pageArray = [...Array(noOfPages).keys()]
    return pageArray.map((item) => {
      const isActivePage = this.state.currentPage === item + 1 ? "active" : ""
      return <li key={item + 1} onClick={() => this.changePage(item+1)} className="page-item"><a className={`page-link ${isActivePage}`} href="#">{item + 1}</a></li>
    }
    )
  }

  render() {
    return (
      <div>
        <h3 className="mb-5">Recent Deployments</h3>
        <div className="row">
          {this.renderFilter()}
          {this.renderPaginationOptions()}
        </div>
        {
          this.renderDeploymentCards()
        }
        <ul className="pagination">
        {this.renderPagination()}
        </ul>
      </div>
    )
  }
}

export default DeploymentList
