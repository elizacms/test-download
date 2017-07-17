var Qna = React.createClass({
  getInitialState() {
    return {
      qnaSpokenText     : "",
      qnaQuestion       : "",
      qnaFaq            : false,
      qnaAnswers        : [ {answer: ''} ],
      qnaVideoThumbnail : '',
      qnaVideoUrl       : '',
      qnaImageThumbnail : '',
      qnaImageUrl       : '',
      qnaLinkText       : '',
      qnaUrl            : ''
    };
  },

  componentDidMount() {
    this.setState({
      qnaSpokenText     : this.props.value.qnaSpokenText     || "",
      qnaQuestion       : this.props.value.qnaQuestion       || "",
      qnaFaq            : this.props.value.qnaFaq            || false,
      qnaAnswers        : this.props.value.qnaAnswers        || [ {answer: ''} ],
      qnaVideoThumbnail : this.props.value.qnaVideoThumbnail || "",
      qnaVideoUrl       : this.props.value.qnaVideoUrl       || "",
      qnaImageThumbnail : this.props.value.qnaImageThumbnail || "",
      qnaImageUrl       : this.props.value.qnaImageUrl       || "",
      qnaLinkText       : this.props.value.qnaLinkText       || "",
      qnaUrl            : this.props.value.qnaUrl            || ""
    });
  },

  componentWillReceiveProps(nextProps) {
    this.setState({
      qnaSpokenText     : nextProps.value.qnaSpokenText     || "",
      qnaQuestion       : nextProps.value.qnaQuestion       || "",
      qnaFaq            : nextProps.value.qnaFaq            || false,
      qnaAnswers        : nextProps.value.qnaAnswers        || [ {answer: ''} ],
      qnaVideoThumbnail : nextProps.value.qnaVideoThumbnail || "",
      qnaVideoUrl       : nextProps.value.qnaVideoUrl       || "",
      qnaImageThumbnail : nextProps.value.qnaImageThumbnail || "",
      qnaImageUrl       : nextProps.value.qnaImageUrl       || "",
      qnaLinkText       : nextProps.value.qnaLinkText       || "",
      qnaUrl            : nextProps.value.qnaUrl            || ""
    });
  },

  addAnswer(e) {
    e.preventDefault();

    this.setState({
      qnaAnswers: this.state.qnaAnswers.concat( [{answer:''}] )
    });
  },

  deleteAnswer(index, e) {
    e.preventDefault();

    this.setState({
      qnaAnswers: this.state.qnaAnswers.filter((a, i) => index !== i)
    }, () => {
      this.handleInputChange( {target:{name:'qnaAnswers', value:null}} );
    });
  },

  handleInputChange(event, index) {
    const stateKey = event.target.name;
    let data;

    if (stateKey === 'qnaFaq') {
      data = event.target.checked;
    } else if (stateKey === 'qnaAnswers') {
      data = this.state.qnaAnswers.map((m,i) => {
        if (index == i) {
          m.answer = event.target.value;
        }
        return m;
      });
    } else {
      data = event.target.value;
    }

    this.setState({
      [stateKey]: data
    }, () => { //Update parent after setState
      this.props.componentData( this.state );
    });
  },

  render() {
    return(
      <div>
        <label>
          <span className='dialog-label'>Spoken Text</span>
        </label>
        <input
          className='dialog-input'
          type='text'
          name='qnaSpokenText'
          value={this.state.qnaSpokenText}
          onChange={this.handleInputChange}
        />
        <br />
        <label><span className='dialog-label'>Question</span></label>
        <input
          className='dialog-input'
          type='text'
          name='qnaQuestion'
          value={this.state.qnaQuestion}
          onChange={this.handleInputChange}
        />
        <br />
        <label>
          <span className='dialog-label'>Include in FAQ</span>
        </label>
        <input
          className='response-qna-faq'
          type="checkbox"
          name='qnaFaq'
          checked={this.state.qnaFaq}
          onChange={this.handleInputChange}
        />
        <br />
        <label>
          <span className='dialog-label'>Answer</span>
        </label>
        <a onClick={this.addAnswer} href='#' className='pull-right'>
          <span className='add-answer'>Add Answer</span>
        </a>
        <br />
        {this.state.qnaAnswers.map((answer, index) => (
          <div key={index}>
              <textarea
                name='qnaAnswers'
                className='response-qna-answer-input'
                value={answer.answer}
                onChange={ (e) => this.handleInputChange(e, index) }
              />
              <a onClick={this.deleteAnswer.bind(this, index)} href='#'>
                <i className='fa fa-trash answer-delete'></i>
              </a>
          </div>
        ))}
        <br />
        <div className="qna-inputs">
          <div className="abs-position">
            <label>
              <span className='dialog-label'>Video Thumbnail</span>
            </label>
            <input
              className='dialog-input'
              type='text'
              name='qnaVideoThumbnail'
              value={this.state.qnaVideoThumbnail}
              onChange={this.handleInputChange}
            />
            <label><span className='dialog-label qna-label-right'>Video Url</span></label>
            <input
              className='dialog-input'
              type='text'
              name='qnaVideoUrl'
              value={this.state.qnaVideoUrl}
              onChange={this.handleInputChange}
            />
          <br />
            <label><span className='dialog-label'>Image Thumbnail</span></label>
            <input
              className='dialog-input'
              type='text'
              name='qnaImageThumbnail'
              value={this.state.qnaImageThumbnail}
              onChange={this.handleInputChange}
            />
            <label><span className='dialog-label qna-label-right'>Image Url</span></label>
            <input
              className='dialog-input'
              type='text'
              name='qnaImageUrl'
              value={this.state.qnaImageUrl}
              onChange={this.handleInputChange}
            />
          <br />
            <label><span className='dialog-label'>Link Text</span></label>
            <input
              className='dialog-input'
              type='text'
              name='qnaLinkText'
              value={this.state.qnaLinkText}
              onChange={this.handleInputChange}
            />
            <label><span className='dialog-label qna-label-right'>Url</span></label>
            <input
              className='dialog-input'
              type='text'
              name='qnaUrl'
              value={this.state.qnaUrl}
              onChange={this.handleInputChange}
            />
          </div>
        </div>
      </div>
    );
  }
});