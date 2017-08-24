import React, { Component } from 'react';
import shortid from 'shortid';

import ee from '../../EventEmitter';
import './answers.sass';

export default class Answers extends Component {
  constructor(props) {
    super(props);
		this.state = {
      value: '',
      canSave: false,
      newAnswerActive: false,
      addingNewAnswer: false
    };
    this.ee = ee;
    this.handleChange = this.handleChange.bind(this);
    this.handleCheckboxChange = this.handleCheckboxChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleEditClick = this.handleEditClick.bind(this);
    this.handleAddClick = this.handleAddClick.bind(this);
    this.handleSaveClick = this.handleSaveClick.bind(this);
    this.renderAnswer = this.renderAnswer.bind(this);
    this.renderNewAnswer = this.renderNewAnswer.bind(this);
  }

  handleChange(e) {
    console.log(e.target.value);
    this.setState({ value: e.target.value});
  }

  handleCheckboxChange(e) {
    this.setState({ newAnswerActive: e.target.checked});
  }

  handleSubmit(e) {
    e.preventDefault();
  }

  handleEditClick(e) {
    this.ee.emit('saveAnswers');
  }

  handleAddClick(e) {
    this.setState({ addingNewAnswer: true});
  }

  handleSaveClick(e){
    this.ee.emit('addAnswer', {text: this.state.value, active: this.state.newAnswerActive});
    this.setState({ addingNewAnswer: false});
  }

  renderAnswer(answer) {

    return (
      <div key={shortid.generate()} className="answers-wrapper">
        <label>
          <span>Valid</span>
          <input type="checkbox" defaultChecked={answer.active}/>
        </label>
        <h4>emotion: {answer.metadata && answer.metadata.emotion} </h4>
        <textarea defaultValue={answer.text}></textarea>
        <div className="buttonWrapper">
          <button onClick={this.handleSaveClick}>Save Answer</button>
          <button>Delete Answer</button>
        </div>
      </div>
    );
  }

  renderNewAnswer() {
    return(
      <div key={shortid.generate()} className="answers-wrapper">
        <label>
          <span>Valid</span>
          <input type="checkbox" onChange={this.handleCheckboxChange} checked={this.state.newAnswerActive}/>
        </label>
        <textarea value={this.state.value} onChange={this.handleChange} />
        <div className="buttonWrapper">
          <button onClick={this.handleSaveClick}>Save Answer</button>
          <button>Delete Answer</button>
        </div>
      </div>
    )
  }

  render() {
    const { data } = this.props;
    if(!data) return null;

    return (
      <div className="Answers">
        <h3>Answers</h3>
        <button onClick={this.handleAddClick}>+ Add New Answer</button>
      <hr />

      {
        this.state.addingNewAnswer && (
          this.renderNewAnswer()
        )
      }

      {
        data.length === 0  && !this.state.addingNewAnswer
          ? (<p>You don't have any answers</p>)
          : data.map(answer => this.renderAnswer(answer))
      }
      </div>
    )
  }
}

