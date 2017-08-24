import React, { Component } from 'react';
import shortid from 'shortid';

import Settings from '../Settings';
import Questions from '../Questions';
import Answers from '../Answers';

import './edit-faq.sass';

export default class EditFaq extends Component {
	constructor(props) {
		super(props);
  }

	render() {
    const {kbId, questions, answers} = this.props;

		return (
      <div className="EditFaq">
        <h2>Edit Faq</h2>
        <Settings kbId={kbId} />
        <Questions data={questions} />
        <Answers data={answers} />
      </div>
		)
	}
}

