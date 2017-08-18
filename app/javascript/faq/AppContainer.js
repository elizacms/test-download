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
	}

	componentDidMount() {
		this.ee = ee;
		this.ee.on('openModal', this.openModal);
		this.ee.on('closeModal', this.closeModal);

		fetchArticles()
			.then(articles => {

				console.log(articles.results);

				return this.setState({
					articles: articles.results,
					pagesTotal: articles.pages,
					articleTotal: articles.total,
				})
			});
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

