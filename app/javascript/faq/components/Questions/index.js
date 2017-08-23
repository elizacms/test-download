import React, { Component } from 'react';
import shortid from 'shortid';

import ee from '../../EventEmitter';

export default class Questions extends Component {
	constructor(props) {
		super(props);

		this.state = {value: ''};
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.ee = ee;
  }

  handleChange(event) {
    console.log(event.target.value);
    this.setState({
      value: event.target.value
    })
  }

  handleSubmit(e) {
    e.preventDefault();
    console.log(this.state.value);
    this.ee.emit('addQuestion', this.state.value);
  }

	render() {
    const { data } = this.props;
    if(!data) return null;
		return (
      <div className="Questions">
        <h3>Questions</h3>
      <form onSubmit={this.handleSubmit}>
        <input
            type="search"
            value={this.state.value}
            placeholder="Question"
            onChange={this.handleChange}
        />
        <button>Add</button>
        {
          data.map(question => (
           <p key={ shortid.generate() }>{ question }</p>)
          )
        }
      </form>
        <div>
          <button>Save Queries</button>
        </div>
      </div>
		)
	}
}

