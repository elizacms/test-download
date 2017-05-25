var Option = React.createClass({
  getInitialState() {
    return {
      msId: "",
      text: "",
      entity: ""
    };
  },

  componentDidMount() {
    this.setState({
      msId: this.props.value.msId,
      text: this.props.value.text || "",
      entity: this.props.value.entity || ""
    });
  },

  componentWillReceiveProps(nextProps) {
    this.setState({
      msId: nextProps.value.msId,
      text: nextProps.value.text || "",
      entity: nextProps.value.entity || ""
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
      <div>
        Option Text:
        <input
          name='text'
          value={this.state.text}
          onChange={this.handleInputChange}
        />
        &nbsp;&nbsp;&nbsp;&nbsp;
        Entity Value:
        <input
          name='entity'
          value={this.state.entity}
          onChange={this.handleInputChange}
        />
        &nbsp;&nbsp;&nbsp;&nbsp;
        <a href="#" onClick={(e)=>this.props.removeItem(e, this.state.msId)}>X</a>
      </div>
    );
  }
});
