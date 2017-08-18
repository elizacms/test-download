import React, { Component } from 'react';

// components
import App from './App';
import TextEditor from './components/TextEditor';
import {fetchArticles} from './api/articles';
import ee from './EventEmitter'

export default class AppContainer extends Component {

	constructor(props) {
		super(props);

		this.state = {
			heading: 'FAQ Index',
			modalContent: null,
			articles: [],
		};

		this.openModal = this.openModal.bind(this);
		this.closeModal = this.closeModal.bind(this);
		this.changePageNumber = this.changePageNumber.bind(this);
		this.pageForward = this.pageForward.bind(this);
		this.pageBack = this.pageBack.bind(this);
		this.fetchArticlesAndSetThemInState = this.fetchArticlesAndSetThemInState.bind(this);
	}

	componentDidMount() {
		this.ee = ee;
		this.ee.on('openModal', this.openModal);
		this.ee.on('closeModal', this.closeModal);
		this.ee.on('changePageNumber', this.changePageNumber);
		this.ee.on('pageForward', this.pageForward);
		this.ee.on('pageBack', this.pageBack);
		this.fetchArticlesAndSetThemInState();
	}

	componentWillUnmount() {
		this.ee.off('openModal');
		this.ee.off('closeModal');
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
		this.fetchArticlesAndSetThemInState(page);
	}

	openModal(content) {
		console.log(content);
		this.setState({
			modalContent: content,
		});
	}

	closeModal() {
		this.setState({
			modalContent: null
		})

	}

	render() {

		let appProps = {
			heading: this.state.heading,
			articles: this.state.articles,
			modalContent: this.state.modalContent,
			pagesTotal: this.state.pagesTotal,
			articleTotal: this.state.articleTotal,
		}

		return (
			<App {...appProps}  />
		)
	}
}

