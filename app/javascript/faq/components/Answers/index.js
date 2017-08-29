import React, { Component } from 'react';
import shortid from 'shortid';

import ee from '../../EventEmitter';
import './answers.sass';

export default class Answers extends Component {
  constructor(props) {
    super(props);
    this.textAreas = new Map();
    this.checkboxes = new Map();
    this.state = {
      value: '',
      canSave: false,
      newAnswerActive: false,
      active: false,
      addingNewAnswer: false
    };
    this.ee = ee;
    this.handleChange = this.handleChange.bind(this);
    this.handleCheckboxChange = this.handleCheckboxChange.bind(this);
    this.handleRadioChange = this.handleRadioChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleEditClick = this.handleEditClick.bind(this);
    this.handleAddClick = this.handleAddClick.bind(this);
    this.handleDeleteClick = this.handleDeleteClick.bind(this);
    this.handleSaveClick = this.handleSaveClick.bind(this);
    this.handleSaveNewClick = this.handleSaveNewClick.bind(this);
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

  handleRadioChange(e, index) {
    return () => {
      this.setState({ active: e.target.checked});
      this.ee.emit('setAnswerActive', index)
    }
  }

  handleSubmit(e) {
    e.preventDefault();
  }

  handleEditClick(id, index, e) {

    return () => {
      let config = {
        index: index,
        text: this.textAreas.get(id).value,
        active: this.checkboxes.get(id).checked,
      }
      let value = this.textAreas.get( id ).value;
      this.ee.emit('editAnswers', config);
    }
  }

  handleAddClick(e) {
    this.setState({ addingNewAnswer: true});
  }

  handleSaveClick(id, e){
    console.log(e.target);
    return () => {
      console.log(this.textAreas.get( id ).value, this.checkboxes.get( id ).checked);
      this.ee.emit('addAnswer', {text: this.textAreas.get(id).value, active: this.checkboxes.get(id).checked});
      this.setState({ addingNewAnswer: false});
    }
  }

  handleSaveNewClick(e){
    this.ee.emit('addAnswer', {text: this.editableTextArea.value, active: this.state.newAnswerActive});
    this.setState({ addingNewAnswer: false});
  }

  handleDeleteClick(e, index){
    return () => {
      this.ee.emit('deleteAnswer', index);
    }
  }

  renderAnswer(answer, index) {
    let id = shortid.generate();

    return (
      <div key={id} className="well">
        <div>
          <input
            name="active"
            type="radio"
            onChange={this.handleRadioChange(event, index)}
            defaultChecked={answer.active}
            value={answer.active || this.state.active}
            ref={
              checkbox => {
                this.checkboxes.set(id, checkbox);
            }}
          />
          &nbsp;&nbsp;
          <span>Valid</span>
        </div>
        <textarea
          defaultValue={answer.text}
          ref={
            textArea => {
              this.textAreas.set(id, textArea);
          }}
        />
        <div className="flex-container">
          <button className="flex-left btn md black" onClick={this.handleEditClick(id,index, event)}>
            Save Answer
          </button>
          <button onClick={this.handleDeleteClick(event, index)} className="flex-right btn md black">
            Delete Answer
          </button>
        </div>
      </div>
    );
  }

  renderNewAnswer() {
    return(
      <div key={shortid.generate()} className="well">
        <div>
          <input type="checkbox" onChange={this.handleCheckboxChange} checked={this.state.newAnswerActive}/>
          &nbsp;&nbsp;
          <span>Valid</span>
        </div>
        <textarea ref={textArea => this.editableTextArea = textArea} />
        <div className="flex-container">
          <button className="flex-left btn md black" onClick={this.handleSaveNewClick}>
            Save Answer
          </button>
          <button className="flex-right btn md black">
            Delete Answer
          </button>
        </div>
      </div>
    )
  }

  render() {
    const { data } = this.props;
    if(!data) return null;

    return (
      <div className="Answers">
        <div className="flex-container">
          <h3 className="flex-left">Answers</h3>
          <button
            onClick={this.handleAddClick}
            className="btn md grey flex-right"
          >+ Add New Answer
          </button>
        </div>
        {
          this.state.addingNewAnswer && (
            this.renderNewAnswer()
          )
        }
        {
          data.length === 0  && !this.state.addingNewAnswer
            ? (<p>You don't have any answers</p>)
            : data.map((answer, index) => this.renderAnswer(answer,index))
        }
      </div>
    )
  }
}
