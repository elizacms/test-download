import React, { Component } from 'react';
import shortid from 'shortid';

import { fetchArticles, fetchSingleArticle } from '../../api/articles';
import ee from '../../EventEmitter';
import FaqList from '../FaqList';
import EditFaq from '../EditFaq';

export default class FaqListContainer extends Component {
	constructor(props) {
		super(props);

		this.state = {
			currentPage: 1,
			articles: [],
		};

    this.ee = ee;
    this.fetchArticlesAndSetThemInState = this.fetchArticlesAndSetThemInState.bind(this);
    this.changePageNumber= this.changePageNumber.bind(this);
    this.pageForward = this.pageForward.bind(this);
    this.pageBack = this.pageBack.bind(this);
    this.editArticle = this.editArticle.bind(this);
	}

	componentDidMount() {
		this.ee.on('changePageNumber', this.changePageNumber);
		this.ee.on('pageForward', this.pageForward);
		this.ee.on('pageBack', this.pageBack);
		this.ee.on('editArticle', this.editArticle);
		this.fetchArticlesAndSetThemInState();
  }
	componentWillUnmount() {
		this.ee.off('changePageNumber');
		this.ee.off('pageForward');
		this.ee.off('pageBack');
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

	changePageNumber(page) {
    console.log('changePageNumber', page);
		this.fetchArticlesAndSetThemInState(page);
	}
  editArticle(article){
    let responses = article.articles.map(item => item.response);
    let queries = article.articles.map(item => item.query);
    let editFaqComponent = <EditFaq
    kbId={article.kbid}
    queries={queries} responses={responses}
      />
    this.ee.emit('openModal', editFaqComponent)

  }

  render() {

    let faqListProps = {
      articles: this.state.articles,
      pagesTotal: this.state.pagesTotal,
      articleTotal:this.state.articleTotal,
      currentPage:this.state.currentPage,
    };


		return (
      <FaqList {...faqListProps} />
		);
	}
}
