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
		let type = target.type;
		let name = target.name;
		let value = null;

		if(type === 'checkbox' ) {
			value = target.checked
		}

		if (type === 'select-one') {
			value = target.options[target.selectedIndex].value;
		}

		if (type === 'search') {
			value = target.value;
		}

		this.setState({
			[name]: value
		}, console.log(this.state));
	}

	handleSubmit(e){
		console.log(e);
		e.preventDefault();
		if(this.state.searchTerm && this.state.searchByType === 'kb_id'){
			this.ee.emit('searchArticle', this.state.searchTerm );
			this.setState({
				searchByType: this.options[0],
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
