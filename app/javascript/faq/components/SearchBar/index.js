import React, { Component } from 'react';
import ee from '../../EventEmitter';
import shortid from 'shortid';

import './search-bar.sass';

export default class SearchBar extends Component {
	constructor(props) {
		super(props);
		this.state = { searchTerm: '' };
		this.ee = ee;
		this.handleChange = this.handleChange.bind(this);
		this.handleSubmit = this.handleSubmit.bind(this);
	}

	handleChange(event) {
		let target = event.target;
		let type = target.type;
		let name = target.name;
		let value = target.value;

		this.setState({
			[name]: value
		}, () => this.ee.emit('searchArticle', this.state.searchTerm));
	}

	handleSubmit(e){
		console.log(e);
		e.preventDefault();
		if(this.state.searchTerm){
			this.ee.emit('searchArticle', this.state.searchTerm );
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
							placeholder="Search by KB ID"
						/>
					</label>
				</form>
			</div>
		);
	}
}
