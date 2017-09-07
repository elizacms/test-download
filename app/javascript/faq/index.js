import 'babel-polyfill';
import 'whatwg-fetch';
import React from 'react';
import ReactDOM from 'react-dom';
import './index.sass';
import AppContainer from './AppContainer';
import registerServiceWorker from './registerServiceWorker';

ReactDOM.render(<AppContainer />, document.getElementById('Faq'));
registerServiceWorker();
