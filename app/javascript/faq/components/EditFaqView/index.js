import React, { Component } from 'react';
import shortid from 'shortid';

import Settings from '../Settings';
import Questions from '../Questions';
import Answers from '../Answers';

import './edit-faq.sass';

export default class EditFaqView extends Component {
	constructor(props) {
		super(props);
  }

	render() {
    const {kbId, isEnabled, questions, answers} = this.props;

		return (
      <div className="EditFaq">
      <h2>{kbId ? 'Edit ' : 'Add New'}FAQ</h2>
        <br />
        <Settings kbId={kbId} isEnabled={isEnabled} />
        <br /><br />
        <Questions data={questions} />
        <br /><br />
        <Answers data={answers} />
      </div>
		)
	}
}

