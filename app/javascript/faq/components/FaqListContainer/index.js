import React, { Component } from 'react';
import shortid from 'shortid';

import { searchArticleByType, fetchArticles, deleteArticle, fetchSingleArticle, putArticle } from '../../api/articles';
import ee from '../../EventEmitter';
import FaqList from '../FaqList';
import EditFaq from '../EditFaq';
import PagingControl from '../PagingControl';

export default class FaqListContainer extends Component {
  constructor(props) {
    super(props);

    this.state = {
      currentArticle: null,
      currentQuestions: [],
      currentAnswers: [],
      currentPage: 1,
      pagesTotal: 0,
      articles: [],
    };

    this.ee = ee;
    this.changePageNumber= this.changePageNumber.bind(this);
    this.pageForward = this.pageForward.bind(this);
    this.pageBack = this.pageBack.bind(this);
    this.fetchArticlesAndSetThemInState = this.fetchArticlesAndSetThemInState.bind(this);
    this.editArticle = this.editArticle.bind(this);
    this.searchArticle = this.searchArticle.bind(this);
    this.addQuestion = this.addQuestion.bind(this);
    this.setCurrentArticleEnabled = this.setCurrentArticleEnabled.bind(this);
    this.saveQuestions  = this.saveQuestions.bind(this);
    this.saveArticle = this.saveArticle.bind(this);
    this.editAnswers = this.editAnswers.bind(this);
    this.addAnswer = this.addAnswer.bind(this);
    this.deleteArticle = this.deleteArticle.bind(this);
  }

  componentDidMount() {
    this.ee.on('changePageNumber', this.changePageNumber);
    this.ee.on('pageForward', this.pageForward);
    this.ee.on('pageBack', this.pageBack);
    this.ee.on('pageBack', this.pageBack);
    this.ee.on('editArticle', this.editArticle);
    this.ee.on('searchArticle', this.searchArticle);
    this.ee.on('addQuestion', this.addQuestion);
    this.ee.on('saveQuestions', this.saveQuestions);
    this.ee.on('setCurrentArticleEnabled', this.setCurrentArticleEnabled);
    this.ee.on('editAnswers', this.editAnswers);
    this.ee.on('addAnswer', this.addAnswer);
    this.ee.on('deleteArticle',this.deleteArticle )
    this.fetchArticlesAndSetThemInState();
  }

  componentWillUnmount() {
    this.ee.off('changePageNumber');
    this.ee.off('pageForward');
    this.ee.off('pageBack');
    this.ee.off('editArticle');
    this.ee.off('searchArticle');
    this.ee.off('addQuestion');
    this.ee.off('saveQuestions');
    this.ee.off('setCurrentArticleEnabled');
    this.ee.off('editAnswers');
    this.ee.off('addAnswer');
  }

  changePageNumber(page) {
    this.fetchArticlesAndSetThemInState(page);
  }

  pageForward() {
    let page = (this.state.currentPage + 1) % this.state.pagesTotal;
    this.fetchArticlesAndSetThemInState(page);
  }

  pageBack() {
    let page = (this.state.currentPage - 1) === 0
      ? this.state.pagesTotal
      : this.state.currentPage - 1;

    this.fetchArticlesAndSetThemInState(page);
  }

  fetchArticlesAndSetThemInState(page){
    fetchArticles(page)
      .then(articles => {
	return this.setState({
	  articles: articles.results,
	  currentPage: page ? page : 1,
	  pagesTotal: articles.pages,
	  articleTotal: articles.total,
	});
      });
  }

  editArticle(article){
    let answers = article.answers;
    let questions = article.questions;
    this.setState({
      currentArticle: article,
      currentAnswers: answers,
      currentQuestions: questions,
    }, () => {

      let editFaqComponent = (
	<EditFaq
	key={shortid.generate()}
	isEnabled={this.state.currentArticle.enabled}
	kbId={this.state.currentArticle.kbid}
	questions={this.state.currentQuestions}
	answers={this.state.currentAnswers}
	/>
      );

      this.ee.emit('openModal', editFaqComponent)
    }
    );

  }

  addQuestion(question) {
    let currentArticle = this.state.currentArticle;
    currentArticle.questions.push(question);
    this.setState({
      currentArticle,
      currentQuestions: currentArticle.questions,
    });
  }

  saveQuestions() {
    this.saveArticle();
  }

  saveArticle() {
    putArticle(this.state.currentArticle)
  }

  searchArticle(searchData){
    searchArticleByType(searchData.searchType, searchData.inputText)
      .then(article => {
	return this.setState({
	  articles: article.results ,
	  pagesTotal: article.pages,
	  articleTotal: article.total,
	})
      })

  }

  setCurrentArticleEnabled(isEnabled){
    let currentArticle = this.state.currentArticle;
    currentArticle.enabled = isEnabled;
    this.setState({ currentArticle }, this.saveArticle);
  }

  editAnswers(answerData) {
    console.log(answerData);
    let currentArticle = this.state.currentArticle;
    let currentAnswers = this.state.currentAnswers;
    currentAnswers[answerData.index].text = answerData.text;
    currentArticle.answers = currentAnswers;
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

  deleteArticle(kbid) {
    return deleteArticle(kbid)
      .then((response) => this.fetchArticlesAndSetThemInState())

  }

  render() {

    let faqListProps = {
      articles: this.state.articles,
      pagesTotal: this.state.pagesTotal,
      articleTotal:this.state.articleTotal,
      currentPage:this.state.currentPage,
    };

    return (
      <span >
      <FaqList {...faqListProps} />
      <PagingControl itemCount={ this.state.pagesTotal } />
      </span>
    );
  }
}
