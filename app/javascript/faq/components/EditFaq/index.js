import React, { Component } from 'react';
import shortid from 'shortid';
import toMarkdown from 'to-markdown';

import { postArticle, searchArticleByType, fetchArticles, deleteArticle, fetchSingleArticle, putArticle } from '../../api/articles';
import EditFaqView from '../EditFaqView/';
import ee from '../../EventEmitter';

export default class EditFaq extends Component {
	constructor(props) {
		super(props);

    //const {kbId, isEnabled, questions, answers} = props;
    this.state = {
      currentArticle: props.currentArticle || {
        enabled: false,
        answers: [],
        questions:[],
      },
    };

    this.ee = ee;
    this.addQuestion = this.addQuestion.bind(this);
    this.setCurrentArticleEnabled = this.setCurrentArticleEnabled.bind(this);
    this.setAnswerActive = this.setAnswerActive.bind(this);
    this.saveQuestions  = this.saveQuestions.bind(this);
    this.saveArticle = this.saveArticle.bind(this);
    this.editAnswers = this.editAnswers.bind(this);
    this.addAnswer = this.addAnswer.bind(this);
    this.deleteQuestion = this.deleteQuestion.bind(this);
    this.deleteAnswer = this.deleteAnswer.bind(this);
  }
  componentDidMount() {

    this.ee.on('addQuestion', this.addQuestion);
    this.ee.on('setCurrentArticleEnabled', this.setCurrentArticleEnabled);
    this.ee.on('setAnswerActive', this.setAnswerActive);
    this.ee.on('saveQuestions', this.saveQuestions);
    this.ee.on('editAnswers', this.editAnswers);
    this.ee.on('addAnswer', this.addAnswer);
    this.ee.on('deleteQuestion', this.deleteQuestion);
    this.ee.on('deleteAnswer', this.deleteAnswer);
  }

  componentWillUnmount() {
    this.ee.off('addQuestion');
    this.ee.off('saveQuestions');
    this.ee.off('setCurrentArticleEnabled');
    this.ee.off('editAnswers');
    this.ee.off('addAnswer');
    this.ee.off('deleteQuestion');
    this.ee.off('deleteAnswer');
  }

  addQuestion(question) {
    let currentArticle = this.state.currentArticle;
    currentArticle.questions.push(question);
    this.setState({ currentArticle });
  }

  setCurrentArticleEnabled(isEnabled){
    let currentArticle = this.state.currentArticle;
    currentArticle.enabled = isEnabled;
    this.setState({ currentArticle }, this.saveArticle);
  }

  setAnswerActive(indexToChange) {
    let currentArticle = this.state.currentArticle;
    currentArticle.answers.forEach((answer, index) => {
      if(indexToChange === index) {
        answer.active = true;
      } else {
        answer.active = false;
      }
    });

    this.setState({ currentArticle }, this.saveArticle);
  }

  saveQuestions() {
    this.saveArticle();
  }

  saveArticle() {
    if(!this.state.currentArticle) return;

    if(this.state.currentArticle.kbid) {

      putArticle(this.state.currentArticle);
    } else {

      postArticle(this.state.currentArticle)
        .then(currentArticle => this.setState({ currentArticle }))
    }
  }

  editAnswers(answerData) {
    let currentArticle = this.state.currentArticle;
    let text =  toMarkdown(answerData.text);
    currentArticle.answers[answerData.index].text = text;

    this.setState({currentArticle}, this.saveArticle);
  }

  addAnswer(answerData) {

    let currentArticle = this.state.currentArticle;

    let answer = {
      active: answerData.active,
      links: [],
      metadata: {},
      text: answerData.text
    }

    currentArticle.answers.unshift(answer);

    this.setState({ currentArticle }, this.saveArticle);
  }

  deleteQuestion(indexToDelete) {
    let currentArticle = this.state.currentArticle;
    currentArticle.questions.splice(indexToDelete, 1);
    this.setState({ currentArticle }, this.saveArticle);
  }

  deleteAnswer(indexToDelete) {
    let currentArticle = this.state.currentArticle;
    currentArticle.answers.splice(indexToDelete, 1);
    this.setState({ currentArticle }, this.saveArticle);
  }

	render() {
    const {currentArticle} =  this.state;
		return (
      <EditFaqView
        key={shortid.generate()}
        isEnabled={currentArticle ? currentArticle.enabled : false}
        kbId={currentArticle && currentArticle.kbid ? currentArticle.kbid : null}
        questions={currentArticle ? currentArticle.questions : []}
        answers={currentArticle ? currentArticle.answers : []}
      />
		)
	}
}

