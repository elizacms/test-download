var Text = React.createClass({
  getInitialState() {
    return {
      text: "",
      spokenText: ""
    };
  },

  componentDidMount() {
    this.setState({
      text: this.props.value.text || "",
      spokenText: this.props.value.spokenText || ""
    });
  },

  componentWillReceiveProps(nextProps) {
    this.setState({
      text: nextProps.value.text || "",
      spokenText: nextProps.value.spokenText || ""
    });
  },

  handleInputChange(event) {
    const stateKey = event.target.name;

    this.setState({
      [stateKey]: event.target.value
    }, () => { //Update parent after setState
      this.props.componentData( this.state );
    });
  },

  render() {
    return(
      <div>
        <label>
          <span className='dialog-label'>Text</span>
        </label>
        <input
          className='dialog-input'
          type='text'
          name='text'
          value={this.state.text}
          onChange={this.handleInputChange}
        />
        <br />
        <label>
          <span className='dialog-label'>Spoken Text</span>
        </label>
        <input
          className='dialog-input'
          type='text'
          name='spokenText'
          value={this.state.spokenText}
          onChange={this.handleInputChange}
        />
      </div>
    );
  }
});
