import React, { Component } from 'react';
import shortid from 'shortid';

import { searchArticleByType, fetchArticles, deleteArticle, fetchSingleArticle, putArticle } from '../../api/articles';
import ee from '../../EventEmitter';
import FaqList from '../FaqList';
import EditFaq from '../EditFaq';
import AddFaq from '../AddFaq';
import PagingControl from '../PagingControl';

export default class FaqListContainer extends Component {
  constructor(props) {
    super(props);

    this.state = {
      currentArticle: null,
      currentPage: 1,
      pagesTotal: 0,
      articles: [],
    };

    this.ee = ee;
    this.fetchArticlesAndSetThemInState = this.fetchArticlesAndSetThemInState.bind(this);
    this.changePageNumber= this.changePageNumber.bind(this);
    this.pageForward = this.pageForward.bind(this);
    this.pageBack = this.pageBack.bind(this);
    this.editArticle = this.editArticle.bind(this);
    this.deleteArticle = this.deleteArticle.bind(this);
    this.addArticle = this.addArticle.bind(this);
    this.searchArticle = this.searchArticle.bind(this);
    this.sortByKbid = this.sortByKbid.bind(this);
    this.sortByEnabled = this.sortByEnabled.bind(this);
  }

  componentDidMount() {
    this.ee.on('changePageNumber', this.changePageNumber);
    this.ee.on('pageForward', this.pageForward);
    this.ee.on('pageBack', this.pageBack);
    this.ee.on('pageBack', this.pageBack);
    this.ee.on('editArticle', this.editArticle);
    this.ee.on('deleteArticle',this.deleteArticle )
    this.ee.on('addArticle',this.addArticle )
    this.ee.on('searchArticle', this.searchArticle);
    this.ee.on('sortByKbid', this.sortByKbid);
    this.ee.on('sortByEnabled', this.sortByEnabled);
    this.fetchArticlesAndSetThemInState();
  }

  componentWillUnmount() {
    this.ee.off('changePageNumber');
    this.ee.off('pageForward');
    this.ee.off('pageBack');
    this.ee.off('editArticle');
    this.ee.off('deleteArticle');
    this.ee.off('addArticle');
    this.ee.off('searchArticle');
    this.ee.off('sortByKbid');
    this.ee.off('sortByEnabled');
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
    this.setState({
      currentArticle: article,
    }, () => {

      let editFaqComponent = (
	<EditFaq
	  key={shortid.generate()}
	  currentArticle={this.state.currentArticle}
	/>
      );

      this.ee.emit('openModal', editFaqComponent)
    }
    );

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


  deleteArticle(kbid) {
    return deleteArticle(kbid)
      .then((response) => this.fetchArticlesAndSetThemInState())

  }

  addArticle() {
      let addFaqComponent = (
	<EditFaq
	  key={shortid.generate()}
	/>
      );

      this.ee.emit('openModal', addFaqComponent);
  }

  sortByKbid(direction) {
    console.log(direction);
    let articles = this.state.articles;

    if(direction) {
      articles.sort((a, b) => {
	if(a.kbid > b.kbid) {
	  return 1;
	}
	if( a.kbid < b.kbid ) {
	  return -1;
	}
	if(a.kbid === b.kbid ) {
	  return 0;
	}
      })
    } else {
      articles.sort((a, b) => {
	if(a.kbid > b.kbid) {
	  return -1;
	}
	if( a.kbid < b.kbid ) {
	  return 1;
	}
	if(a.kbid === b.kbid ) {
	  return 0;
	}
      })
    }

    return this.setState({ articles });
  }

  sortByEnabled(direction) {
    console.log(direction);
    let articles = this.state.articles;

    if(direction) {
      articles.sort((a, b) => {
	if(a.enabled && !b.enabled) {
	  return 1;
	}
	if( !a.enabled && b.enabled) {
	  return -1;
	}
	if(a.enabled === b.enabled) {
	  return 0;
	}
      })
    } else {
      articles.sort((a, b) => {
	if(a.enabled && !b.enabled) {
	  return -1;
	}
	if( !a.enabled && b.enabled) {
	  return 1;
	}
	if(a.enabled === b.enabled) {
	  return 0;
	}
      })
    }

    return this.setState({ articles });

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
