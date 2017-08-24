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
			modalContent: this.state.modalContent,
		}

		return (
			<App {...appProps}  />
		)
	}
}

