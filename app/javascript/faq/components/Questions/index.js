import React, { Component } from 'react';
import shortid from 'shortid';

import ee from '../../EventEmitter';

export default class Questions extends Component {
	constructor(props) {
		super(props);

		this.state = {value: '', canSave: false};
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleAddClick = this.handleAddClick.bind(this);
    this.ee = ee;
  }

  handleChange(event) {
    this.setState({
      value: event.target.value
    })
  }

  handleSubmit(e) {
    e.preventDefault();
    this.ee.emit('addQuestion', this.state.value);
    this.setState({ value: '', canSave: true });
  }

  handleAddClick() {
    this.ee.emit('saveQuestions');
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
        </form>
          {
            data.map(question => (
             <p key={ shortid.generate() }>{ question }</p>)
            )
          }
          {
            this.state.canSave && (
              <button onClick={this.handleAddClick}>Save Questions</button>
            )
          }
      </div>
		)
	}
}

