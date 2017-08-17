import React, { Component } from 'react';
import ee from '../../EventEmitter';

import './search-bar.sass';

export default class SearchBar extends Component {
	constructor(props) {
		super(props);
		this.options = ['kb_id', 'type', 'enabled' ];
		this.state = {value: this.options[0]};
		this.ee = ee;
		this.handleChange = this.handleChange.bind(this);
	}

	handleChange(event) {
		console.log(event);
		this.setState({value: event.target.value});
	}

	render() {
		return (
			<div className="SearchBar">
				<label>
					<input type="search" />
				</label>
				<label>
					<select value={this.state.value} onChange={this.handleChange}>
					{
						this.options.map((option, index) => (
							<option key={index} value={option}>{option}</option>)
						)
					}
					</select>
				</label>
			</div>
		);
	}
}
