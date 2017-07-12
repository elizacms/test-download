var Option = React.createClass({
  getInitialState() {
    return {
      id: "",
      text: "",
      spokenText: ""
    };
  },

  componentDidMount() {
    this.setState({
      id: this.props.index,
      text: this.props.value.text || "",
      spokenText: this.props.value.spokenText || ""
    });
  },

  componentWillReceiveProps(nextProps) {
    this.setState({
      id: nextProps.index,
      text: nextProps.value.text || "",
      spokenText: nextProps.value.spokenText || ""
    });
  },

  handleInputChange(event) {
    this.setState({
      [event.target.name]: event.target.value
    }, () => {
      this.props.updateParent( this.state );
    });
  },

  render() {
    return(
      <div className="flex-box-wrapper">
        <label className="flex-box1">
          <span className='dialog-label'>Option</span>
        </label>
        <input
          className='dialog-input response-option-input flex-box2'
          type='text'
          name='text'
          placeholder="Text"
          value={this.state.text}
          onChange={this.handleInputChange}
        />
        <label className="flex-box1 margin-left15">
          <span className='dialog-label'>Entity</span>
        </label>
        <input
          className='dialog-input response-option-input margin-left-50 flex-box2'
          type='text'
          name='spokenText'
          placeholder="Entity Value"
          value={this.state.spokenText}
          onChange={this.handleInputChange}
        />
        <a href="#" onClick={(e)=>this.props.removeItem(e, this.state.id)}>
          <span className='fa fa-trash option-trash-position'></span>
        </a>
      </div>
    );
  }
});
