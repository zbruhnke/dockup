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
      currentPageDeployments:[],
      filterBy: "all",
      currentPage: 1,
      itemsPerPage: 10,
    }
    this.getDeployments();
    this.connectToDeploymentsChannel();
    this.handleFilterChange = this.handleFilterChange.bind(this)
    this.changeitemsPerPage = this.changeitemsPerPage.bind(this)
  }

  componentDidMount(){
      if(this.history.location.state){
        const {currentPage, filterBy, itemsPerPage} = this.history.location.state
        this.setState({currentPage, filterBy, itemsPerPage})
        this.filterDeployments();
      }
  }

  getDeployments() {
    let xhr = new XMLHttpRequest();
    xhr.open('GET', '/api/deployments');
    xhr.onload = () => {
      if (xhr.status === 200) {
        let deployments = JSON.parse(xhr.responseText).data;
        this.setState({deployments}, () => { this.filterDeployments()});
      }
    };
    xhr.send();
  }

  addDeployment(deployment) {
    this.setState({deployments: [deployment, ...this.state.deployments]},
      () => {
        this.filterDeployments()
        this.pushHistory()
      })
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
    this.setState({filterBy: event.target.value, currentPage: 1},
      () => {
        this.filterDeployments()
        this.pushHistory()
      })
  }

  pushHistory(){
    const {filterBy,currentPage, itemsPerPage} = this.state
    this.history.push(`/deployments?filter=${filterBy}?pageNo=${currentPage}?items=${itemsPerPage}`, {filterBy, currentPage, itemsPerPage})
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
    <label className="my-1 mr-2" htmlFor="filter-deployments">Filter deployments</label>
    <select className="custom-select-sm my-3 mr-sm-2 " value={this.state.filterBy} onChange={this.handleFilterChange}>
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
    this.setState({itemsPerPage}, () => {
      this.filterDeployments()
      this.pushHistory()
    })
  }

  renderPaginationOptions(){
    return (
    <div className="form-group col">
    <label className="my-1 mr-2" htmlFor="pagination-options">Items per page</label>
    <select className="custom-select-sm my-3 mr-sm-2 " value={this.state.itemsPerPage} onChange={this.changeitemsPerPage}>
      <option value="10">10</option>
      <option value="20">20</option>
      <option value="30">30</option>
      <option value="40">40</option>
      <option value="50">50</option>
    </select>
    </div>
    )
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
          {this.renderFilter()}
        {this.renderDeploymentCards()}
        <div className="row">
        <ul className="pagination col">
        {this.renderPagination()}
        </ul>
        {this.renderPaginationOptions()}
        </div>

      </div>
    )
  }
}

export default DeploymentList
