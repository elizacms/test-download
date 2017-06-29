var Video = React.createClass({
  getInitialState() {
    return {
      thumbnail: "",
      url: ""
    };
  },

  componentDidMount() {
    this.setState({
      thumbnail: this.props.value.thumbnail || "",
      url: this.props.value.url || ""
    });
  },

  componentWillReceiveProps(nextProps) {
    this.setState({
      thumbnail: nextProps.value.thumbnail || "",
      url: nextProps.value.url || ""
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
          <span className='dialog-label'>Video Thumbnail</span>
        </label>
        <input
          className='dialog-input'
          type='text'
          name='thumbnail'
          placeholder="Thumbnail"
          value={this.state.thumbnail}
          onChange={this.handleInputChange}
        />
        <label>
          <span className='dialog-label'>Video URL</span>
        </label>
        <input
          className='dialog-input abs-position'
          type='text'
          name='url'
          placeholder="Link"
          value={this.state.url}
          onChange={this.handleInputChange}
        />
        <br />
      </div>
    );
  }
});