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
      currentPageItems: [[]],
      itemsPerPage: 10,
      currentPage: 1
    }
    this.getDeployments();
    this.connectToDeploymentsChannel();
    this.handleFilterChange = this.handleFilterChange.bind(this)
    this.changeitemsPerPage =  this.changeitemsPerPage.bind(this)
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

  chunkDeployments(array, chunk_size){
    if(!array.length){
      return [[]]
    }
    return array.map( function(_,index){
      return index % chunk_size===0 ? array.slice(index,index+chunk_size) : null;
  }).filter(item => item)
  }

  showAll() {
    return !this.state.filtersApplied.length
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
    this.showAll() ? this.setState({filteredDeployments: this.state.deployments}, () => this.paginate() ) : this.setState({filteredDeployments}, () => this.paginate())
  }

  paginate(){
    const {itemsPerPage, filtersApplied, filteredDeployments, deployments} = this.state
    const currentPageItems = filtersApplied.length ? this.chunkDeployments(filteredDeployments, itemsPerPage) : this.chunkDeployments(deployments, itemsPerPage)
    this.setState({currentPageItems})
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
    return this.state.filtersApplied.length ? this.state.currentPageItems[this.state.currentPage - 1].map((deployment) => <DeploymentCard key={deployment.id} deployment={deployment} />): this.state.deployments.map(deployment => <DeploymentCard key={deployment.id} deployment={deployment}/>) 
  }

  changeitemsPerPage(e){
    const itemsPerPage = parseInt(e.target.value)
    console.log(itemsPerPage)
    this.setState({itemsPerPage, currentPage: 1}, () => this.filterDeployments() )
  }

  changePage(pageNumber){
    this.setState({currentPage: pageNumber})
  }

  renderPagination(){
    const noOfPages = this.state.currentPageItems.length;
    const pageArray = [...Array(noOfPages).keys()]
    return pageArray.map((item) => {
      const isActivePage = this.state.currentPage === item + 1 ? "active" : ""
      return <li key={item + 1} onClick={() => this.changePage(item+1)} className="page-item"><a className={`page-link ${isActivePage}`} href="#">{item + 1}</a></li>
    }
    )
  }

  renderPaginationOptions(){
    return (<div className="form-group col">
    <label className="my-1 mr-2" htmlFor="pagination-options">Items on a Page</label>
    <select className="custom-select-sm my-3 mr-sm-2 " value={this.state.itemsPerPage} onChange={this.changeitemsPerPage}>
      <option value="10">10</option>
      <option value="20">20</option>
      <option value="30">30</option>
      <option value="40">40</option>
      <option value="50">50</option>
    </select>
    </div>)
  }

  render() {
    return (
      <div>
        <h3 className="mb-5">Recent Deployments</h3>
        {this.renderFilter()}
        {this.renderDeploymentCards()}
        {console.log(this.renderDeploymentCards())}

        <div className="row">
          <ul className="pagination">
          {this.renderPagination()}
          {this.renderPaginationOptions()}
          </ul>
        </div>
      </div>
    )
  }
}

export default DeploymentList
