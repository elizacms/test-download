import React, { Component } from 'react';
import shortid from 'shortid';

import ee from '../../EventEmitter';
import './questions.sass';

export default class Questions extends Component {
	constructor(props) {
		super(props);

		this.state = {value: '', canSave: false};
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleAddClick = this.handleAddClick.bind(this);
    this.handleDeleteClick = this.handleDeleteClick.bind(this);
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

  handleAddClick(e) {
    e.preventDefault();
    this.ee.emit('saveQuestions');
  }

  handleDeleteClick(e, idx) {
    e.preventDefault();
    return () => {
      this.ee.emit('deleteQuestion', idx);
    }
  }

	render() {
    const { data } = this.props;
    if(!data) return null;
		return (
      <div className="Questions">
        <h3>Questions</h3>
        <div className="well">
          <div className="form-wrapper">
            <form onSubmit={this.handleSubmit}>
              <input
                type="text"
                value={this.state.value}
                placeholder="Question"
                onChange={this.handleChange}
              />
              <button className="add-btn btn md black">Add</button>
            </form>
          </div>
            {
              data.map((question, idx) => (
                <div key={ shortid.generate() }>
                 <button onClick={this.handleDeleteClick(event, idx)} className="delete-btn"><span>x</span></button>
                  <span>{ question }</span>
                </div>
              ))
            }
            <div className="save-btn">
              <button
                onClick={this.handleAddClick}
                className="btn md black flex-right"
              >
                Save Questions
              </button>
            </div>
        </div>
      </div>
		)
	}
}

