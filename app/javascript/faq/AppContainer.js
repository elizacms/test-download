import React, { Component } from 'react';

// components
import App from './App';
import TextEditor from './components/TextEditor';
import { fetchArticles, fetchSingleArticle } from './api/articles';
import ee from './EventEmitter'

export default class AppContainer extends Component {

	constructor(props) {
		super(props);

		this.state = {
			heading: 'FAQ Index',
			modalContent: null,
			currentPage: 1,
			articles: [],
		};

		this.openModal = this.openModal.bind(this);
		this.closeModal = this.closeModal.bind(this);
	}

	componentDidMount() {
		this.ee = ee;

		this.ee.on('openModal', this.openModal);
		this.ee.on('closeModal', this.closeModal);

	}

	componentWillUnmount() {
		this.ee.off('openModal');
		this.ee.off('closeModal');
	}

	openModal(content) {
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
			currentPage: this.state.currentPage,
			articleTotal: this.state.articleTotal,
		}

		return (
			<App {...appProps}  />
		)
	}
}

