var Card = React.createClass({
  getInitialState() {
    return {
      msId: "",
      textValue: "",
      spokenTextValue: "",
      iconUrl: "",
      options: []
    };
  },

  componentDidMount() {
    this.setState({ ...this.state, ...this.props.value });

    // this.setState({
    //   msId: this.props.value.msId || "",
    //   textValue: this.props.value.textValue || "",
    //   spokenTextValue: this.props.value.spokenTextValue || "",
    //   iconUrl: this.props.value.iconUrl || "",
    //   options: this.props.value.options || []
    // }, () => {
    //   console.log(this.state);
    // });
  },

  componentWillReceiveProps(nextProps) {
    this.setState({
      msId: nextProps.value.msId || "",
      textValue: nextProps.value.textValue || "",
      spokenTextValue: nextProps.value.spokenTextValue || "",
      iconUrl: nextProps.value.iconUrl || "",
      options: nextProps.value.options || []
    });
  },

  handleDataFromChild(newValue) {
    const tmpCardState = this.state;

    for (var prop in newValue) {
      tmpCardState[prop] = newValue[prop];
    }

    this.setState({ ...this.state, ...tmpCardState }, () => {
      this.updateParent();
    });
  },

  handleInputChange(event) {
    this.setState({
      [event.target.name]: event.target.value
    }, ()=>{
      this.updateParent();
    });
  },

  updateParent() {
    this.props.updateParent( this.state );
  },

  render() {
    return(
      <div>
        <Text
          value={ {textValue, spokenTextValue}=this.state }
          componentData={this.handleDataFromChild}
        />

        Icon URL: 
        <input
          name="iconUrl"
          value={this.state.iconUrl}
          onChange={this.handleInputChange}
        />

        <Template
          templateType="options"
          value={{options: this.state.options}}
          componentData={this.handleDataFromChild}
        />

        <a href="#" onClick={(e)=>this.props.removeItem(e, this.state.msId)}>X</a>
      </div>
    );
  }
});
