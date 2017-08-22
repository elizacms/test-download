import React, { Component } from 'react';
import shortid from 'shortid';

import { fetchArticles, fetchSingleArticle } from '../../api/articles';
import ee from '../../EventEmitter';
import FaqList from '../FaqList';
import EditFaq from '../EditFaq';
import PagingControl from '../PagingControl';

export default class FaqListContainer extends Component {
  constructor(props) {
    super(props);

    this.state = {
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
  }

  componentDidMount() {
    this.ee.on('changePageNumber', this.changePageNumber);
    this.ee.on('pageForward', this.pageForward);
    this.ee.on('pageBack', this.pageBack);
    this.ee.on('pageBack', this.pageBack);
    this.ee.on('editArticle', this.editArticle);
    this.ee.on('searchArticle', this.searchArticle);
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
	console.log(articles);
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
    let editFaqComponent = (
      <EditFaq
      kbId={article.kbid}
      questions={article.questions}
      answers={article.answers}
      />
    );

    this.ee.emit('openModal', editFaqComponent)
  }

  searchArticle(article){
    console.log(article);
    fetchSingleArticle(article)
      .then(article => {
	this.setState({
	  articles: article.results,
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
