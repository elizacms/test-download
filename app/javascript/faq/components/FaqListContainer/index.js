import React, { Component } from 'react';
import shortid from 'shortid';

import { fetchArticles, fetchSingleArticle, putArticle } from '../../api/articles';
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
  }

  componentDidMount() {
    this.ee.on('changePageNumber', this.changePageNumber);
    this.ee.on('pageForward', this.pageForward);
    this.ee.on('pageBack', this.pageBack);
    this.ee.on('pageBack', this.pageBack);
    this.ee.on('editArticle', this.editArticle);
    this.ee.on('searchArticle', this.searchArticle);
    this.ee.on('addQuestion', this.addQuestion);
    this.fetchArticlesAndSetThemInState();
  }

  componentWillUnmount() {
    this.ee.off('changePageNumber');
    this.ee.off('pageForward');
    this.ee.off('pageBack');
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
    }, () => putArticle(this.state.currentArticle));
  }

  searchArticle(article){
    fetchSingleArticle(article)
      .then(article => {
	this.setState({
	  currentPage: 1,
	  articles: article.results,
	  currentArticle: article.results
	})
      })

  }
  render() {

    let faqListProps = {
      articles: this.state.articles,
      pagesTotal: this.state.pagesTotal,
      articleTotal:this.state.articleTotal,
      currentPage:this.state.currentPage,
    };

    return (
      <span>
	<FaqList {...faqListProps} />
	<PagingControl itemCount={ this.state.pagesTotal } />
      </span>
    );
  }
}
