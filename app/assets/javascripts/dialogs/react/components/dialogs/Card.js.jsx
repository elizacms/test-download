var Card = React.createClass({
  getInitialState() {
    return {
      id: "",
      textValue: "",
      spokenTextValue: "",
      iconUrl: "",
      options: []
    };
  },

  componentDidMount() {
    this.setState({
      id: this.props.index,
      textValue: this.props.value.textValue || "",
      spokenTextValue: this.props.value.spokenTextValue || "",
      iconUrl: this.props.value.iconUrl || "",
      options: this.props.value.options || []
    });
  },

  componentWillReceiveProps(nextProps) {
    this.setState({
      id: nextProps.index,
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
        <label>
          <span className='dialog-label card-label'>Cards</span>
        </label>
        <div className='card-bg'>
          <a href="#" onClick={(e)=>this.props.removeItem(e, this.state.id)}>
            <span className='fa fa-trash option-trash-position'></span>
          </a>
          <Text
            value={ {textValue, spokenTextValue}=this.state }
            componentData={this.handleDataFromChild}
          />
          <label>
            <span className='dialog-label'>Icon URL</span>
          </label>
          <input
            className='dialog-input'
            type='text'
            name="iconUrl"
            value={this.state.iconUrl}
            onChange={this.handleInputChange}
          />
          <Template
            templateType="options"
            value={{options: this.state.options}}
            componentData={this.handleDataFromChild}
          />
        </div>
      </div>
    );
  }
});
