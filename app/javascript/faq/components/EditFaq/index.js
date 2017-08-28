import React, { Component } from 'react';
import shortid from 'shortid';

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
    this.saveQuestions  = this.saveQuestions.bind(this);
    this.saveArticle = this.saveArticle.bind(this);
    this.editAnswers = this.editAnswers.bind(this);
    this.addAnswer = this.addAnswer.bind(this);
  }
  componentDidMount() {
    this.ee.on('addQuestion', this.addQuestion);
    this.ee.on('setCurrentArticleEnabled', this.setCurrentArticleEnabled);
    this.ee.on('saveQuestions', this.saveQuestions);
    this.ee.on('editAnswers', this.editAnswers);
    this.ee.on('addAnswer', this.addAnswer);
  }

  componentWillUnmount() {
    this.ee.off('addQuestion');
    this.ee.off('saveQuestions');
    this.ee.off('setCurrentArticleEnabled');
    this.ee.off('editAnswers');
    this.ee.off('addAnswer');
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
    console.log(answerData);
    let currentArticle = this.state.currentArticle;
    let currentAnswers = this.state.currentArticle.answers;
    currentArticle.answers[answerData.index].text = answerData.text;

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

    currentArticle.answers.push(answer);

    console.log(this.state.currentArticle.answers);

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

