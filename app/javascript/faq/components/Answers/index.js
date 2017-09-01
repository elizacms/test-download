import React, { Component } from 'react';
import shortid from 'shortid';
import marked from 'marked';
import { ContentState, EditorState, convertToRaw, convertFromHTML } from 'draft-js';
import { stateToHTML } from 'draft-js-export-html';


import ee from '../../EventEmitter';
import TextEditor from '../TextEditor';
import './answers.sass';

export default class Answers extends Component {
  constructor(props) {
    super(props);

    var defaultState = {};
    var restOfState = {
      value: '',
      canSave: false,
      newAnswerActive: false,
      active: false,
      addingNewAnswer: false,
      currentAnswerText: '',
    };

    props.data && props.data.forEach((answer, index) => {
      if(!answer) return;
      const parsedToHtml = marked(answer.text);
      let blocksFromHtml = convertFromHTML(parsedToHtml);
      let state = ContentState.createFromBlockArray(
      blocksFromHtml.contentBlocks,
        blocksFromHtml.entityMap
      );
      defaultState['editorState' + index] = (answer.text && answer.text.length > 0)
          ? EditorState.createWithContent(state)
          : EditorState.createEmpty()
    });

    this.radios = new Map();
    this.state = Object.assign({}, defaultState, restOfState);

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
    this.handleTextEditorChange = this.handleTextEditorChange.bind(this);
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

    let text = this.state.currentAnswerText;
    return () => {
      let config = {
        index,
        text: this.state.currentAnswerText,
        active: this.radios.get(id).checked,
      }
      this.ee.emit('editAnswers', config);
    }
  }

  handleAddClick(e) {
    this.setState({ addingNewAnswer: true});
  }

  handleSaveClick(id, e){
    console.log(e.target);
    return () => {
      this.ee.emit('addAnswer', {text: this.state.currentAnswerText, active: this.radios.get(id).checked});
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

  handleTextEditorChange(editorState, index){

    console.log(editorState.getCurrentContent().getBlocksAsArray());
    let currentAnswerText = stateToHTML(editorState.getCurrentContent());
      this.setState({
        currentAnswerText,
        ['editorState' + index]: editorState,
      });
  }

  renderAnswer(answer, index) {
    let id = shortid.generate();
    let editorState = this.state['editorState' + index];

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
              radio => {
                this.radios.set(id, radio);
            }}
          />
          &nbsp;&nbsp;
          <span>Valid</span>
        </div>
        <TextEditor
          key={id}
          handleChange={this.handleTextEditorChange}
          index={index}
          editorState={editorState}
        />
        <div className="flex-container">
          <button className="flex-left btn md black" onClick={this.handleEditClick(id, index, event)}>
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
          <input type="radio" onChange={this.handleCheckboxChange} checked={this.state.newAnswerActive}/>
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
          (data.length === 0) && !this.state.addingNewAnswer
            ? (<p>You don't have any answers</p>)
            : data.map((answer, index) => this.renderAnswer(answer,index))
        }
      </div>
    )
  }
}

