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

      let answerText = answer.text.replace(/(\\n)?\\n/, '\r\n');
      const parsedToHtml = marked(answerText);
      let blocksFromHtml = convertFromHTML(parsedToHtml);
      let state = ContentState.createFromBlockArray(
        blocksFromHtml.contentBlocks,
        blocksFromHtml.entityMap
      );
      defaultState['editorState' + index] = (answer.text && answer.text.length > 0)
        ? EditorState.createWithContent(state)
        : EditorState.createEmpty()
    });

    this.checkboxes = new Map();
    this.state = Object.assign({}, defaultState, restOfState);

    this.ee = ee;
    this.handleChange = this.handleChange.bind(this);
    this.handleNewAnswerCheckboxChange = this.handleNewAnswerCheckboxChange.bind(this);
    this.handleEditAnswerCheckboxChange = this.handleEditAnswerCheckboxChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleEditClick = this.handleEditClick.bind(this);
    this.handleAddClick = this.handleAddClick.bind(this);
    this.handleDeleteClick = this.handleDeleteClick.bind(this);
    this.handleSaveClick = this.handleSaveClick.bind(this);
    this.handleSaveNewClick = this.handleSaveNewClick.bind(this);
    this.handleMouseOver = this.handleMouseOver.bind(this);
    this.renderAnswer = this.renderAnswer.bind(this);
    this.renderNewAnswer = this.renderNewAnswer.bind(this);
    this.handleTextEditorChange = this.handleTextEditorChange.bind(this);
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

  handleChange(e) {
    if(!e) return ;
    e.persist();
    console.log(e.target.value);
    this.setState({ value: e.target.value});
  }

  handleNewAnswerCheckboxChange(id, e) {
    return () => {
      this.ee.emit('addAnswer', {text: this.state.currentAnswerText, active: !this.state.newAnswerActive})
      this.setState({ newAnswerActive: !this.state.newAnswerActive});
    }
  }

  handleEditAnswerCheckboxChange(id, index, e) {

    return () => {

      this.ee.emit('setAnswerActive', index);
      this.setState({ active: this.checkboxes.get(id).checked});
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
        active: this.checkboxes.get(id).checked,
      };

      this.ee.emit('editAnswers', config);
    }
  }

  handleAddClick(e) {
    this.setState({
      addingNewAnswer: true,
      ['editorState' + this.props.data.length]: EditorState.createEmpty(),
    },() => this.ee.emit('addAnswer', {text: '', active: false})
    );
  }

  handleSaveClick(id, e){
    console.log(e.target);
    return () => {
      this.ee.emit('addAnswer', {text: this.state.currentAnswerText, active: this.checkboxes.get(id).checked});
      this.setState({ addingNewAnswer: false});
    }
  }

  handleSaveNewClick(e){
    this.ee.emit('addAnswer', {text: this.editableTextArea.value, active: this.state.newAnswerActive});
    this.setState({ addingNewAnswer: false});
  }

  handleMouseOver(e) {
    e.target.focus();
    console.log(e.target)
  }

  handleDeleteClick(e, index){
    return () => {
      this.ee.emit('deleteAnswer', index);
    }
  }

  handleTextEditorChange(editorState, index){

    console.log('handleTextEditorChange', stateToHTML(editorState.getCurrentContent()));
    let currentAnswerText = stateToHTML(editorState.getCurrentContent());
    if(editorState) {
      this.setState({
        currentAnswerText,
        ['editorState' + index]: editorState,
      });
    }
  }

  renderAnswer(answer, index) {
    let id = shortid.generate();
    let editorState = this.state['editorState' + index];

    return (
      <div tabIndex={0} key={id} className="well">
        <div>
          <input
            name="active"
            type="checkbox"
            onChange={this.handleEditAnswerCheckboxChange(id, index)}
            defaultChecked={answer.active}
            value={this.state.active || answer.active }
            ref={
              radio => {
                this.checkboxes.set(id, radio);
              }
            }
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
        {
          answer.metadata && answer.metadata.videolink && (
              <p>Video url: {answer.metadata.videolink}</p>
          )

        }
        {
          answer.metadata && answer.metadata.imagelink && (
              <p>Image url: {answer.metadata.imagelink}</p>
          )

        }
        {
          answer.metadata && answer.metadata.pagepush && (
              <p>PagePush url: {answer.metadata.pagepush}</p>
          )

        }
        <div className="flex-container">
          <button
            onMouseOver={this.handleMouseOver}
            className="flex-left btn md black"
            onClick={this.handleEditClick(id, index, event)}>
            Save Answer
          </button>
          <button
            onMouseOver={this.handleMouseOver}
            onClick={this.handleDeleteClick(event, index)}
            className="flex-right btn md black">
            Delete Answer
          </button>
        </div>
      </div>
    );
  }

  renderNewAnswer() {
    let id = shortid.generate();
    let index = this.props.data.length - 1;
    return(
      <div key={id} className="well">
      <div>
      <input
      type="checkbox"
      onChange={this.handleNewAnswerCheckboxChange(id)}
      checked={this.state.newAnswerActive}
      ref={
        radio => {
          this.checkboxes.set(id, radio);
        }}
      />
      &nbsp;&nbsp;
      <span>Valid</span>
      </div>
      <TextEditor
      key={id}
      handleChange={this.handleTextEditorChange}
      index={index}
      editorState={this.state['editorState' + index]}
      />
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

}
