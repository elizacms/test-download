import React, { Component } from 'react';
import shortid from 'shortid';

import { searchArticleByType, fetchArticles, deleteArticle, fetchSingleArticle, putArticle } from '../../api/articles';
import EditFaqView from '../EditFaqView/';
import ee from '../../EventEmitter';

export default class AddFaq extends Component {
	constructor(props) {
		super(props);

    this.state = {
      currentArticle: props.currentArticle,
    };

    this.ee = ee;
  }
}
