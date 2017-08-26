import React, { Component } from 'react';
import ee from '../../EventEmitter';
import shortid from 'shortid';

import './search-bar.sass';

export default class SearchBar extends Component {
	constructor(props) {
		super(props);
		this.state = { searchTerm: '', searchType: 'kbid' };
		this.ee = ee;
		this.handleChange = this.handleChange.bind(this);
		this.handleSelectChange = this.handleSelectChange.bind(this);
		this.handleSubmit = this.handleSubmit.bind(this);
	}

	handleChange(event) {
		let target = event.target;
		let value = target.value;
		this.ee.emit('searchArticle', {searchType: this.state.searchType, inputText: value});
		this.setState({ searchTerm: value });
	}

	handleSelectChange(event) {
		let target = event.target;
		let value = target.value;

		this.setState({
			searchType: value
		});
	}

	handleSubmit(e){
		console.log(e);
		e.preventDefault();
		if(this.state.searchTerm){
			this.ee.emit('searchArticle', {searchType: this.state.searchType, inputText: this.state.searchTerm});
			this.setState({
				searchTerm: ''
			});
		}
	}

	render() {
		return (
			<div className="SearchBar">
				<form onSubmit={this.handleSubmit}>
					<label>
						<input
							name="searchTerm"
							type="search"
							value={this.state.searchTerm}
							onChange={this.handleChange}
							placeholder={`Search by ${this.state.searchType}`}
						/>
					</label>
					<label>
				<select value={this.state.searchType} onChange={this.handleSelectChange}>
					<option value="kbid">KB ID</option>
					<option value="query">Questions</option>
					<option value="response">Answer</option>
          </select>
					</label>
				</form>
			</div>
		);
	}
}
