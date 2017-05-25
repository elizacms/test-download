var Text = React.createClass({
  getInitialState() {
    return {
      textValue: "",
      spokenTextValue: ""
    };
  },

  componentDidMount() {
    this.setState({
      textValue: this.props.value.textValue || "",
      spokenTextValue: this.props.value.spokenTextValue || ""
    });
  },

  componentWillReceiveProps(nextProps) {
    this.setState({
      textValue: nextProps.value.textValue || "",
      spokenTextValue: nextProps.value.spokenTextValue || ""
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
        Text:
        <input
          type='text'
          name='textValue'
          value={this.state.textValue}
          onChange={this.handleInputChange}
        />
        <br />

        Spoken Text:
        <input
          type='text'
          name='spokenTextValue'
          value={this.state.spokenTextValue}
          onChange={this.handleInputChange}
        />
      </div>
    );
  }
});
