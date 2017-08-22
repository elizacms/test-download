import React, { Component } from 'react';
import ee from '../../EventEmitter';
import shortid from 'shortid';

import './search-bar.sass';

export default class SearchBar extends Component {
	constructor(props) {
		super(props);
		this.options = ['kb_id', 'type', 'enabled' ];
		this.state = {searchByType: this.options[0], searchTerm: ''};
		this.ee = ee;
		this.handleChange = this.handleChange.bind(this);
		this.handleSubmit = this.handleSubmit.bind(this);
	}

	handleChange(event) {
		let target = event.target;
		let value = target.type === 'checkbox' ? target.checked : target.value;
		let name = target.name;
		this.setState({
			[name]: value
		});
	}

	handleSubmit(e){
		console.log(e);
		e.preventDefault();
		if(this.state.searchTerm){
		 this.ee.emit('searchArticle', this.state.searchTerm );
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
						placeholder={`Search ${this.state.searchByType}`}
					/>
				</label>
				<label>
					<select
						name="searchByType"
						value={this.state.searchByType}
						onChange={this.handleChange}
					>
					{
						this.options.map(option => (
							<option key={shortid.generate()} value={option}>
								{option}
							</option>)
						)
					}
					</select>
				</label>
				</form>
			</div>
		);
	}
}
